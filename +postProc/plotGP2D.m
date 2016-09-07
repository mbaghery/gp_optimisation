function plotGP2D(gp, domain, range, xNext)
  % Plot the gaussian process, only if the training points are on a
  % 2d plane, with the colourcoding representing their target values.
  % this function only works for noFeatures = 2

  X1 = linspace(domain.min(1), domain.max(1), 50);
  X2 = linspace(domain.min(2), domain.max(2), 50);
  [x1, x2] = meshgrid(X1,X2);
  
  % evaluated points so far
  [xTrainSet, ~] = gp.getTrainSet;
  xTrainSet = util.denormalise(xTrainSet, domain);
  

  % GP estimate of the latent function
%   yGP = gp.predictAffine(util.normalise([x1(:),x2(:)], domain));
  yGP = gp.oneStepLookahead(util.normalise([x1(:),x2(:)], domain));

%   yGP = reshape(util.denormalise(yGP, range), size(x1));
  yGP = reshape(yGP, size(x1));

  
  % Plot estimate by GP
  myfillcontour(x1, x2, yGP-mean(yGP(:)), 5);
%   myfillcontour(x1, x2, yGP, 5);
  
  xlabel('x1');
  ylabel('x2');
%   set(gca, 'XScale', 'log');
  
  xlim([domain.min(1), domain.max(1)]);
  ylim([domain.min(2), domain.max(2)]);
  
  
  
  % evaluated points so far
  hold on
  plot(xTrainSet(:,1), xTrainSet(:,2), '+', ...
    'MarkerSize', 8, 'LineWidth', 2, 'Color', 'black');
  hold off


  % next points, if given
  if (nargin < 4)
    return
  end
  hold on
  plot(xNext(:,1), xNext(:,2), '+', ...
    'MarkerSize', 8, 'LineWidth', 2, 'Color', 'blue');
  hold off

end

