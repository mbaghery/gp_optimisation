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
  
  
%   % it is assumed that only the input correlation lengths are important
%   k = k + sum((dm(:,end-numel(this.hyp.cov)+1:end-1) * ...
%     this.LaplaceCov) .* dm(:,end-numel(this.hyp.cov)+1:end-1), 2);
  
%   % it is assumed that only the correlation function parameters are important
%   k = k + sum((dm(:,end-numel(this.hyp.cov)+1:end) * ...
%     this.LaplaceCov) .* dm(:,end-numel(this.hyp.cov)+1:end), 2);
  
  % it is assumed all the hyperparameters are important.
  k = k + sum((dm * this.LaplaceCov) .* dm, 2);
  
  
  
  % remove negative values, as they are meaningless
  k(k < 0) = 0;
  
  
  % calculate the derivatives only if they are needed
  if (nargout<4)
    varargout = {m, k, Ks};
    return
  end
  
  
  
  
  for i = 1:size(xs, 1)
    dDm = zeros(noHP, size(xs, 2));
    
    for j = 1:numel(this.hyp.mean)
      dDm(j,:) = feval(this.meanD{:}, this.hyp.mean, xs(i,:), j) ...
        - this.invK_dmu(:,j)' * DKs;
    end
    
    
    for j = 1:numel(this.hyp.cov)
      dDm(j + numel(this.hyp.mean),:) = ...
        this.alpha' * feval(this.covD{:}, this.hyp.cov, this.X, xs(i,:), j) ...
        - this.invK_dK_alpha(:,j)' * DKs;
    end
    
    
    % it is assumed that only the input correlation lengths are important
%     Dk(i,:) = Dk(i,:) + 2 * dm(i,end-numel(this.hyp.cov)+1:end-1) * ...
%       this.LaplaceCov * dDm(end-numel(this.hyp.cov)+1:end-1,:);
    
    % it is assumed that only the correlation function parameters are important
%     Dk(i,:) = Dk(i,:) + 2 * dm(i,end-numel(this.hyp.cov)+1:end) * ...
%       this.LaplaceCov * dDm(end-numel(this.hyp.cov)+1:end,:);
    
    % it is assumed all the hyperparameters are important.
    Dk(i,:) = Dk(i,:) + 2 * dm(i,:) * this.LaplaceCov * dDm;
    
  end
  
  varargout = {m, k, Dm, Dk, Ks, DKs};
  
end
