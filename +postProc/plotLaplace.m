function plotLaplace(gp, lambda1, lambda2)
  % Plot the prior resulting from Laplace approximation

  if (nargin == 1)
    lambda1 = linspace(0.1,40,50);
    lambda2 = linspace(0.1,40,50);
  end


  logL = zeros(length(lambda2), length(lambda1));
  hyp_center = gp.hyp.cov(1:2);


  for i = 1:length(lambda2)
    for j = 1:length(lambda1)
      hyp_diff = hyp_center - [log(lambda1(j)); log(lambda2(i))];
      logL(i,j) = -1/2 * hyp_diff' * (gp.LaplaceCov \ hyp_diff);
    end
  end


  clf
  options.ShowText = 'off';
  myfillcontour(lambda1, lambda2, exp(logL), 5, options);


  xlabel('\lambda_1');
  ylabel('\lambda_2');
  title('L(\lambda_1,\lambda_2|X,y)=p(y|X,\lambda_1,\lambda_2)');

end
