function plotPES(spectrum, params, delta, gamma)
%   spectrum is the output of extractSpec

  for i = 0:params.lmax
    plot(spectrum(:,1,i + 1), spectrum(:,3,i + 1), '-', 'LineWidth', 1.5);
    hold on;
  end

  set(gcf, 'Position', [300 300 600 400]);
  set(gca, 'YScale', 'Log');
  grid on;
  xlim([-0.5, 2]);
  ylim([1e-6,1]);


  % tau is taken from the paper by Demekhin & Cederbaum
  if (strcmp(params.pulseshape, 'z QHOStates'))
    titlebar = sprintf(['A_0 = %.3f, \\omega = %.2f, FWHM = %.0f\n' ...
      'I = %.2e W/cm^2, \\omega = %.2f eV, \\tau = %.2f fs' ...
      ], ... %'\n\\Delta = %.5f, \\Gamma = %.5f'], ...
      params.A0, params.omega, params.FWHM, ...
      (params.A0 * params.omega)^2 * 3.51 * 1e16, params.omega/0.03674, params.FWHM/(2*sqrt(log(2))) / 41.34 ...
      ); %, delta, gamma);
  elseif (strcmp(params.pulseshape, 'z 2QHOStates'))
    titlebar = sprintf(['A_0 = %.3f, \\omega = %.2f, FWHM = %.0f, A_0'' = %.3f, \\omega'' = %.2f, FWHM'' = %.0f\n' ...
      'I = %.2e W/cm^2, \\omega = %.2f eV, \\tau = %.2f fs\n' ...
      'I'' = %.2e W/cm^2, \\omega'' = %.2f eV, \\tau'' = %.2f fs' ...
      ], ... %'\n\\Delta = %.5f, \\Gamma = %.5f'], ...
      params.A0, params.omega, params.FWHM, params.A0_x, params.omega_x, params.FWHM_x, ...
      (params.A0 * params.omega)^2 * 3.51 * 1e16, params.omega/0.03674, params.FWHM/(2*sqrt(log(2))) / 41.34, ...
      (params.A0_x * params.omega_x)^2 * 3.51 * 1e16, params.omega_x/0.03674, params.FWHM_x/(2*sqrt(log(2))) / 41.34 ...
      ); %, delta, gamma
  end
  
  title(titlebar);
  xlabel('Energy [a.u.]');
  
  legend(num2cell(num2str((0:params.lmax)')), 'location', 'eastoutside');
  
end
