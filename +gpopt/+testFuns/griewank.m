function z = griewank(x)
%GRIEWANK Returns the Griewank function at point x
%   x is a matrix consisting of different points represented as rows. x is
%   a collection of row vectors stacked up. The global minimum is at 0.


  d = size(x,2);
  
  ii = 1:d;
  
  z = sum(x.^2,2)/4000 ...
    - prod(cos(bsxfun(@rdivide,x,sqrt(ii))),2) ...
    + 1;
  
end

