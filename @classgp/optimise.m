function optimise(this)
  % optimise the hyperparameters
  
  this.hyp = minimize(this.hyp, @gp, -300, ...
    this.inf, this.mean, this.cov, this.lik, this.X, this.Y);
  
end