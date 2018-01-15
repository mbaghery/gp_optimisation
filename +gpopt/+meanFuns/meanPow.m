function m = meanPow(d, mean, hyp, x, i, j)

% meanPow - compose a mean function as the power of another mean function m0.
%
% The degree d has to be a strictly positive integer.
%
% m(x) = m_0(x) ^ d
%
% The hyperparameter is:
%
% hyp = [ ]
%
% This function doesn't actually compute very much on its own, it merely does
% some bookkeeping, and calls other mean function to do the actual work.
%
% Copyright (c) by Carl Edward Rasmussen & Hannes Nickisch 2013-11-02.
%
% See also MEANFUNCTIONS.M.

d = max(abs(floor(d)),1);                         % positive integer degree only
if nargin<4                                        % report number of parameters
  m = feval(mean{:}); return
end

[n,D] = size(x);
if nargin==4                                               % compute mean vector
  m = feval(mean{:},hyp,x).^d;
elseif nargin ==5                                    % compute derivative vector
  m = ( d*feval(mean{:},hyp,x).^(d-1) ).* feval(mean{:},hyp,x,i);
else                                                           % compute hessian
  m = ( d*(d-1)*feval(mean{:},hyp,x).^(d-2) ).*feval(mean{:},hyp,x,i).*feval(mean{:},hyp,x,j) ...
    + ( d*feval(mean{:},hyp,x).^(d-1) ).*feval(mean{:},hyp,x,i,j);
end