function plotAll(outputFile)

  params = targetFuns.extractParams(outputFile);
  
  [path, ~, ~] = fileparts(outputFile);
  
  observables = targetFuns.extractObser(outputFile);
  
%   delta = 0;
%   gamma = 0;
%   
%   
%   
%   
%   
%   phase_es = observables(:,8) - observables(1,8) + ... % phase(t) - phase(t=0)
%     (-0.125) * observables(:,1); % deduct (energy of es) * time
%   phase_es = unwrap(phase_es);
%   
%   sigma = params.FWHM / (2 * sqrt(2 * log(2)));
% 
%   t0 = observables(end,1)/2;
%   J = @(t) sigma * sqrt(pi) / 2 * (1 + erf((t - t0) / sigma));
%   a = @(gamma, t) exp(-gamma * J(t));
%   p = @(delta, t) -delta * J(t);
% 
%   fit_a = fittype(a, 'coefficients', {'gamma'}, 'independent', {'t'});
%   fit_p = fittype(p, 'coefficients', {'delta'}, 'independent', {'t'});
% 
%   fitobject_a = fit(observables(:,1), observables(:,7), fit_a,'StartPoint', -0.01);
%   fitobject_p = fit(observables(:,1), phase_es,fit_p, 'StartPoint', -0.01);
% 
%   delta = fitobject_p.delta;
%   gamma = fitobject_a.gamma;
% 
% 
% 
% 
% 
% 
% %   J = @(t0,t) sigma * sqrt(pi) / 2 * (1 + erf((t - t0) / sigma));
% %   a = @(gamma,t0, t) exp(-gamma * J(t0,t));
% %   fit_a = fittype(a, 'coefficients', {'gamma','t0'}, 'independent', {'t'});
% %   fitobject_a = fit(observables(:,1),observables(:,5),fit_a,'StartPoint',[-0.01,0]);
% %   gamma = fitobject_a.gamma;
% %   t0 = fitobject_a.t0;
%   
% 
%   
%   targetFuns.plotObser(observables, params, delta, gamma);
%   
% %   hold on
% %   plot(observables(:,1), a(gamma, t0, observables(:,1)));
%   
%   export_fig([path '/Obser.pdf'], '-transparent', '-nocrop');
%   close all;
%   
%   
%   
%   
%   
%   
%   spec = targetFuns.extractSpec(outputFile);
%   disp(['electron yield: ', num2str(targetFuns.elecYield(spec))]);
%   targetFuns.plotPES(spec, params, delta, gamma);
%   
% %   hold on
% %   [e,s] = targetFuns.ansatzSpec(params,delta,gamma);
% %   de = diff(e);
% %   de(end+1) = de(end);
% %   plot(e,s./de/10);
% %   ylim([1,1000])
% %   xlim([0.4,0.8])
%   
%   export_fig([path '/PES.pdf'], '-transparent', '-nocrop');
%   close all;
%   
  
  
  
  [dipoledot_fft, omega] = targetFuns.hhgSpectrum(observables, params);
  targetFuns.plotHHGSpec(dipoledot_fft, omega, observables, params);
%   export_fig([path '/hhg.pdf'], '-transparent'); %, '-nocrop'
%   close all;
  
  
  
  return
  
  
  % this line is only valid for wavefunction files not from matlab
  % optimisation algorithm, otherwise I should add the weights to the file
  % name.
  wf = targetFuns.extractWF([path '/wfn/wf_0.435_0.90_80_0.375_0.45_80_0.03'], params);
  wf = targetFuns.truncateoffBound(wf, params);
  [n,s] = targetFuns.hemispheres(wf);
  real(n-s)
  targetFuns.plotPAD(wf);
  export_fig([path '/PAD.pdf'], '-transparent');
  close all;
  
end

