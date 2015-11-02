function [m, k, Dm, Dk] = predictBBQ(this, xs)
%PREDICTBBQ Prediction based on paper below
%   Paper: Active Learning of Model Evidence Using Bayesian Quadrature
  
  
  if (nargout<3)
    [m, k] = this.predictMAP(xs);
  else
    [m, k, Dm, Dk] = this.predictMAP(xs);
  end
  
  noHP = numel(this.hyp.mean) + numel(this.hyp.cov); % no. of hyper parameters
  
  % REDUNDANT, this line should be removed some way
  Ks = feval(this.cov{:}, this.hyp.cov, this.X, xs)';

  dmStar = zeros(size(xs, 1), noHP);
  for i = 1:numel(this.hyp.mean)
    dmStar(:,i) = feval(this.mean{:}, this.hyp.mean, xs, i) ...
      - Ks * this.invK_dmu(:,i);
  end
  
  for i = 1:numel(this.hyp.cov)
    dmStar(:,i + numel(this.hyp.mean)) = ...
      feval(this.cov{:}, this.hyp.cov, this.X, xs, i)' * this.alpha ...
      - Ks * this.invK_dK_alpha(:,i);
  end
  
  
  
%   k = k + sum((dmStar(:,end-numel(this.hyp.cov)+1:end-1) * ...
%     this.hessian) .* dmStar(:,end-numel(this.hyp.cov)+1:end-1), 2);
  
  k = k + sum((dmStar * this.hessian) .* dmStar, 2);

  
  
  
  % calculate the derivatives only if they are needed
  if (nargout<3)
    return
  end
  
  
  
  
  for i = 1:size(xs, 1)
    dDmStar = zeros(noHP, size(xs, 2));
    
    % REDUNDANT, this line should be removed some way
    DKs = feval(this.covD{:}, this.hyp.cov, this.X, xs(i,:));
    
    for j = 1:numel(this.hyp.mean)
      dDmStar(j,:) = feval(this.meanD{:}, this.hyp.mean, xs(i,:), j) ...
        - this.invK_dmu(:,j)' * DKs;
    end
    
    
    for j = 1:numel(this.hyp.cov)
      dDmStar(j + numel(this.hyp.mean),:) = ...
        this.alpha' * feval(this.covD{:}, this.hyp.cov, this.X, xs(i,:), j) ...
        - this.invK_dK_alpha(:,j)' * DKs;
    end
    
    
%     Dk(i,:) = Dk(i,:) + 2 * dmStar(i,end-numel(this.hyp.cov)+1:end-1) * ...
%       this.hessian * dDmStar(end-numel(this.hyp.cov)+1:end-1,:);
    
    Dk(i,:) = Dk(i,:) + 2 * dmStar(i,:) * this.hessian * dDmStar;
  end
  
  
end
