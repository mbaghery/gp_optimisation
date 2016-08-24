function output = targetAsym(intensity1, phasediff)
%PATCHKOVSKII Runs SCID TDSE and returns the (north - south)
%   Detailed explanation goes here

  omega1 = 0.9;
  FWHM1 = 80;
  phase1 = 0;

  omega2 = omega1 / 2;
  intensity2 = 1e15;
  FWHM2 = 80;
  phase2 = phase1 + phasediff;

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
  fileSuffix = sprintf('_%.3f_%.2f_%d_%.3f_%.2f_%d_%.2f', ...
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
  
  params = targetFuns.extractParams(outputFile);
  
  wf = targetFuns.extractWF(wfPrefix, params);
  wf = targetFuns.truncateoffBound(wf, params);
  
  [north, south] = targetFuns.hemispheres(wf);
  output = real(north - south);
  
end

