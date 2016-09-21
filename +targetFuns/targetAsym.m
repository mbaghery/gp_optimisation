function output = targetAsym(A0_1, omega1, FWHM1, A0_2, omega2, FWHM2, phasediff)
%PATCHKOVSKII Runs SCID TDSE and returns the (north - south)
%   Detailed explanation goes here

  phase1 = 0;
  phase2 = phase1 + phasediff;

  nradial = 5000;
  dt = 0.01;
  dr = 0.4;
  timesteps = 5 * max(FWHM1, FWHM2) / dt;

  
  % create the input file
  fileSuffix = sprintf('_%.3f_%.2f_%d_%.3f_%.2f_%d_%.2fpi', ...
    A0_1, omega1, FWHM1, A0_2, omega2, FWHM2, phasediff / pi);
  
  ioPrefix = ['iofiles/hydrogen' fileSuffix];
  wfPrefix = ['wfn/wf' fileSuffix];
  
  inputFile = [ioPrefix '.inp'];
  outputFile = [ioPrefix '.out'];
  
  
  inputfilestream = {
    '&sph_tdse'
    'comment = "linear polarization, linear grid"'
    'verbose = 1,'
    'omp_num_threads  = 1,'
    sprintf('dt = %f,', dt)
    sprintf('timesteps = %d,', timesteps)
    'initial_wfn= ''atomic'','
    'initial_wfn_index= 0, 0, 1,'
    'sd_lmax = 6,'
    'sd_mmin = 0,'
    'sd_mmax = 0,'
    'sd_rgrid= ''uniform'','
    'sd_rgrid_zeta = 1.0,'
    sprintf('sd_rgrid_dr = %f,', dr)
    sprintf('sd_nradial = %d,', nradial)
    'field_unwrap  = .true.'
    'rotation_mode = ''auto'','
    'pot_name= ''hydrogenic'','
    'pot_param  = 1.0,'
    'task = ''real time'','
    'cap_name= ''none'','
    'pt_mix_solver = ''default'','
    'bicg_epsilon  = 0'
    'skip_tests = .T.'
    'output_each= 20,'
    'composition_threshold  = 1e-10,'
    'initial_wf_dump_prefix = '' '','
    'field_preview = '' '','
    'detail_output = '' '','
    'vp_shape= ''z 2QHOStates'','
    'vp_param(11:20)  = 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,'
    'vp_param_x(11:20)= 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,'
    sprintf('vp_scale = %f,', A0_1);
    sprintf('vp_scale_x = %f,', A0_2);
    sprintf('vp_param(1:4) = %f, %f, %f, %f', omega1, phase1, timesteps*dt/2, FWHM1);
    sprintf('vp_param_x(1:4) = %f, %f, %f, %f', omega2, phase2, timesteps*dt/2, FWHM2);
    ['wt_atomic_cache_prefix = ''/data2/finite/mbaghery/SCID_', ...
        num2str(nradial), '_', num2str(dr, '%.1f'), '/cache/H'',']
    ['final_wf_dump_prefix = ''' wfPrefix ''',\n']
    '/'};

  
  f = fopen(inputFile, 'w');
  fprintf(f, '%s', strjoin(inputfilestream, '\n'));
  fclose(f);

  
  % 'ulimit -s umlimited; ' ...
  system(['./spherical_tdse.x < ' inputFile ' > ' outputFile ' 2>&1']);
  
  params = targetFuns.extractParams(outputFile);
  
  wf = targetFuns.extractWF(wfPrefix, params);
  wf = targetFuns.truncateoffBound(wf, params);
  
  [north, south] = targetFuns.hemispheres(wf);
  output = real(north - south);
  
end

