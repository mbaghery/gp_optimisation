function varargout = predictAffine(this, xs)
%PREDICTAFFINE Predictive probability based on affine assumption
%   xs is a matrix whose rows are test points
  
  if (nargout < 4)
    [m, k, Ks] = this.predictMAP(xs);
  else
    [m, k, Dm, Dk, Ks, DKs] = this.predictMAP(xs);
  end
  
  % no. of hyper parameters
  noHP = numel(this.hyp.mean) + numel(this.hyp.cov);
  
  % REDUNDANT, this line should be removed some way
%   Ks = feval(this.cov{:}, this.hyp.cov, this.X, xs)';

  dm = zeros(size(xs, 1), noHP);
  for i = 1:numel(this.hyp.mean)
    dm(:,i) = ...
      feval(this.mean{:}, this.hyp.mean, xs, i) ...
      - Ks * this.invK_dmu(:,i);
  end
  
  for i = 1:numel(this.hyp.cov)
    dm(:,i + numel(this.hyp.mean)) = ...
      feval(this.cov{:}, this.hyp.cov, this.X, xs, i)' * this.alpha ...
      - Ks * this.invK_dK_alpha(:,i);
  end
  
  
  
  k = k + sum((dm(:,end-numel(this.hyp.cov)+1:end-1) * ...
    this.LaplaceCov) .* dm(:,end-numel(this.hyp.cov)+1:end-1), 2);
  
%   k = k + sum((dm * this.LaplaceCov) .* dm, 2);

  % remove negative values, as they are meaningless
  k(k < 0) = 0;
  
  
  % calculate the derivatives only if they are needed
  if (nargout<4)
    varargout = {m, k, Ks};
    return
  end
  
  
  
  
  for i = 1:size(xs, 1)
    dDm = zeros(noHP, size(xs, 2));
    
%     % REDUNDANT, this line should be removed some way
%     DKs = feval(this.covD{:}, this.hyp.cov, this.X, xs(i,:));
    
    for j = 1:numel(this.hyp.mean)
      dDm(j,:) = feval(this.meanD{:}, this.hyp.mean, xs(i,:), j) ...
        - this.invK_dmu(:,j)' * DKs;
    end
    
    
    for j = 1:numel(this.hyp.cov)
      dDm(j + numel(this.hyp.mean),:) = ...
        this.alpha' * feval(this.covD{:}, this.hyp.cov, this.X, xs(i,:), j) ...
        - this.invK_dK_alpha(:,j)' * DKs;
    end
    
    
    Dk(i,:) = Dk(i,:) + 2 * dm(i,end-numel(this.hyp.cov)+1:end-1) * ...
      this.LaplaceCov * dDm(end-numel(this.hyp.cov)+1:end-1,:);
    
%     Dk(i,:) = Dk(i,:) + 2 * dm(i,:) * this.LaplaceCov * dDm;
  end
  
  varargout = {m, k, Dm, Dk, Ks, DKs};
  
end
