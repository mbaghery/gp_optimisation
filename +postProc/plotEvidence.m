function plotEvidence(gp, lambda1, lambda2)
  % Plot the evidence of the gaussian process as a function of the first
  % two covariance function hyperparameters

  gpcopy = gp.copy;
  
  if (nargin == 1)
    lambda1 = linspace(0.1,40,50);
    lambda2 = linspace(0.1,40,50);
  end

  logL = zeros(length(lambda2), length(lambda1));
  hyp = gpcopy.hyp;


  for i = 1:length(lambda2)
    for j = 1:length(lambda1)
      hyp.cov(1:2) = [log(lambda1(j)); log(lambda2(i))];
      logL(i,j) = - gpcopy.infer(hyp);
    end
  end


  L = exp(logL);

  % the plot fails if L has very large or very small values
  normalizedL = (L - mean(L(:)))/(max(L(:)) - min(L(:)));
  
  clf
  options.ShowText = 'off';
  myfillcontour(lambda1, lambda2, normalizedL, 5, options);


  xlabel('\lambda_1');
  ylabel('\lambda_2');
  title('L(\lambda_1,\lambda_2|X,y)=p(y|X,\lambda_1,\lambda_2)');
  
end
