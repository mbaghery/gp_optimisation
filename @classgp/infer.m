function [l, dl, ddl] = infer(this, hyp)
%   Does Bayesian inference, that is, it sets up the required matrices.
%   returns the marginalised likelihood and its derivatives if required
%   
%   first derivatives with respect to mean hyperparameters appear and then
%   derivatives with respect to covariance function hyperparameters.

  this.hyp = hyp;
  
  M = feval(this.mean{:}, hyp.mean, this.X);
  K = feval(this.cov{:}, hyp.cov, this.X);

  sn2 = exp(2 * this.uncertainty);

  N = length(this.Y);

  % very small sn2 can cause numerical instabilities; I don't know what
  % this is exactly supposed to mean
  if (sn2 < 1e-6)
    L = chol(K + sn2 * eye(N));
    denominator = 1;
  else
    L = chol(K / sn2 + eye(N));
    denominator = sn2;
  end
  
  % inverse of K matrix with noise
  this.invK = solve_chol(L, eye(N)) / denominator;
  this.alpha = this.invK * (this.Y - M);
  
  
  

  % - log likelihood
  l = 1/2 * (this.Y - M)' * this.alpha ...
     + log(prod(diag(L)))...
     + N/2 * log(2 * pi * denominator);
  
  
  % calculate the derivatives only if they are needed
  if (nargout<=1)
    return
  end
  
  
  noHP = numel(hyp.mean) + numel(hyp.cov); % no. of hyper parameters
  
  % derivatives
  dl = zeros(noHP, 1);
  
  % with respect to mean hyperparameters
  for i = 1:numel(hyp.mean)
    dl(i) = - feval(this.mean{:}, hyp.mean, this.X, i)' * this.alpha;
  end
  
  % with respect to covariance hyperparameters
  Q = this.invK - this.alpha * this.alpha'; % common factor
  dK = zeros(size(this.X, 1), size(this.X, 1), numel(hyp.cov));
  for i = 1:numel(hyp.cov)
    dK(:,:,i) = feval(this.cov{:}, hyp.cov, this.X, [], i);
    dl(i + numel(hyp.mean)) = sum(sum(Q .* dK(:,:,i))) / 2;
  end
  
  
  
  % calculate the hessian only if it is needed
  if (nargout<=2)
    return
  end
  
  
  % hessian
  ddl = zeros(noHP, noHP);
  dmu = zeros(size(this.X, 1), numel(hyp.mean));
  dK_alpha = zeros(size(this.X, 1), numel(hyp.cov));
  invK_dK = zeros(size(this.X, 1), size(this.X, 1), numel(hyp.cov));
  
  invK_dmu = zeros(size(this.X, 1), numel(hyp.mean));
  invK_dK_alpha = zeros(size(this.X, 1), numel(hyp.cov));
  
  for i = 1:numel(hyp.mean)
    dmu(:,i) = feval(this.mean{:}, hyp.mean, this.X, i);
  end

  for i = 1:numel(hyp.cov)
    dK_alpha(:,i) = dK(:,:,i) * this.alpha;
%     dK_invK(:,:,i) = dK(:,:,i) * this.invK;
    invK_dK(:,:,i) = this.invK * dK(:,:,i);
  end
  
  
  % with respect to mean hp only
  for i = 1:numel(hyp.mean)
    
    invK_dmu(:,i) = this.invK * dmu(:,i);
    
    for j = i:numel(hyp.mean)
      ddm = feval(this.mean{:}, hyp.mean, this.X, i, j);
      
%       ddl(i,j) = dmu(:,i)' * this.invK * dmu(:,j) - ddm' * this.alpha;
      ddl(i,j) = invK_dmu(:,i)' * dmu(:,j) - ddm' * this.alpha;
      
      % the hessian matrix is symmetric
      ddl(j,i) = ddl(i,j);
    end
  end
  
  
% with respect to mean and covariance hp
  for i = 1:numel(hyp.cov)
%     dK_invK_alpha(:,i) = (this.alpha' * dK_invK(:,:,i))';
    invK_dK_alpha(:,i) = invK_dK(:,:,i) * this.alpha;
    
    for j = 1:numel(hyp.mean)
%       ddl(i + numel(hyp.mean),j) = dK_invK_alpha(:,i)' * dmu(:,j);
      ddl(i + numel(hyp.mean),j) = dmu(:,j)' * invK_dK_alpha(:,i);
      
      % the hessian matrix is symmetric
      ddl(j,i + numel(hyp.mean)) = ddl(i + numel(hyp.mean),j);
    end
  end
  
  
  % with respect to covariance hp only
  for i = 1:numel(hyp.cov)
    for j = i:numel(hyp.cov)
      ddK = feval(this.cov{:}, hyp.cov, this.X, [], i, j);
      Q = 2 * dK_alpha(:,i) * dK_alpha(:,j)' + ddK;
      
%       ddl(i + numel(hyp.mean), j + numel(hyp.mean)) = (...
%         sum(sum(Q .* this.invK - dK_invK(:,:,i)' .* dK_invK(:,:,j))) ...
%         - this.alpha' * ddK * this.alpha ) / 2;

        ddl(i + numel(hyp.mean), j + numel(hyp.mean)) = (...
          sum(sum(Q .* this.invK - invK_dK(:,:,i) .* invK_dK(:,:,j)')) ...
          - this.alpha' * ddK * this.alpha ) / 2;
        
        
      % the hessian matrix is symmetric
      ddl(j + numel(hyp.mean),i + numel(hyp.mean)) = ...
        ddl(i + numel(hyp.mean),j + numel(hyp.mean));
    end
  end
  
  this.invK_dmu = invK_dmu;
  this.invK_dK_alpha = invK_dK_alpha;
%   this.dK_alpha = dK_alpha;
  
  
  % it is assumed that only the input correlation lengths are important
%   this.hessian = ddl(end-numel(hyp.cov)+1:end-1,end-numel(hyp.cov)+1:end-1) ...
%     \ eye(numel(hyp.cov)-1);
  
  this.hessian = ddl \ eye(noHP);
  
end