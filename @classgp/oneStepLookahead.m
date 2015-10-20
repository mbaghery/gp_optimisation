function [f, df] = oneStepLookahead(this, xs)
%ONESTEPLOOKAHEAD Gives the next probable point to evaluate
%   Based on paper: Gaussian processes for global optimization, Osborne,
%   et al.

  [m, k, dm, dk] = this.predict(xs);

  eta = min(this.Y);

%   
% s = sqrt(s2);
% ds = ds2 ./ (2*s);
%   
%   
%   f = 1/2 * (m + eta - sqrt(2/pi)*s.*exp(-(m-eta).^2./(2*s.^2)) ...
%     + (eta-m).*erf((m-eta)./(sqrt(2)*s)));

  
  f = 1/2 * (eta + m) ...
    + 1/2 * (eta - m) .* erf((m-eta)./sqrt(2*k)) ...
    - sqrt(k/(2*pi)) .* exp(-(m-eta).^2./(2*k));


  if (nargout==1)
    return
  end

%   df =  -1/2 * bsxfun(@times, dm, erf((m-eta)./(sqrt(2)*s))-1) ...
%    - bsxfun(@times, ds, exp(-(eta - m).^2./(2*s.^2))/sqrt(2*pi));

  df = -1/2 * bsxfun(@times, dm, erf((m-eta)./sqrt(2*k))-1) ...
       -1/2 * bsxfun(@times, dk, exp(-(m-eta).^2./(2*k))./sqrt(2*pi*k));
     
  % sometimes k could be zero, which leads to NaN. Therefore, let's kill
  % them bitches
  df(isnan(df))=0;

end
  