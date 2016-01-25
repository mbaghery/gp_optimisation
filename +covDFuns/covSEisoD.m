function DK = covSEisoD(hyp, x, z, i, j)
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
%   Tested on 2015-12-16. Works fine.

  if nargin<2, DK = '2'; return; end                 % report number of parameters
  if nargin<3, z = 'diag'; end                               % make sure, z exists
  dg = strcmp(z,'diag');                                          % determine mode

  [n,D] = size(x);

  % ell should always be a row vector
  ell = exp(hyp(1));                                 % characteristic length scale
  sf2 = exp(2*hyp(2));                                           % signal variance

  % precompute distances
  if dg                                                     % symmetric matrix Kxx
    if n>1
      error('For "diag" option, x can only have one point.');
    end

    DK = zeros(n,D);
    return;
  else                                                     % cross covariances Kxz
    DK = bsxfun(@minus, x, z) / ell;
    Q = sum(DK.^2, 2);
  end

  if nargin==3                                                        % covariance
    DK = bsxfun(@times, sf2 / ell * exp(-Q / 2), DK);
  end

  if nargin==4                       % derivatives with respect to hyperparameters
    if i==1
      DK = bsxfun(@times, sf2 / ell * exp(-Q / 2) .* (Q - 2), DK);
    elseif i==2
      DK = 2 * bsxfun(@times, sf2 / ell * exp(-Q / 2), DK);
    else
      error('Unknown hyperparameter');
    end
  end

  if nargin>4                                                            % hessian
    if i==1
      if j==1
        DK = bsxfun(@times, sf2 / ell * exp(-Q / 2) .* (Q.^2 - 6*Q + 4), DK);
      elseif j==2
        DK = 2 * bsxfun(@times, sf2 / ell * exp(-Q / 2) .* (Q - 2), DK);
      else
        error('Unknown hyperparameter');
      end
    elseif i==2
      if j==1
        DK = 2 * bsxfun(@times, sf2 / ell * exp(-Q / 2) .* (Q - 2), DK);
      elseif j==2
        DK = 4 * bsxfun(@times, sf2 / ell * exp(-Q / 2), DK);
      else
        error('Unknown hyperparameter');
      end
    else
      error('Unknown hyperparameter');
    end
  end

end
