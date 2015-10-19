function z = schwefel(x)
%SCHWEFEL Returns the Schwefel function at point x
%   x is a matrix consisting of different points represented as rows. x is
%   a collection of row vectors stacked up.
%   This function is usually evaluated inside the hypercube [-500,500], in
%   which case the global minimum is at (420.9687,...,420.9687)


  d = size(x,2);
  
  z = 418.9829*d ...
    - sum(x.*sin(sqrt(abs(x))),2);
  
end

