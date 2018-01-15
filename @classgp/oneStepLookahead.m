function [f, Df] = oneStepLookahead(this, xs)
%ONESTEPLOOKAHEAD Gives the next probable point to evaluate
%   Implementation of 'Gaussian processes for global optimization,
%    Osborne, et al. 2009'

  if (isempty(xs))
    f=[];
    Df=[];
    return
  end

%   [m, k, Dm, Dk] = this.predictMAP(xs);
  [m, k, Dm, Dk] = this.predictAffine(xs);

  eta = min(this.Y);

  % if the training set is empty
  if (isempty(eta)); eta = min(m); end


  normalCDF = 0.5 * erfc((m-eta) ./ sqrt(2*k));
  normalPDF = exp(-(m-eta).^2 ./ (2*k)) ./ sqrt(2*pi*k);

  f = eta ...
    + normalCDF .* (m - eta) ...
    - normalPDF .* k;


  % calculate the derivative only if it is needed
  if (nargout==1)
    return
  end


  Df = bsxfun(@times, normalCDF, Dm) ...
     - bsxfun(@times, normalPDF, 0.5 * Dk);

  % sometimes k could be zero, which leads to NaN.
  Df(isnan(Df))=0;

end
