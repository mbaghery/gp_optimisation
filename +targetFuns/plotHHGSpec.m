function plotHHGSpec(dipoledot_fft, omega, observables, params)
%PLOTHHGSPEC Summary of this function goes here
%   Detailed explanation goes here

  A0 = max(abs(observables(:,2)));
  U_pond = A0^2 / 4;
  e_cutoff = 0.5 + 3.17 * U_pond;

  y_lim = [1e-20,1];
  
  y_axis = abs(dipoledot_fft).^2;
  
  
  s = 1;
  y_axis2 = unwrap(angle(dipoledot_fft));
  
  
  y_axis = y_axis(1:s:end);
  y_axis2 = y_axis2(1:s:end);
  x_axis = omega(1:s:end);


  h1 = subplot(2,1,1);
  semilogy(x_axis, y_axis, [e_cutoff, e_cutoff], y_lim);
  omega_max = 60;
  omega_step = 4;
  xlim([0,omega_max] * params.omega);
  ylim(y_lim);
  h1.XTick = (0:omega_step:omega_max) * params.omega;
  minorTickValues = 0:omega_max;
  minorTickValues(1:omega_step:end) = [];
  h1.XAxis.MinorTickValues = minorTickValues * params.omega;
  h1.XTickLabel = num2cell(0:omega_step:omega_max);
  h1.XMinorTick = 'on';
  h1.XMinorGrid = 'on';
  xlabel('harmonic order');
  ylabel('|D_v(\omega)|^2');
  grid on
  
  yyaxis right
  plot(x_axis, y_axis2);
  ylabel('\phi(\omega)');
  
  titlebar = targetFuns.createtitle(params);
  title(titlebar);
  
  h2 = subplot(2,1,2);
  semilogy(x_axis, y_axis, [e_cutoff, e_cutoff], y_lim);
  omega_max = 150;
  omega_step = 12;
  omega_minorstep = 4;
  xlim([0,omega_max] * params.omega);
  ylim(y_lim);
  h2.XTick = (0:omega_step:omega_max) * params.omega;
  minorTickValues = 0:omega_minorstep:omega_max;
  minorTickValues(1:(omega_step/omega_minorstep):end) = [];
  h2.XAxis.MinorTickValues = minorTickValues * params.omega;
  h2.XTickLabel = num2cell(0:omega_step:omega_max);
  h2.XMinorTick = 'on';
  h2.XMinorGrid = 'on';
  xlabel('harmonic order');
  ylabel('|D_v(\omega)|^2');
  grid on
  
  yyaxis right
  plot(x_axis, y_axis2);
  ylabel('\phi(\omega)');

end

