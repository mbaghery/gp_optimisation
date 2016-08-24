function [energies, spec] = ansatzSpec(params, delta, gamma)
%PLOTSPEC Plots the spectrum based on ansatz in PRL 108, 253001 (2012)
%   maxEnergy is the maximum energy for which the spectrum should be
%   calculated. It should be expressed in atomic units.

  maxEnergy = 1;


  E_gs = -0.125; % energy of ground state
  t0 = params.simLength / 2; % the time when the laser pulse is at its maximum
  envelope = @(t) exp(-(t - t0) .^ 2 / params.FWHM ^ 2 * 4 * log(2));
  sigma = params.FWHM / (2 * sqrt(2 * log(2)));
  J = @(t) sigma * sqrt(pi) / 2 * (1 + erf((t - t0) / sigma));
  

  
  % first column: energies
  % second column: squared dipole matrix elements from 1s to p-states
%   dipole = dlmread('+targetFuns/dipol-ml-4-mb.dat'); % dipole operator

  % first column: energies
  % second column: squared dipole matrix elements from 2p to d-states
  load('/home/mbaghery/Documents/MATLAB/Optimisation/+targetFuns/2p-s-dipole.mat')
  
  dipole(dipole(:,1) < 0, :) = [];
  dipole(dipole(:,1) > maxEnergy, :) = [];
  
  spec = zeros(length(dipole), 1);
  
  
  for i = 1: length(dipole)
    epsilon = dipole(i, 1); % energy
    
    integrand = @(t) envelope(t) ...
      .* (params.A0 * params.omega * exp(-1i * params.omega * t) ...
        + params.A0_x * params.omega_x * exp(-1i * params.omega_x * t)) ...
      .* exp(-1i * E_gs * t) .* exp(-1i * (delta - (params.A0 + params.A0_x) ^ 2 / 4) * J(t)) ...
      .* exp(1i * epsilon * t) .* exp(-gamma / 2 * J(t));

    q = integral(integrand, 0, params.simLength, ...
      'RelTol', 1e-4);

    spec(i) = dipole(i,2) * real(q * conj(q));
    
    if (mod(i, 1000) == 0)
      disp(num2str(dipole(i, 1)));
    end
  end
  
  energies = dipole(:,1);

end
