function output = targetStark(intensity2, FWHM2)
%TARGETSTARK Run SCID TDSE and return (delta1-delta2)^2+(sigma1-sigma2)^2
%   Detailed explanation goes here

  intensity1 = 3e15;
  omega1 = 0.9;
  FWHM1 = 3 * 41.34*2*sqrt(log(2));
  phase1 = 0;

  omega2 = 0.3;
%   FWHM2 = sigma2*(2*sqrt(2*log(2)));
  phase2 = 0;

  f1 = @(int) sqrt(int/3.51e16)/omega1;
  f2 = @(int) sqrt(int/3.51e16)/omega2;

  A0_1 = f1(intensity1);
  A0_2 = f2(intensity2);

  nradial = 5000;
  dt = 0.005;
  dr = 0.4;
  timesteps = 3 * max(FWHM1, FWHM2) / dt;

  phasediff = (phase2 - phase1) / pi;

  
  
  % create the input file
  fileSuffix = sprintf('_%.3f_%.3f_%.3f_%.3f_%.3f_%.3f_%.3f', ...
    A0_1, omega1, FWHM1, A0_2, omega2, FWHM2, phasediff);
  
  ioPrefix = ['iofiles/hydrogen' fileSuffix];
  wfPrefix = ['wfn/wf' fileSuffix];
  
  inputFile = [ioPrefix '.inp'];
  outputFile = [ioPrefix '.out'];
  
  copyfile('hydrogen2ColorHeader.inp', inputFile);

  f = fopen(inputFile, 'a');

  fprintf(f, 'sd_nradial = %d,\n', nradial);
  fprintf(f, 'sd_rgrid_dr = %f,\n', dr);
  fprintf(f, 'dt = %f,\n', dt);
  fprintf(f, 'timesteps = %d,\n', timesteps);
  fprintf(f, 'wt_atomic_cache_prefix = ''/data2/finite/mbaghery/SCID_%d_%.1f/cache/H'',\n', nradial, dr);
  fprintf(f, ['final_wf_dump_prefix = ''' wfPrefix ''',\n']); 
  fprintf(f, 'vp_scale = %f,\n', A0_1);
  fprintf(f, 'vp_scale_x = %f,\n', A0_2);
  fprintf(f, 'vp_param(1:4) = %f, %f, %f, %f\n', omega1, phase1, timesteps*dt/2, FWHM1);
  fprintf(f, 'vp_param_x(1:4) = %f, %f, %f, %f\n', omega2, phase2, timesteps*dt/2, FWHM2);
  fprintf(f, ' /\n');

  fclose(f);

  
  % 'ulimit -s umlimited; ' ...
  system(['./spherical_tdse.x < ' inputFile ' > ' outputFile ' 2>&1']);
  
  
  
  
  
  observables = targetFuns.extractObser(outputFile);
  
  phase = observables(:,6) - observables(1,6) + ... % phase(t) - phase(t=0)
    observables(1,3) * observables(:,1); % deduct (energy of gs) * time
  phase = unwrap(phase);
  
  J = @(delta1, delta2, sigma1, sigma2, t) ...
      delta1 * sigma1 * sqrt(pi) / 2 * (1 + erf(t / sigma1)) ...
    - delta2 * sigma2 * sqrt(pi) / 2 * (1 + erf(t / sigma2));
  
  myfit = fittype(J, ...
    'coefficients', {'delta1', 'delta2', 'sigma1', 'sigma2'}, ...
    'independent', {'t'});
  
  fitobject = fit(observables(:,1) - observables(end,1)/2, phase, ...
    myfit, 'StartPoint', [10,10,80,80]);
  
  
%   J = @(c, t) ...
%       c(1) * c(3) * sqrt(pi) / 2 * (1 + erf(t / c(3))) ...
%     - c(2) * c(4) * sqrt(pi) / 2 * (1 + erf(t / c(4)));
%   
%   fitobject = lsqcurvefit(J, [10,10,80,80], ...
%     observables(:,1) - observables(end,1)/2, phase);
% 
%   sigma1 = fitobject(1);
%   sigma2 = fitobject(2);
%   delta1 = fitobject(3);
%   delta2 = fitobject(4);

  
  
%   output = (fitobject.sigma1*2*sqrt(2*log(2)) -...
%             fitobject.sigma2*2*sqrt(2*log(2)))^2 / fitobject.sigma1*2*sqrt(2*log(2))^2 ...
%     + (fitobject.delta1 - fitobject.delta2)^2 / fitobject.delta1^2;
    
%   output = (fitobject.sigma1 *2*sqrt(2*log(2)) -...
%             fitobject.sigma2 *2*sqrt(2*log(2)))^2 ...
%     + (fitobject.delta1 - fitobject.delta2)^2;


  sigma1 = fitobject.sigma1;
  sigma2 = fitobject.sigma2;
  delta1 = fitobject.delta1;
  delta2 = fitobject.delta2;
  
  
  % minimise the integral of the stark shift over time
%   output = sqrt(pi/2)*(delta1^2*sigma1 + delta2^2*sigma2) ...
%     - (2*sqrt(pi)*delta1*delta2*sigma1*sigma2)/sqrt(sigma1^2 + sigma2^2);
  
  
  criterion1 = (delta2-delta1)^2;
  criterion2 = delta2^2*((sigma1/sigma2)^2-1)^2 ...
    * (delta2/delta1*(sigma1/sigma2)^2)^(-2/(1-(sigma2/sigma1)^2));
  
  % minimise the maximum stark shift during the simulation
  if (sigma1>sigma2 && delta2/delta1*(sigma1/sigma2)^2>1) || ...
     (sigma1<sigma2 && delta2/delta1*(sigma1/sigma2)^2<1)
    output = max(criterion1, criterion2);
  else
    output = criterion1;
  end
  
  
  % minimise the integral of the phase over time
%   T = 1000;
%   
%   output = 1/2*pi*(T*(delta1*sigma1-delta2*sigma2)^2 ...
%     +T*delta1^2*sigma1^2*erf(T/sigma1)^2 ...
%     -sqrt(2/pi)*delta1^2*sigma1^3*erf((sqrt(2)*T)/sigma1) ...
%     +2*delta1*sigma1*erf(T/sigma1)*((exp(-(T^2/sigma1^2))*delta1*sigma1^2 ...
%     -exp(-(T^2/sigma2^2))*delta2*sigma2^2)/sqrt(pi) ...
%     -T*delta2*sigma2*erf(T/sigma2))+ ...
%     delta2*sigma2*((2*(-exp(-(T^2/sigma1^2))*delta1*sigma1^2+ ...
%     exp(-(T^2/sigma2^2))*delta2*sigma2^2)*erf(T/sigma2))/sqrt(pi)+ ...
%     T*delta2*sigma2*erf(T/sigma2)^2+ ...
%     (-sqrt(2)*delta2*sigma2^2*erf((sqrt(2)*T)/sigma2)+ ...
%     2*delta1*sigma1*sqrt(sigma1^2+sigma2^2)*erf((T*sqrt(sigma1^2+sigma2^2))/(sigma1*sigma2)))/sqrt(pi)));
  
end

