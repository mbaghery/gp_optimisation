function initialise(this)


% this file should be modified to use gp package
%   K = covSEard(this.hyp.cov, this.X);
% 
%   sn2 = exp(2*this.hyp.lik);
% 
%   N = length(this.Y);
% 
%   % very small sn2 can cause numerical instabilities
%   if (sn2 < 1e-6)
%     L = chol(K + sn2 * eye(N));
%     this.beta = solve_chol(L, eye(N));
%   else
%     L = chol(K / sn2 + eye(N));
%     this.beta = solve_chol(L, eye(N)) / sn2;
%   end
% 
%   this.alpha = this.beta*this.Y;
  
  
  
  
  [~,~,this.post] = gp(this.hyp, this.inf, this.mean, ...
    this.cov, this.lik, this.X, this.Y);
  
  
end