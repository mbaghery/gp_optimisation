function [f, df] = oneStepLookahead(this,xs)
%ONESTEPLOOKAHEAD Gives the next probable point to evaluate
%   Based on paper: Gaussian processes for global optimization, Osborne,
%   et al.

  [m, s, dm, ds] = this.predict(xs);

  eta = min(this.Y);

  f = 1/2 * (m + eta - sqrt(2/pi)*s.*exp(-(m-eta).^2./(2*s.^2)) ...
    + (eta-m).*erf((m-eta)./(sqrt(2)*s)));
  
  if (nargout==1)
    return
  end

  df = -1/2 * bsxfun(@times, dm, erf((m-eta)./(sqrt(2)*s))-1) ...
    - bsxfun(@times, ds, exp(-(eta - m).^2./(2*s.^2))/sqrt(2*pi));
end
  