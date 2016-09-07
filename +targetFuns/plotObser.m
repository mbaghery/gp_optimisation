function plotObser(observables, params, delta, gamma)

  phase_gs = observables(:,6) - observables(1,6) + ... % phase(t) - phase(t=0)
    (-0.5) * observables(:,1); % deduct (energy of gs) * time
  phase_gs = unwrap(phase_gs);
  
  
  phase_es = observables(:,8) - observables(1,8) + ... % phase(t) - phase(t=0)
    (-0.125) * observables(:,1); % deduct (energy of es) * time
  phase_es = unwrap(phase_es);
  
  
%   continuumphase = - 0.5 * params.dt * cumsum(observables(:,2).^2);
%   
%   
% plot(observables(:,1),phase,observables(:,1),continuumphase,observables(:,1),continuumphase-phase)
% grid on
% xlim([0,observables(end,1)])
% legend('phase(gs)', 'phase(con)', 'diff', 'Location', 'southwest')
% xlabel('Time [a.u.]')
% % ylim([-0.6,0.6])
% export_fig('phase.pdf', '-transparent');
%   
%   
%   phase = continuumphase - phase;
  
  
  % QUATSCH:
  % in Patchkowskii package the A(t)^2 term is also included, here I deduct
  % this term as this phase has no physical consequence. What matters here
  % is the energy difference between ground state and the continuum state.
  % Since both of these two terms have this phase added to their phase, the
  % difference shouldn't contain it.
%   patchphase = 0.5 * params.dt * cumsum(observables(:,2).^2);
%   phase = phase + patchphase;

  
%   sigma = FWHM/(2*sqrt(2*log(2)));
  
  % I just checked whether the phase I get from Patchkovski is correct, it
  % is indeed correct and accurate. Mehrdad, 28.4.2016
%   A=A0*exp(-(B(:,1)-simulationLength/2).^2./sigma^2/2);
%   A2=A0_2*exp(-(B(:,1)-simulationLength/2).^2./sigma^2/2);
%   
%   myvec = A + A2;
%   patchvec = B(:,2);
%   
%   myphase = 0.25 * cumsum(A.^2 + A2.^2);

  
  
%   J = @(t) sigma * sqrt(pi)/2 * (1 + erf((t-observables(end,1)/2)/sigma));
%   a = @(gamma, t) exp(-gamma * J(t));
%   p = @(delta, t) -delta * J(t);
% 
%   fit_a = fittype(a, 'coefficients', {'gamma'}, 'independent', {'t'});
%   fit_p = fittype(p, 'coefficients', {'delta'}, 'independent', {'t'});
% 
%   fitobject_a = fit(observables(:,1),observables(:,5),fit_a,'StartPoint',-0.01);
%   fitobject_p = fit(observables(:,1),phase,fit_p,'StartPoint',-0.01);
%   
%   delta = fitobject_p.delta;
%   gamma = fitobject_a.gamma;

  
  
  
  % A(t)
  plot(observables(:,1), observables(:,2), '-', 'LineWidth', 1);
  hold on;
  
%   % dipole operator
%   plot(observables(:,1), observables(:,4), '-', 'LineWidth', 1);
  
  % population of ground state
  plot(observables(:,1), observables(:,5), '-', 'LineWidth', 1);
  
  % population of 2p-state
  plot(observables(:,1), observables(:,7), '-', 'LineWidth', 1);
  
  % energy
  plot(observables(:,1), observables(:,3), '-', 'LineWidth', 1);
  
  ylim([-2,2]);
  
  yyaxis right

  % ground-state phase
  plot(observables(:,1), phase_gs, '-b', 'LineWidth', 1);
  
  % 2p-state phase
  plot(observables(:,1), phase_es, '-r', 'LineWidth', 1);
  
  
%   plot(observables(1:end-1,1), -diff(phase)/params.dt, ...
%     '-', 'LineWidth', 1, 'Color', [0.4660    0.6740    0.1880]);  

  
%   ylim([-0.1,0.1]);
%   ylim([-pi,pi]);
%   ax = gca;
%   ax.YTick = [-pi, 0, pi];
%   ax.YTickLabel = {'-\pi','0','\pi'};



%   plot(observables(:,1), fitobject_p(observables(:,1)));
%   plot(observables(:,1), fitobject_a(observables(:,1)));


  legend('A(t)', '|gs|^2', '|2p|^2', 'Energy', 'phase(gs)',  'phase(2p)', ...
    'Location', 'eastoutside');
  

  set(gcf, 'Position', [300 300 600 400]);
  grid on;
  xlim([0, params.simLength]);
%   ylim([-8,8]);

  
  % tau is taken from the paper by Demekhin & Cederbaum
  if (strcmp(params.pulseshape, 'z QHOStates'))
    titlebar = sprintf(['A_0 = %.3f, \\omega = %.3f, FWHM = %.0f\n' ...
      'I = %.2e W/cm^2, \\omega = %.2f eV, \\tau = %.2f fs' ...
      ], ... %'\n\\Delta = %.5f, \\Gamma = %.5f'], ...
      params.A0, params.omega, params.FWHM, ...
      (params.A0 * params.omega)^2 * 3.51 * 1e16, params.omega/0.03674, params.FWHM/(2*sqrt(log(2))) / 41.34 ...
      ); %, delta, gamma);
  elseif (strcmp(params.pulseshape, 'z 2QHOStates'))
    titlebar = sprintf(['A_0 = %.3f, \\omega = %.3f, FWHM = %.0f, A_0'' = %.3f, \\omega'' = %.2f, FWHM'' = %.0f\n' ...
      'I = %.2e W/cm^2, \\omega = %.2f eV, \\tau = %.2f fs\n' ...
      'I'' = %.2e W/cm^2, \\omega'' = %.2f eV, \\tau'' = %.2f fs' ...
      ], ... %'\n\\Delta = %.5f, \\Gamma = %.5f'], ...
      params.A0, params.omega, params.FWHM, params.A0_x, params.omega_x, params.FWHM_x, ...
      (params.A0 * params.omega)^2 * 3.51 * 1e16, params.omega/0.03674, params.FWHM/(2*sqrt(log(2))) / 41.34, ...
      (params.A0_x * params.omega_x)^2 * 3.51 * 1e16, params.omega_x/0.03674, params.FWHM_x/(2*sqrt(log(2))) / 41.34 ...
      ); %, delta, gamma);
  end

  
  title(titlebar);
  
  xlabel('Time [a.u.]');
  
end
