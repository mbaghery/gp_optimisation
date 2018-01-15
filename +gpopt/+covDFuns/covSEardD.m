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

  if nargin<2, DK = '(D+1)'; return; end             % report number of parameters
  if nargin<3, z = 'diag'; end                               % make sure, z exists
  dg = strcmp(z,'diag');                                          % determine mode

  [n,D] = size(x);

  % ell should always be a row vector
  ell = reshape(exp(hyp(1:D)), 1, D);                % characteristic length scale
  sf2 = exp(2*hyp(D+1));                                         % signal variance

  % precompute distances
  if dg                                                     % symmetric matrix Kxx
    if n>1
      error('For "diag" option, x can only have one point.');
    end

    DK = zeros(n,D);
    return;
  else                                                     % cross covariances Kxz
    DK = bsxfun(@rdivide, bsxfun(@minus, x, z), ell);
    Q = sum(DK.^2, 2);
  end

  if nargin==3                                                        % covariance
    DK = bsxfun(@rdivide, sf2 * exp(-Q / 2), ell) .* DK;
  end

  if nargin==4                       % derivatives with respect to hyperparameters
    if i<=D
      aux = zeros(n,D);
      aux(:,i) = - 2/ell(i) * DK(:,i);

      DK = bsxfun(@times, sf2 * exp(-Q / 2), ...
        bsxfun(@rdivide, DK(:,i).^2, ell) .* DK + aux);
    elseif i==D+1
        DK = 2 * bsxfun(@rdivide, sf2 * exp(-Q / 2), ell) .* DK;
    else
      error('Unknown hyperparameter');
    end
  end

  if nargin>4                                                            % hessian
    if i<=D
      if j<=D
        if i==j
          aux = zeros(n,D);
          aux(:,i) = - 4/ell(i) * DK(:,i).^3 + 4/ell(i) * DK(:,i);

          DK = bsxfun(@times, sf2 * exp(-Q / 2), ...
            bsxfun(@rdivide, DK(:,i).^4 - 2 * DK(:,i).^2, ell) .* DK + aux);
        else
          aux = zeros(n,D);
          aux(:,i) = - 2/ell(i) * DK(:,j).^2 .* DK(:,i);
          aux(:,j) = - 2/ell(j) * DK(:,i).^2 .* DK(:,j);

          DK = bsxfun(@times, sf2 * exp(-Q / 2), ...
            bsxfun(@rdivide, DK(:,i).^2 .* DK(:,j).^2 , ell) .* DK + aux);
        end
      elseif j==D+1
        aux = zeros(n,D);
        aux(:,i) = - 2/ell(i) * DK(:,i);

        DK = 2 * bsxfun(@times, sf2 * exp(-Q / 2), ...
          bsxfun(@rdivide, DK(:,i).^2, ell) .* DK + aux);
      else
        error('Unknown hyperparameter');
      end
    elseif i==D+1
      if j<=D
        aux = zeros(n,D);
        aux(:,j) = - 2/ell(j) * DK(:,j);

        DK = 2 * bsxfun(@times, sf2 * exp(-Q / 2), ...
          bsxfun(@rdivide, DK(:,j).^2, ell) .* DK + aux);
      elseif j==D+1
        DK = 4 * bsxfun(@rdivide, sf2 * exp(-Q / 2), ell) .* DK;
      else
        error('Unknown hyperparameter');
      end
    else
      error('Unknown hyperparameter');
    end
  end

end
