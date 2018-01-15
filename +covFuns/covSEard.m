function K = covSEard(hyp, x, z, i, j)
%COVSEARD SE covariance funciton with ARD
%   Squared Exponential covariance function with Automatic Relevance Detemination
%   (ARD) distance measure. The covariance function is parameterized as:
% 
%   k(x,z) = sf^2 * exp(-(x - z)'*inv(P)*(x - z)/2)
% 
%   where the P matrix is diagonal with ARD parameters ell_1^2,...,ell_D^2, where
%   D is the dimension of the input space and sf2 is the signal variance. The
%   hyperparameters are:
% 
%   hyp = [ log(ell_1)
%           log(ell_2)
%            .
%           log(ell_D)
%           log(sf) ]
% 
%   Copyright (c) by Carl Edward Rasmussen and Hannes Nickisch, 2010-09-10.
% 
%   See also COVFUNCTIONS.M.
% 
% 
%   Extended by Mehrdad Baghery.
% 

  import gpopt.util.sq_dist

  if nargin<2, K = '(D+1)'; return; end              % report number of parameters
  if nargin<3, z = []; end                                   % make sure, z exists
  xeqz = isempty(z); dg = strcmp(z,'diag');                       % determine mode

  [n,D] = size(x);
  ell = exp(hyp(1:D));                               % characteristic length scale
  sf2 = exp(2*hyp(D+1));                                         % signal variance

  % precompute squared distances
  if dg                                                               % vector kxx
    K = zeros(size(x,1),1);
  else
    if xeqz                                                 % symmetric matrix Kxx
      K = sq_dist(diag(1./ell)*x');
    else                                                   % cross covariances Kxz
      K = sq_dist(diag(1./ell)*x',diag(1./ell)*z');
    end
  end

  if nargin<4                                                         % covariance
    K = sf2*exp(-K/2);
  end

  if nargin==4                                                       % derivatives
    if i<=D                                              % length scale parameters
      if dg
        return;
      end

      if xeqz
        K = sf2*exp(-K/2) .* sq_dist(x(:,i)'/ell(i));
      else
        K = sf2*exp(-K/2) .* sq_dist(x(:,i)'/ell(i),z(:,i)'/ell(i));
      end
    elseif i==D+1                                            % magnitude parameter
      K = 2 * sf2*exp(-K/2);
    else
      error('Unknown hyperparameter')
    end
  end

  if nargin>4                                                            % hessian
    if i<=D
      if dg
        return;
      end

      if j<=D % with respect to ell_i and ell_j
        if i==j
          if xeqz
            K = sf2*exp(-K/2) .* sq_dist(x(:,j)'/ell(j)) ...
                              .* (sq_dist(x(:,j)'/ell(j))-2);
          else
            K = sf2*exp(-K/2) .* sq_dist(x(:,j)'/ell(j),z(:,j)'/ell(j))...
                              .* (sq_dist(x(:,j)'/ell(j),z(:,j)'/ell(j))-2);
          end
        else
          if xeqz
            K = sf2*exp(-K/2) .* sq_dist(x(:,i)'/ell(i)) ...
                              .* sq_dist(x(:,j)'/ell(j));
          else
            K = sf2*exp(-K/2) .* sq_dist(x(:,i)'/ell(i),z(:,i)'/ell(i)) ...
                              .* sq_dist(x(:,j)'/ell(j),z(:,j)'/ell(j));
          end
        end
      elseif j==D+1 % with respect to ell_i and sf
        if xeqz
          K = 2 * sf2*exp(-K/2) .* sq_dist(x(:,i)'/ell(i));
        else
          K = 2 * sf2*exp(-K/2) .* sq_dist(x(:,i)'/ell(i),z(:,i)'/ell(i));
        end
      else
        error('Unknown hyperparameter')
      end
    elseif i==D+1
      if j<=D % with respect to sf and ell_j
        if dg
          return;
        end

        if xeqz
          K = 2 * sf2*exp(-K/2) .* sq_dist(x(:,j)'/ell(j));
        else
          K = 2 * sf2*exp(-K/2) .* sq_dist(x(:,j)'/ell(j),z(:,j)'/ell(j));
        end
      elseif j==D+1 % with respect to sf and sf
        K = 4 * sf2*exp(-K/2);
      else
        error('Unknown hyperparameter')
      end
    else
      error('Unknown hyperparameter')
    end
  end
end
