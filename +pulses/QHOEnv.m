function pulse = QHOEnv(t, E0, omega, T, coeffs)
%QHOENV Laser pulse with envelope made of QHO eigenstates
%   coeffs is a row vector. t could be a column vector or a scalar.

  x=t/T;
  n = length(coeffs);

  psi=zeros(length(x), n+2);

  for i=1:n+2
    psi(:, i)=util.QHOState(x, i-1);
  end

  dPsi = bsxfun(@times, psi(:, 1:n+1), x) - ...
    bsxfun(@times, psi(:, 2:n+2), sqrt(2*(1:n+1)));
  ddPsi = psi(:, 1:n) + bsxfun(@times, dPsi(:, 1:n), x) - ...
    bsxfun(@times, dPsi(:, 2:n+1), sqrt(2*(1:n)));

  sumPsi = sum(bsxfun(@times, psi(:,1:n), coeffs), 2);
  sumdPsi = sum(bsxfun(@times, dPsi(:,1:n), coeffs), 2);
  sumddPsi = sum(bsxfun(@times, ddPsi, coeffs), 2);

  pulse = E0 * ...
    ((-2/(omega^2 * T^2) * (sumdPsi.^2 + sumPsi .* sumddPsi) + sumPsi.^2) ...
    .* cos(omega * t) + 4/(omega * T) * sumPsi .* sumdPsi .* sin(omega * t));
  
end
