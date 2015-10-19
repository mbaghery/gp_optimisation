function z = rastrigin(x)
%RASTRIGIN Returns the Rastrigin function at point x
%   x is a matrix consisting of different points represented as rows. x is
%   a collection of row vectors stacked up. The global minimum is at 0.


  d = size(x,2);
  
  z = 10*d ...
    + sum(x.^2 - 10*cos(2*pi*x),2);
  
end

