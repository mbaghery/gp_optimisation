function DK = covSEardD(hyp, x, z, i, j)
%COVSEARDD Derivative of SE-ARD covariance function with respect to z
%   Derivative with respect to z of Squared Exponential covariance function
%   with Automatic Relevance Detemination (ARD) distance measure.
%   
%   (D/Dz k(x,z))_i = sf^2 * exp(-(x - z)'*inv(P)*(x - z)/2) * (x_i - z_i)'*inv(P)
%   
%   Unlike covSEard file, there's no option as 'xeqz', because in general
%   only x can have more than one point while z always has one point.
%   The derivatives are taken with respect to z, the second parameter.
%   
%   The 'diag' option only works when x has one point.
%   
%   Tested on 2/11/2015. Works fine.

  if nargin<2, DK = '(D+1)'; return; end             % report number of parameters
  if nargin<3, z = 'diag'; end                               % make sure, z exists
  dg = strcmp(z,'diag');                                          % determine mode

  [n,D] = size(x);
  ell = exp(hyp(1:D));                               % characteristic length scale

  % precompute distances
  if dg                                                     % symmetric matrix Kxx
    if n>1
      error('For "diag" option, x should only have one point.');
    end
    
    DK = zeros(n,D);
    return;
  else                                                     % cross covariances Kxz
    DK = bsxfun(@minus, x*diag(1./(ell.^2)), z*diag(1./(ell.^2)));
  end

  if nargin==3                                                        % covariance
    DK = bsxfun(@times, DK, covFuns.covSEard(hyp, x, z));
  end

  if nargin==4                       % derivatives with respect to hyperparameters
    if i<=D
      Q = zeros(n,D);
      Q(:,i) = 2;
      
%       DK = bsxfun(@times, DK, covFuns.covSEard(hyp, x, z, i)) ...
%          + bsxfun(@times, -2*(x(:,i)-z(i))/ell(i)^2, covFuns.covSEard(hyp, x, z));
      
      % The line below should be faster as it doens't need to calculate the
      % distances twice, while the line commented out above needs to
      % calculate the distances once in each call to covSEard.
%       DK = bsxfun(@times, DK, covFuns.covSEard(hyp, x, z)) ...
%         .* bsxfun(@minus, (x(:,i)-z(i)).^2/ell(i)^2, Q);
      
      DK = bsxfun(@times, DK, covFuns.covSEard(hyp, x, z)) ...
        .* bsxfun(@minus, DK(:,i).^2 * ell(i)^2, Q);
    elseif i==D+1
%       DK = 2 * bsxfun(@times, DK, covFuns.covSEard(hyp, x, z));
      DK = bsxfun(@times, DK, covFuns.covSEard(hyp, x, z, i));
    else
      error('Unknown hyperparameter');
    end
  end
  
  if nargin>4                                                            % hessian
    
  end

end
