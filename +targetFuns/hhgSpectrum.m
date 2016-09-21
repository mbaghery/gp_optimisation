function [dipoledot_fft, omega] = hhgSpectrum(observables, params)
%HHGSPECTRUM Summary of this function goes here
%   Detailed explanation goes here

  dipole = observables(:,4);
  time = observables(:,1);
  
  dt = (time(2)-time(1));
  
  
  
  %%%%%%%%%%%%%%%%
  padding = -(params.simlength - 2*params.midlaser):dt:-dt;
  time = [padding'; time];
  
  dipole = [dipole(1) * ones(length(padding), 1); dipole];
  %%%%%%%%%%%%%%%%
  
  
  N = length(time);
  
  T = time(end) - time(1);
  
  dipoledot = sptoeplitz([0, -1, zeros(1, length(dipole)-2)], ...
                         [0,  1, zeros(1, length(dipole)-2)]) * dipole / (2*dt);
  dipoledot(end)=0;
  
  % my own
%   mymask = mask(time, T/2, 0.85*T/2, 100);
  
  % sigmoid
%   dipoledot = dipoledot .* mask(time, T/2, 1700, 50);

  % one-sided gaussian
%   mymask = mask(time, T/2, 0.70*T/2, 100);
  
  % gaussian
  mymask = mask(time, params.midlaser, 0, 1.5*params.FWHM);

  dipoledot = dipoledot .* mymask;
  
  
  % pad with zeros
  M = 2^nextpow2(8*N);
  delta_omega = 2*pi/(M*dt);
  

  omega = delta_omega * (0:M/2)';
  
  dipoledot_fft = fft(dipoledot, M) * dt / (2*pi);

  % assuming real values
  dipoledot_fft(M/2+2:end) = [];
  dipoledot_fft(2:end-1) = 2*dipoledot_fft(2:end-1);
  
  
  mymask_fft = fft(mymask, M) * dt / (2*pi);
  mymask_fft(M/2+2:end) = [];
  mymask_fft(2:end-1) = 2*mymask_fft(2:end-1);
  
%   dipole_fft = fft(dipole, M) * dt / (2*pi);
%   dipole_fft(M/2+2:end) = [];
%   dipole_fft(2:end-1) = 2*dipole_fft(2:end-1);
  
%   dipole_fft =  dipole_fft .* (1i * omega) ; % + exp(-1i*omega*T)*dipole(end);
  
  
  function output = mask(t, t0, beta, gamma)
    % gamma determines how fast the function goes to zero, the smaller it
    % is the quicker it decays to zero.
    % 2*beta is the width of the window
    % t0 is the center of the window
    
    if (nargin<4)
      t0 = 0;
      beta = 10;
      gamma = 1;
    end
    
    % my own mask
%     output = exp(-cosh((t-t0)/gamma)*exp(-(beta/gamma)));
    
    % sigmoid mask
%     s = @(t) 1./(1+exp(-t));
%     output = s((t-t0+beta)/gamma) - s((t-t0-beta)/gamma);

    % one-sided gaussian mask
%     g = @(t) exp(-t.^2);
%     output(t < t0+beta) = 1;
%     output(t >= t0+beta) = g((t(t >= t0+beta)-t0-beta)/gamma);
%     output=output';
    
    % gaussian
    g = @(t) exp(-t.^2);
    output = g((t-t0)/gamma);
    
  end
  
end
