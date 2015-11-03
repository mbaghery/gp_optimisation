function DK = covSEardD(hyp, x, z, i)
%COVSEARDD dK/dx
%   Derivative with respect to x of Squared Exponential covariance function
%   with Automatic Relevance Detemination (ARD) distance measure.
%
%   It is only allowed for one of x and z to have more than one point.
%   Tested on 2/11/2015. Works fine.

  if nargin<2, DK = '(D+1)'; return; end             % report number of parameters
  if nargin<3, z = 'diag'; end                               % make sure, z exists
  dg = strcmp(z,'diag');                                          % determine mode

  [n,D] = size(x);
  ell = exp(hyp(1:D));                               % characteristic length scale

  % precompute distances
  if dg                                                     % symmetric matrix Kxx
    DK = zeros(n,D);
    return;
  else                                                     % cross covariances Kxz
    DK = bsxfun(@minus, x*diag(1./(ell.^2)), z*diag(1./(ell.^2)));
  end

  DK = bsxfun(@times, DK, covFuns.covSEard(hyp, x, z));
  if nargin>3                    % derivatives with respect to hyperparameters
    if i<=D
      Q = zeros(n,D);
      Q(:,i)=1;
      DK = DK .* bsxfun(@minus, (x(:,i)-z(i)).^2/ell(i)^2, 2*Q);
    elseif i==D+1
      DK = 2 * DK;
    end
  end

end
