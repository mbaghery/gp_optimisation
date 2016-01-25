function output = optimise(this, hyp)
  % optimise the hyperparameters
  
% % Rasmussen's method
%   prior.lik = {{@priorDelta}};
%   inf = {@infPrior,@infExact,prior};
%   lik = {@likGauss};
%   
%   hyp2=hyp;
%   hyp2.lik = this.uncertainty;
%   
%   output = minimize(hyp2, @gp, -300, ...
%     inf, this.mean, this.cov, lik, this.X, this.Y);
  


	% My method
  problem.x0 = [hyp.mean; hyp.cov];
  problem.solver = 'fmincon';
  problem.options = optimoptions('fmincon', ...
    'GradObj', 'on', ...
    'Hessian','on', ...
    'Algorithm', 'trust-region-reflective', ...
    'MaxIter', 100, ...
    'Display', 'none');
  
  problem.objective = @(x) this.infer( ...
    struct('mean',x(1:length(hyp.mean)), ...
           'cov' ,x(length(hyp.mean)+1:end)) );
  
  out = fmincon(problem);
  
  output.mean = out(1:length(hyp.mean));
  output.cov = out(length(hyp.mean)+1:end);
  
  
  % For both methods
  % This line is necessary to update all private variables in classgp
  [~,~,~] = this.infer(output);
end