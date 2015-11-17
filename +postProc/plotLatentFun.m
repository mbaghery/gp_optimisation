function plotLatentFun(gp, f, domain, range, xNext)
  % Plot the latent function of the gaussian process
  % this function only works for noFeatures = 1

  xPlot = linspace(domain.min, domain.max, 500)';

  % ground truth
  yGroundTruth = f(xPlot);

  % evaluated points so far
  [xTrainSet, yTrainSet] = gp.getTrainSet;
  yTrainSet = util.denormalise(yTrainSet, range);

  % onestep lookahead cost
  yLookaheadCost = gp.oneStepLookahead(xPlot);
  yLookaheadCost = util.denormalise(yLookaheadCost, range);

  % what points are evaluated next
  yNext = gp.oneStepLookahead(xNext);
  yNext = util.denormalise(yNext, range);

  % GP estimate of the latent function
  [yGP, kGP] = gp.predictMAP(xPlot);
  yGP = util.denormalise(yGP, range);

  % Plot estimate by GP
  myvarianceplot(xPlot, yGP, sqrt(kGP));
  % break
  hold on

  colors = [94,129,181;
            225,156,36;
            143,177,49;
            236,98,53;
            135,120,179;
            197,110,26;
            93,158,200;
            255,191,0;
            165,96,157;
            146,150,0;
            234,85,54;
            102,133,217;
            249,159,18;
            188,91,128;
            71,183,109];

  % ground truth
  plot(xPlot, yGroundTruth, '-k', ...
    'LineWidth', 1.5);

  % evaluated points so far
  plot(xTrainSet,yTrainSet,'+', ...
    'Color', colors(4,:), 'MarkerSize', 8, 'LineWidth', 2);

  % onestep lookahead cost
  plot(xPlot, yLookaheadCost, ...
    'Color', 'r', 'LineWidth', 2);

  % next points
  plot(x,yNext,'o', ...
    'Color', colors(8,:), 'LineWidth', 2, 'MarkerSize', 20);

  hold off

end
