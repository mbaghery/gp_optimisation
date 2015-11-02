function [m, k, dm2, dk2] = predictMAP(this, xs)
%PREDICTMAP Prediction based on MAP procedure
%   xs is a matrix whose rows are test points
  
  
%   Ks = feval(this.cov{:}, this.hyp.cov, this.X, xs)';
%   kBase = Ks * this.invKwNoise;
%   
%   
%   % mean(xs)
%   m = feval(this.mean{:}, this.hyp.mean, xs) ...
%     + sum(bsxfun(@times, Ks, this.alpha'), 2);
%   
%   % variance(xs)
%   k = feval(this.cov{:}, this.hyp.cov, xs, 'diag') - sum(kBase .* Ks, 2);
  
  
  % remove negative values, as they are meaningless
%   k(k < 0) = 0;








  Ks = feval(this.cov{:}, this.hyp.cov, this.X, xs)';
  Ks_invKwNoise = Ks * this.invKwNoise;
  
  
  % mean(xs)
%   m = feval(this.mean{:}, this.hyp.mean, xs) ...
%     + sum(bsxfun(@times, Ks, this.alpha'), 2);
  
  m = feval(this.mean{:}, this.hyp.mean, xs) + Ks * this.alpha;
  
  % variance(xs)
  k = feval(this.cov{:}, this.hyp.cov, xs, 'diag') ...
    - sum(Ks_invKwNoise .* Ks, 2);













  
  
  % Calculate the derivatives only if they are needed
  if (nargout < 3)
    return
  end

%   dm = zeros(size(xs));
%   dk = zeros(size(xs));
  
  dm2 = zeros(size(xs));
  dk2 = zeros(size(xs));
  
  
%   % matrix of correlation lengths as a row vector
%   Lambda = exp(-2 * this.hyp.cov(1:end-1))';

  for i = 1:size(xs, 1)
%     XxLambda = bsxfun(@times, bsxfun(@minus, this.X, xs(i,:)), Lambda);

    % d mean(xs) / dx
% %       dm(i,:) = (Ks(i,:) .* this.alpha') * XxLambda;
%     dm(i,:) = mBase(i,:) * XxLambda;
    
    KDs = feval(this.covD{:}, this.hyp.cov, this.X, xs(i,:));
    
    dm2(i,:) = feval(this.meanD{:}, this.hyp.mean, xs(i,:)) ...
      + this.alpha' * KDs;

    % d sigma^2(xs) / dx
% %       dk(i,:) = -2 * ((this.beta * Ks(i,:)')' .* Ks(i,:)) * XxLambda;
% %       dk(i,:) = -2 * ((Ks(i,:) * this.beta) .* Ks(i,:)) * XxLambda;
%     dk(i,:) = -2 * (kBase(i, :) * XxLambda);
    
%     dk2(i,:) = feval(this.covD{:}, this.hyp.cov, xs(i,:)) ...
%       - 2 * feval(this.cov{:}, this.hyp.cov, this.X, xs(i,:))' * ...
%       this.invKwNoise * ...
%       feval(this.covD{:}, this.hyp.cov, this.X, xs(i,:));
%     
%     
%     dk2(i,:) = feval(this.covD{:}, this.hyp.cov, xs(i,:)) ...
%       - 2 * Ks(i,:) * this.invKwNoise * Q;
    

    dk2(i,:) = feval(this.covD{:}, this.hyp.cov, xs(i,:)) ...
      - 2 * Ks_invKwNoise(i,:) * KDs;
    
  end
  
end