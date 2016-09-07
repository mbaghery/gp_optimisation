function [dipoledot_fft, omega] = hhgSpectrum(observables)
%HHGSPECTRUM Summary of this function goes here
%   Detailed explanation goes here

  dipole = observables(:,4);
  time = observables(:,1);
  
  dt = (time(2)-time(1));
  N = length(time);
  
  T = N*dt;
  delta_omega = 2*pi/T;
  
  
  dipoledot = sptoeplitz([0, -1, zeros(1, length(dipole)-2)], ...
                         [0,  1, zeros(1, length(dipole)-2)]) * dipole / (2*dt);
  dipoledot = dipoledot .* mask(50, 1700, time, T/2);
  

  omega = delta_omega * (0:N/2-1)';
  
  dipoledot_fft = fft(dipoledot) / N;
  dipoledot_fft(N/2+1:end) = [];
  dipoledot_fft(2:end) = 2*dipoledot_fft(2:end);
  
  
%   mymask_fft = fft(mymask) / N;
%   mymask_fft(N/2+1:end) = [];
%   mymask_fft(2:end) = 2*mymask_fft(2:end);
  
%   dipole_fft = fft(dipole) / N;
%   dipole_fft(N/2+1:end) = [];
%   dipole_fft(2:end) = 2*dipole_fft(2:end);
  
%   dipole_fft =  dipole_fft .* (1i * omega) ; % + exp(-1i*omega*T)*dipole(end);
  
  
  function output = mask(gamma, beta, t, t0)
    % gamma determines how fast the function goes to zero, the smaller it
    % is the quicker it decays to zero.
    % 2*beta is the width of the window
    % t0 is the center of the window
    
    output = exp(-cosh((t-t0)/gamma)*exp(-(beta/gamma)));
  end
  
end

