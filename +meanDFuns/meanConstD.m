function dA = meanConstD(hyp, x, i)
%MEANCONSTD dm/dx
%   Derivative with respect to x of constant mean function.


  if nargin<2, dA = '1'; return; end             % report number of hyperparameters
  dA = zeros(size(x));                                    % derivative and mean

end

