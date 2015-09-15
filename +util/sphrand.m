function angles = sphrand(n)
%CONSRAND Generate random numbers on an n dimensional sphere
%   The output is the angles of a vector with its tip on an n dimensional
%   sphere; it is a column vector of n-1 elements.

  angles = rand(n-1, 1) .* [ones(n - 2, 1); 2] * pi;

end
