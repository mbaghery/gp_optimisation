function Dm = meanConstD(hyp, x, i)
%MEANCONSTD dm/dx
%   Derivative with respect to x of constant mean function.


  if nargin<2, Dm = '1'; return; end             % report number of hyperparameters
  Dm = zeros(size(x));                                    % derivative and mean

end

