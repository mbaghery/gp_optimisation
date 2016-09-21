function K = covSEard(hyp, x, z, i, j)

% Squared Exponential covariance function with Automatic Relevance Detemination
% (ARD) distance measure. The covariance function is parameterized as:
%
% k(x^p,x^q) = sf^2 * exp(-(x^p - x^q)'*inv(P)*(x^p - x^q)/2)
%
% where the P matrix is diagonal with ARD parameters ell_1^2,...,ell_D^2, where
% D is the dimension of the input space and sf2 is the signal variance. The
% hyperparameters are:
%
% hyp = [ log(ell_1)
%         log(ell_2)
%          .
%         log(ell_D)
%         log(sf) ]
%
% Copyright (c) by Carl Edward Rasmussen and Hannes Nickisch, 2010-09-10.
%
% See also COVFUNCTIONS.M.
%
%
% Extended by Mehrdad Baghery, 2015-10-28. DOESN'T Works perfectly fine.
%

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
    K = util.sq_dist(diag(1./ell)*x');
  else                                                   % cross covariances Kxz
    K = util.sq_dist(diag(1./ell)*x',diag(1./ell)*z');
  end
end

K = sf2*exp(-K/2);                                                  % covariance
if nargin>3                                                        % derivatives
  if i<=D                                              % length scale parameters
    if dg
      K = K*0;
      return;
    else
      if xeqz
        K = K .* util.sq_dist(x(:,i)'/ell(i));
      else
        K = K .* util.sq_dist(x(:,i)'/ell(i),z(:,i)'/ell(i));
      end
    end
  elseif i==D+1                                            % magnitude parameter
    K = 2*K;
  else
    error('Unknown hyperparameter')
  end
end

% From here on, it is my own doing
if nargin>4                                                            % hessian
  if i<=D
    if j<=D % with respect to ell_i and ell_j
      if i==j
        if xeqz
          K = K .* (util.sq_dist(x(:,j)'/ell(j))-2);
        else
          K = K .* (util.sq_dist(x(:,j)'/ell(j),z(:,j)'/ell(j))-2);
        end
      else
        if xeqz
          K = K .* util.sq_dist(x(:,j)'/ell(j));
        else
          K = K .* util.sq_dist(x(:,j)'/ell(j),z(:,j)'/ell(j));
        end
      end
    elseif j==D+1 % with respect to ell_i and sf
      K = 2*K;
    else
      error('Unknown hyperparameter')
    end
  elseif i==D+1
    if j<=D % with respect to sf and ell_j
      if xeqz
        K = K .* util.sq_dist(x(:,j)'/ell(j));
      else
        K = K .* util.sq_dist(x(:,j)'/ell(j),z(:,j)'/ell(j));
      end
    elseif j==D+1 % with respect to sf and sf
      K = 2*K;
    else
      error('Unknown hyperparameter')
    end
  else
    error('Unknown hyperparameter')
  end
end