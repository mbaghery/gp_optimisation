function [x, f] = minsphere(objective, x0, options)
%SPHIMISER Minimise on a sphere; hence the name (sph + imise)
%   It finds the minimum of a given function, assuming that the point
%   should stay on a sphere of radius one at all times.
%   'objective' is a function handle that returns two variables, f and df.
%   'x0' is the starting point of the algorithm, which is a ROW vector.

  if (nargin < 3)
    [x, f] = gpopt.util.mincylin(objective, x0, 0);
  else
    [x, f] = gpopt.util.mincylin(objective, x0, 0, options);
  end

end

