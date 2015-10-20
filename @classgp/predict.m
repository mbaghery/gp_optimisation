function [m, k, dm, dk] = predict(this, xs)
  % xs is a matrix whose rows are test points
  
  % mean(xs)
%   m = Ks*this.alpha;
% %   m = sum(mBase,2);

  % sigma^2(xs)
%   k = covSEard(this.hyp.cov,xs,'diag') - sum((Ks*this.beta).*Ks, 2);
% %   k = covSEard(this.hyp.cov,xs,'diag') - sum(kBase, 2);
  
  % remove negative values, as they are meaningless
% %   k(k<0) = 0;

%   % sigma(xs)
%   s = sqrt(s2);


[~,~,m,k]=gp(this.hyp, this.inf, this.mean, ...
    this.cov, this.lik, this.X, this.post, xs);


  % For now, the rest is only valid for covSEard and likGauss
  
  if (nargout==4) % if the derivatives are needed
    
    % prior covariance
    Ks = covSEard(this.hyp.cov, this.X, xs)';
    
    N = length(this.Y);
    
    if (isempty(this.beta) || size(this.beta,1)~=N)
      this.beta = (this.post.sW * this.post.sW') ...
        .* solve_chol(this.post.L, eye(N));
    end
    

    mBase = bsxfun(@times, Ks, this.post.alpha');
    kBase = (Ks * this.beta) .* Ks;
    
    
    dm=zeros(size(xs));
%     ds=zeros(size(xs));
    dk=zeros(size(xs));

    % matrix of correlation lengths as a row vector
    Lambda=exp(-2*this.hyp.cov(1:end-1))';

    for i=1:size(xs,1)
      XxLambda = bsxfun(@times,bsxfun(@minus,this.X,xs(i,:)),Lambda);

      % d mean(xs) / dx
%       dm(i,:) = (Ks(i,:) .* this.alpha') * XxLambda;
      dm(i,:) = mBase(i,:) * XxLambda;

      % d sigma^2(xs) / dx
%       dk(i,:) = -2 * ((this.beta * Ks(i,:)')' .* Ks(i,:)) * XxLambda;
%       dk(i,:) = -2 * ((Ks(i,:) * this.beta) .* Ks(i,:)) * XxLambda;
      dk(i,:) = -2 * (kBase(i, :) * XxLambda);
      
%       % d sigma(xs) / dx
%       ds(i,:) = ds2 / (2*s(i));
    end
    
  end

end