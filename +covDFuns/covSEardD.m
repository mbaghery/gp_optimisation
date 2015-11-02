function dK = covSEardD(hyp, x, z, i)
%COVSEARDD dK/dx
%   Derivative with respect to x of Squared Exponential covariance function
%   with Automatic Relevance Detemination (ARD) distance measure.
%
%   It is only allowed for one of x and z to have more than one point.



  if nargin<2, dK = '(D+1)'; return; end             % report number of parameters
  if nargin<3, z = []; end                                   % make sure, z exists
  xeqz = isempty(z);                                              % determine mode

  [n,D] = size(x);
  ell = exp(hyp(1:D));                               % characteristic length scale

  % precompute distances
  if xeqz                                                   % symmetric matrix Kxx
    dK = zeros(n,D);
    return;
  else                                                     % cross covariances Kxz
    dK = bsxfun(@minus,x*diag(1./(ell.^2)),z*diag(1./(ell.^2)));
    % it is only allowed for one of x or z to have multiple points
    if (size(z,1)~=1) % if z has more than one
      dK = dK';
    end
  end

  if nargin<=3
    dK = bsxfun(@times, dK, covFuns.covSEard(hyp, x, z));
  elseif nargin>3                    % derivatives with respect to hyperparameters
    dK = dK .* covFuns.covSEard(hyp, x, z, i);
    if i<=D
      Q = bsxfun(@minus,x(:,i)*diag(1./(ell(i).^2)),z(:,i)*diag(1./(ell(i).^2)));
      if (size(z,1)~=1) % if z has more than one
        Q = Q';
      end
      dK = dK - 2 * covFuns.covSEard(hyp, x, z) .* Q;
    end

  end

end
