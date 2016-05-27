function [varargout] = predictMAP(this, xs)
%PREDICTMAP Predictive probability based on MAP approximation
%   xs is a matrix whose rows are test points
%   If only 'm' and 'k' are wanted, Ks will be passed as the third output
%   argument. If 'm', 'k', 'Dm', and 'Dk' are wanted, the four of them are
%   passed along with Ks and DKs. These two variables are required in
%   predictAffine.

  Ks = feval(this.cov{:}, this.hyp.cov, this.X, xs)';
  Ks_invK = Ks * this.invK;
  
  m = feval(this.mean{:}, this.hyp.mean, xs) ...
    + Ks * this.alpha;
  
  % variance(xs)
  k = feval(this.cov{:}, this.hyp.cov, xs, 'diag') ...
    - sum(Ks_invK .* Ks, 2);
  
  % remove negative values, as they are meaningless
%   k(k < 0) = 0;


  % Calculate the derivatives only if they are needed
  if (nargout < 4)
    varargout = {m, k, Ks};
    return
  end
  
  Dm = zeros(size(xs));
  Dk = zeros(size(xs));
  
  for i = 1:size(xs, 1)
    
    DKs = feval(this.covD{:}, this.hyp.cov, this.X, xs(i,:));
    
    % d mean(xs) / dx
    Dm(i,:) = feval(this.meanD{:}, this.hyp.mean, xs(i,:)) ...
      + this.alpha' * DKs;
    
    % d sigma^2(xs) / dx
    Dk(i,:) = feval(this.covD{:}, this.hyp.cov, xs(i,:), 'diag') ...
      - 2 * Ks_invK(i,:) * DKs;
  end
  
  varargout = {m, k, Dm, Dk, Ks, DKs};
  
end