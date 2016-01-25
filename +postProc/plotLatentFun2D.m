function plotLatentFun2D(gp, f, domain, range, xNext)
  % Plot the latent function of the gaussian process
  % this function only works for noFeatures = 1

  x1 = linspace(domain.min(1), domain.max(1), 100)';
  x2 = linspace(domain.min(2), domain.max(2), 100)';
    
  [xPlot1, xPlot2] = meshgrid(x1,x2);
  xPlot = [xPlot1(:), xPlot2(:)];

  % ground truth
  yGroundTruth = reshape(f(xPlot), size(xPlot1));

  % evaluated points so far
  xTrainSet = gp.getTrainSet;

  % onestep lookahead cost
  yLookaheadCost = gp.oneStepLookahead(xPlot);
  yLookaheadCost = reshape(util.denormalise(yLookaheadCost, range), size(xPlot1));

  % GP estimate of the latent function
  yGP = gp.predictMAP(xPlot);
  yGP = reshape(util.denormalise(yGP, range), size(xPlot1));
  
  
  % Plot estimate by GP
  subplot(2,2,1);
  surf(xPlot1, xPlot2, yGP, 'EdgeColor', 'none');
  view(2)
  title('GP estimate');
  
  % ground truth, and evaluated points so far
  subplot(2,2,2);
  contourf(xPlot1, xPlot2, yGroundTruth, 5);
  hold on
  plot(xTrainSet(:,1), xTrainSet(:,2), '+', ...
    'MarkerSize', 8, 'LineWidth', 2, 'Color', 'red');
  hold off
  title('ground truth and evaluated points');

  % onestep lookahead cost and next points
  subplot(2,2,3);
  surf(xPlot1, xPlot2, yLookaheadCost, 'EdgeColor', 'none');
  view(2)
  title('One-step lookahead cost and next points');
  if (nargin<5)
    return
  end
  hold on
  plot(xNext(:,1), xNext(:,2), '+', 'MarkerSize', 8, 'LineWidth', 2);
  hold off

end


%   colors = [94,129,181;
%             225,156,36;
%             143,177,49;
%             236,98,53;
%             135,120,179;
%             197,110,26;
%             93,158,200;
%             255,191,0;
%             165,96,157;
%             146,150,0;
%             234,85,54;
%             102,133,217;
%             249,159,18;
%             188,91,128;
%             71,183,109];
