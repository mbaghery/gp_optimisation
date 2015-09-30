function optimise(this)
  % optimise the hyperparameters
  
  prior.lik = {{@priorDelta}};

  optimizedhyp = minimize(this.hyp, @gp, -300, ...
    {@infPrior,@infExact,prior}, [], ...
    {@covSEard}, {@likGauss}, this.X, this.Y);

  this.hyp=optimizedhyp;
end