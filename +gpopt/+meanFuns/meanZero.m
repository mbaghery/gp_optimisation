function m = meanZero(hyp, x, i, j)

% Zero mean function. The mean function does not have any parameters.
%
% m(x) = 0
%
% Copyright (c) by Carl Edward Rasmussen and Hannes Nickisch, 2010-01-10.
%
% See also MEANFUNCTIONS.M.

if nargin<2, m = '0'; return; end             % report number of hyperparameters 
m = zeros(size(x,1),1);                                    % derivative and mean
