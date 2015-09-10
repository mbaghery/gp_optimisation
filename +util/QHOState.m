function y = QHOState(r, n)
%QHOSTATE Quantum harmonic oscillator eigenstates
%   r is a column vector representing the points at which the value of the
%   eigenstate is needed. n is the number of eigenstate. For instnace, n=0
%   is the ground state. The output is a matrix whose columns are
%   eigenfunctions corresponding to the row vector n.
%   n could be a scalar as well as a row vector.

  y = (pi^(-1/4) * exp(-r.^2/2)) * (1./sqrt(2.^n .* factorial(n))) ...
    .* util.myHermite(r, n);

end

