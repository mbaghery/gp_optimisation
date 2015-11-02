function dA = meanZeroD(hyp, x, i)
%MEANZEROD dm/dx
%   Derivative with respect to x of zero mean function.


  if nargin<2, dA = '0'; return; end             % report number of hyperparameters 
  dA = zeros(size(x));                                    % derivative and mean

end

