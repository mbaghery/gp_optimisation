function pulse = QHOEnv(t, E0, omega, T, coeffs)
%QHOENV Laser pulse with envelope made of QHO eigenstates
%   coeffs is a row vector. t could be a column vector or a scalar.

  time=t/T;
  N = length(coeffs);

  % QHO eigenstates from 0 to N+1
  phi=util.QHOState(time, 0:N+1);

  dPhi = bsxfun(@times, phi(:, 1:N+1), time) - ...
    bsxfun(@times, phi(:, 2:N+2), sqrt(2*(1:N+1)));
  ddPhi = phi(:, 1:N) + bsxfun(@times, dPhi(:, 1:N), time) - ...
    bsxfun(@times, dPhi(:, 2:N+1), sqrt(2*(1:N)));

  sumPhi = sum(bsxfun(@times, phi(:,1:N), coeffs), 2);
  sumdPhi = sum(bsxfun(@times, dPhi(:,1:N), coeffs), 2);
  sumddPhi = sum(bsxfun(@times, ddPhi, coeffs), 2);

  pulse = E0 * ...
    ((-2/(omega^2 * T^2) * (sumdPhi.^2 + sumPhi .* sumddPhi) + sumPhi.^2) ...
    .* cos(omega * t) + 4/(omega * T) * sumPhi .* sumdPhi .* sin(omega * t));
  
end
