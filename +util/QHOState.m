function y = QHOState(r, n)
%QHOSTATE Quantum harmonic oscillator eigenstates
%   r is a column vector representing the points at which the value of the
%   eigenstate is needed. n is the number of eigenstate. For instnace, n=0
%   is the ground state. The output is a column vector.

  % this is my version
  y = 1/sqrt( 2^n * factorial(n)) * pi^(-1/4) * ...
    exp(-r.^2/2) .* hermite(n, r);
  
  % this is ulf's version
%   y = 1/sqrt( 2^n * factorial(n)) * ...
%     exp(-r.^2/2) .* hermite(n, r);

end

