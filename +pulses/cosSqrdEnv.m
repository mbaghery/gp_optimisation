function pulse = cosSqrdEnv(t, E0, omega, T)
%COSSQRDENV Laser pulse with cos squared envelope
%   E0 is the laser field amplitude, omega is the laser field frequency,
%   and T is the FWHM of the laser field. The center of the pulse is at 0.
  
  if (nargin < 2)
    E0 = 0.05;
    omega = 0.057; % 800nm
    T = 250;
  end
  
  pulse = (t>-T & t<T) .* ...
    (E0 * sin(omega * t) .* cos(pi * t / (2 * T)) .^ 2);
  
  % carrier wave: E0 * sin(omega * t)
  % envelope: cos(pi * t / (2 * T)) .^ 2
  
end

