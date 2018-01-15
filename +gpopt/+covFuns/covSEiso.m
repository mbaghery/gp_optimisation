function K = covSEiso(hyp, x, z, i, j)
%COVSEISO Isotropic SE covariance funciton
%   Squared Exponential covariance function with isotropic distance measure. The
%   covariance function is parameterized as:
% 
%   k(x,z) = sf^2 * exp(-(x - z)'*inv(P)*(x - z)/2) 
% 
%   where the P matrix is ell^2 times the unit matrix and sf^2 is the signal
%   variance. The hyperparameters are:
% 
%   hyp = [ log(ell)
%           log(sf)  ]
% 
%   For more help on design of covariance functions, try "help covFunctions".
% 
%   Copyright (c) by Carl Edward Rasmussen and Hannes Nickisch, 2010-09-10.
% 
%   See also COVFUNCTIONS.M.
% 
% 
%   Extended by Mehrdad Baghery, 2015-12-14. Works perfectly fine.
% 

  import gpopt.util.sq_dist

  if nargin<2, K = '2'; return; end                  % report number of parameters
  if nargin<3, z = []; end                                   % make sure, z exists
  xeqz = isempty(z); dg = strcmp(z,'diag');                       % determine mode

  ell = exp(hyp(1));                                 % characteristic length scale
  sf2 = exp(2*hyp(2));                                           % signal variance

  % precompute squared distances
  if dg                                                               % vector kxx
    K = zeros(size(x,1),1);
  else
    if xeqz                                                 % symmetric matrix Kxx
      K = sq_dist(x'/ell);
    else                                                   % cross covariances Kxz
      K = sq_dist(x'/ell,z'/ell);
    end
  end

  if nargin<4                                                        % covariances
    K = sf2*exp(-K/2);
  end

  if nargin==4                                                       % derivatives
    if i==1
      K = sf2*exp(-K/2) .* K;
    elseif i==2
      K = 2 * sf2*exp(-K/2);
    else
      error('Unknown hyperparameter')
    end
  end

  % From here on, it is my own doing
  if nargin==5                                                           % hessian
    if i==1
      if j==1
        K = sf2*exp(-K/2) .*K.*(K-2);
      elseif j==2
        K = 2 * sf2*exp(-K/2) .* K;
      else
        error('Unknown hyperparameter')
      end
    elseif i==2
      if j==1
        K = 2 * sf2*exp(-K/2) .*K;
      elseif j==2
        K = 4 * sf2*exp(-K/2);
      else
        error('Unknown hyperparameter')
      end
    else
      error('Unknown hyperparameter')
    end
  end
end
