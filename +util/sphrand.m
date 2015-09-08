function angles = sphrand(n)
%CONSRAND Generate random numbers on a n+1 dimensional sphere
%   The output is the angles of a vector with its tip on a n+1 dimensional
%   sphere; it is a column vector.

  angles = rand(n, 1) .* [ones(n - 1, 1); 2] * pi;

end
