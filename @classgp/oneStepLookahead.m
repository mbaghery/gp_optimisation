function [f, df] = oneStepLookahead(this, xs)
%ONESTEPLOOKAHEAD Gives the next probable point to evaluate
%   Based on paper: Gaussian processes for global optimization, Osborne,
%   et al.

  if (isempty(xs))
    f=[];
    df=[];
    return
  end

  [m, k, dm, dk] = this.predictMAP(xs);
%   [m, k, dm, dk] = this.predictAffine(xs);

  eta = min(this.Y);

  % if the training set is empty
  if (isempty(eta)); eta = min(m); end


%   f = 1/2 * (m + eta - sqrt(2/pi)*s.*exp(-(m-eta).^2./(2*s.^2)) ...
%     + (eta-m).*erf((m-eta)./(sqrt(2)*s)));


%   f = 1/2 * (eta + m) ...
%     + 1/2 * (eta - m) .* erf((m-eta) ./ sqrt(2*k)) ...
%     - sqrt(k / (2*pi)) .* exp(-(m-eta).^2 ./ (2*k));


  normalCDF = 0.5 * erfc((m-eta) ./ sqrt(2*k));
  normalPDF = exp(-(m-eta).^2 ./ (2*k)) ./ sqrt(2*pi*k);

  f = eta ...
    + normalCDF .* (m - eta) ...
    - normalPDF .* k;


  % calculate the derivative only if it is needed
  if (nargout==1)
    return
  end

%   df =  -1/2 * bsxfun(@times, dm, erf((m-eta)./(sqrt(2)*s))-1) ...
%    - bsxfun(@times, ds, exp(-(eta - m).^2./(2*s.^2))/sqrt(2*pi));

%   df = -1/2 * bsxfun(@times, dm, erf((m-eta) ./ sqrt(2*k)) - 1) ...
%        -1/2 * bsxfun(@times, dk, exp(-(m-eta).^2 ./ (2*k)) ./ sqrt(2*pi*k));

  df = bsxfun(@times, normalCDF, dm) ...
     - bsxfun(@times, normalPDF, 0.5 * dk);

  % sometimes k could be zero, which leads to NaN. Therefore, let's kill
  % them bitches all
  df(isnan(df))=0;

end
  