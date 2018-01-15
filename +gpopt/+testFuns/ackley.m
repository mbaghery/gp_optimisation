function z = ackley(x)
%ACKLEY Returns the Ackley function at point x
%   x is a matrix consisting of different points represented as rows. x is
%   a collection of row vectors stacked up. The global minimum is at 0.


  d = size(x,2);
  
  z = -20*exp(-0.2*sqrt(1/d*sum(x.^2,2))) ...
    - exp(1/d*sum(cos(2*pi*x),2)) ...
    + 20 + exp(1);

end

