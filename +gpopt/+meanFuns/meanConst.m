function m = meanConst(hyp, x, i, j)

% Constant mean function. The mean function is parameterized as:
%
% m(x) = c
%
% The hyperparameter is:
%
% hyp = [ c ]
%
% Copyright (c) by Carl Edward Rasmussen and Hannes Nickisch, 2010-08-04.
%
% See also MEANFUNCTIONS.M.

if nargin<2, m = '1'; return; end             % report number of hyperparameters 
if numel(hyp)~=1, error('Exactly one hyperparameter needed.'), end
c = hyp;
if nargin==2
  m = c*ones(size(x,1),1);                                       % evaluate mean
elseif nargin ==3
  if i==1
    m = ones(size(x,1),1);                                          % derivative
  else
    m = zeros(size(x,1),1);
  end
else
  m = zeros(size(x,1),1);                                              % hessian
end