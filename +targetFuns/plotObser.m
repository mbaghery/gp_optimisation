function plotObser(observables, params, delta, gamma)



%   A = importdata(observables, '\n');
%   A = char(A);
%   
%   A0 = 0;
%   omega = 0;
%   FWHM = 0;
%   
%   A0_2 = 0;
%   omega2 = 0;
%   FWHM2 = 0;
%   
%   
%   
%   for i = 1:size(A,1)
%     isfound = strfind(A(i,:), 'VP_SHAPE ');
% 
%     if (~isempty(isfound))
%       temptext = A(i,:);
%       temptext(strfind(temptext, '=')) = ' ';
%       temptext = strtrim(temptext);
%       temptext(1:8) = '';
%       vp_shape = strtrim(temptext);
%       
%       break;
%     end
%   end
%   
%   
%   for i = 1:size(A,1)
%     isfound = strfind(A(i,:), 'VP_SCALE ');
% 
%     if (~isempty(isfound))
%       temptext = A(i,:);
%       temptext(strfind(temptext, '=')) = ' ';
%       a = textscan(temptext, '%s %f');
%       A0 = a{2};
%       
%       break;
%     end
%   end
%   
%   
%   for i = 1:size(A,1)
%     isfound = strfind(A(i,:), 'VP_PARAM ');
% 
%     if (~isempty(isfound))
%       temptext = A(i,:);
%       temptext(strfind(temptext, '=')) = ' ';
%       temptext(strfind(temptext, ',')) = ' ';
%       a = textscan(temptext, '%s %f %f %f %f');
%       omega = a{2};
%       FWHM = a{5};
%       simulationLength = a{4} * 2; % because the center of the pulse is in the middle
%       
%       break;
%     end
%   end
%   
%   
%   if (strcmp(vp_shape, 'z 2QHOStates'))
%     
%     for i = 1:size(A,1)
%       isfound = strfind(A(i,:), 'VP_SCALE_X');
% 
%       if (~isempty(isfound))
%         temptext = A(i,:);
%         temptext(strfind(temptext, '=')) = ' ';
%         a = textscan(temptext, '%s %f');
%         A0_2 = a{2};
% 
%         break;
%       end
%     end
% 
% 
%     for i = 1:size(A,1)
%       isfound = strfind(A(i,:), 'VP_PARAM_X');
% 
%       if (~isempty(isfound))
%         temptext = A(i,:);
%         temptext(strfind(temptext, '=')) = ' ';
%         temptext(strfind(temptext, ',')) = ' ';
%         a = textscan(temptext, '%s %f %f %f %f');
%         omega2 = a{2};
%         FWHM2 = a{5};
% 
%         break;
%       end
%     end
%   
%   end
%   
%   
%   for i = 1:size(A,1)
%     isfound = strfind(A(i,:), 'DT');
% 
%     if (~isempty(isfound))
%       temptext = A(i,:);
%       temptext(strfind(temptext, '=')) = ' ';
%       a = textscan(temptext, '%s %f');
%       dt = a{2};
%       
%       break;
%     end
%   end
  

%   A(A(:,1) ~= '@',:) = [];
%   
%   % time, vector potential, energy, dipole, gs population, phase(gs), es population, phase(es)
%   B=zeros(size(A,1),6);
%   formatSpec = '%s%f%s%f%s%f%s%f%s%f%s%f%f%s%f%f%s%f%s%f%s%f%s%f%s%f';
% 
%   for i=1:size(A,1)
%     temp = textscan(A(i,:), formatSpec);
%     B(i,:) = [temp{4}, temp{6}, temp{15}, temp{18}, temp{20}, temp{22}];
%   end


  phase = observables(:,6) - observables(1,6) + ... % phase - phase@time=0
    observables(1,3) * observables(:,1); % deduct (energy of gs) * time
  phase = unwrap(phase);
  
  
  patchphase = 0.5 * params.dt * cumsum(observables(:,2).^2);
  phase = phase + patchphase;

  
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

  
  
  
  

  h1 = plot(observables(:,1), observables(:,3), '-', 'LineWidth', 1);
  hold on;
  plot(observables(:,1), observables(:,2), '-', 'LineWidth', 1);
  plot(observables(:,1), observables(:,4), '-', 'LineWidth', 1);
  plot(observables(:,1), observables(:,5), '-', 'LineWidth', 1);
  plot(observables(:,1), phase, '-', 'LineWidth', 1);



%   plot(observables(:,1), fitobject_p(observables(:,1)));
%   plot(observables(:,1), fitobject_a(observables(:,1)));


  legend('Energy', 'A(t)', '|d(t)|', '|gs|^2', 'phase(gs)', ...
    'Location', 'eastoutside');

  uistack(h1, 'top');
  

  set(gcf, 'Position', [300 300 600 400]);
  grid on;
  xlim([0, params.simLength]);
%   ylim([-8,8]);

  
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
      ); %, delta, gamma);
  end

  
  title(titlebar);
  
  xlabel('Time [a.u.]');
  
end
