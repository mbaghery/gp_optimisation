function [m, s, dm, ds] = predict(this, xs)
  % xs is a matrix whose rows are test points

  ks = covSEard(this.hyp.cov, this.X, xs)';

  % mean(xs)
  m = ks*this.alpha;

  % sigma^2(xs)
  s2 = exp(2*this.hyp.cov(end)) - sum((ks*this.beta).*ks,2);

  % sigma(xs)
  s = sqrt(s2);


  if (nargout==4)
    dm=zeros(size(xs));
    ds=zeros(size(xs));

    % matrix of correlation lengths as a row vector
    Lambda=exp(-2*this.hyp.cov(1:end-1))';

    for i=1:size(xs,1)
      XxLambda = bsxfun(@times,bsxfun(@minus,this.X,xs(i,:)),Lambda);

      % d mean(xs) / dx
      dm(i,:) = (ks(i,:).*this.alpha') * XxLambda;

      % d sigma^2(xs) / dx
      ds2 = -2 * ((this.beta*ks(i,:)')'.*ks(i,:)) * XxLambda;

      % d sigma(xs) / dx
      ds(i,:) = ds2 / (2*s(i));
    end
  end

end