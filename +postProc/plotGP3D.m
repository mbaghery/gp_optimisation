function plotGP3D(gp, radius, range, xNext)
  % Plot the gaussian process, only if the training points are on a
  % sphere, with the colourcoding representing their target values.
  % this function only works for noFeatures = 3

  [x1, x2, x3] = sphere(300);
  x1 = radius * x1;
  x2 = radius * x2;
  x3 = radius * x3;
  
  % evaluated points so far
  xTrainSet = gp.getTrainSet;

  % GP estimate of the latent function
  yGP = gp.predictMAP([x1(:),x2(:),x3(:)]);
%   yGP = gp.oneStepLookahead([x1(:),x2(:),x3(:)]);

  yGP = reshape(util.denormalise(yGP, range), size(x1));
%   yGP = reshape(yGP, size(x1));

  
  % Plot estimate by GP
  surf(x1, x2, x3, yGP, 'EdgeColor', 'none');
  axis square
  xlabel('x1');
  ylabel('x2');
  zlabel('x3');
  colorbar
  
  
  % evaluated points so far
  hold on
  plot3(xTrainSet(:,1), xTrainSet(:,2), xTrainSet(:,3), '+', ...
    'MarkerSize', 8, 'LineWidth', 2, 'Color', 'black');
  hold off


  % next points, if given
  if (nargin<4)
    return
  end
  hold on
  plot(xNext(:,1), xNext(:,2), xNext(:,3), '+', ...
    'MarkerSize', 8, 'LineWidth', 2, 'Color', 'red');
  hold off

end


% [x1, x2, x3] = sphere(200);
% y=griddata(1.1*finalX(:,1),1.1*finalX(:,2),1.1*finalX(:,3),finalY(:),x1(:),x2(:),x3(:),'natural');
% surf(x1,x2,x3,reshape(y,size(x1)),'EdgeColor','none'), hold on
% plot3(finalX(:,1),finalX(:,2),finalX(:,3),'k+'),grid on, axis square

