function plotHHGSpec(dipoledot_fft, omega)
%PLOTHHGSPEC Summary of this function goes here
%   Detailed explanation goes here

%   subplot(2,1,1)
  semilogy(omega, abs(dipoledot_fft).^2);
  ylim([1e-30,1]);
  xlabel('\omega [a.u.]');
  grid on
  
%   subplot(2,1,2)
%   plot(time, dipoledot);
% %   ylim([-1,1]);
%   xlim([0,T]);
%   xlabel('time [a.u.]');
%   grid on

end

