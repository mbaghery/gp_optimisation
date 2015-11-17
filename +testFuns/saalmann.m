function z = saalmann(x)
%SAALMANN Returns the Saalmann function at point x
%   x is a column vector consisting of different points stacked up. The
%   global minimum is to the left of 0.

  z = prod(sin(2 * (0.7 + 1./(1 + exp(-x))) .* x), 2) + 0.002 * sum(x.^2, 2);

end

