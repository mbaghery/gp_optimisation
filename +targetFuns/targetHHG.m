function output = targetHHG(weights)
%TARGETHHG Summary of this function goes here
%   Detailed explanation goes here

  fileSuffix = [num2str(weights(:)', '_%+.3f') '_' num2str(labindex)];

  ioPrefix = ['iofiles/hydrogen', fileSuffix];
  wfPrefix = ['wfn/wf', fileSuffix];
  
  inputFile = [ioPrefix, '.inp'];
  outputFile = [ioPrefix, '.out'];

  weightsZeroPadded = zeros(10,1);
  weightsZeroPadded(1:length(weights)) = weights(1:end);

  dt = 0.01;
  timesteps = 5*FWHM/dt;
  
  inputfilestream = {
    '&sph_tdse'
    'comment = "linear polarization, linear grid"'
    'verbose = 1,'
    'omp_num_threads = 1,'
    'initial_wfn = ''atomic'','
    'initial_wfn_index = 0, 0, 1,'
    'sd_lmax = 6,'
    'sd_mmin = 0,'
    'sd_mmax = 0,'
    'sd_nradial = 5000,'
    'sd_rgrid = ''uniform'','
    'sd_rgrid_dr = 0.40,'
    'sd_rgrid_zeta = 1.0,'
    'field_unwrap = .true.'
    'rotation_mode = ''auto'','
    'pot_name = ''hydrogenic'','
    'pot_param = 1.0,'
    'task = ''real time'','
    sprintf('dt = %f,', dt)
    sprintf('timesteps = %d,', timesteps)
    'vp_shape= ''z QHOStates'','
    sprintf('vp_scale = %f,', A0)
    sprintf('vp_param(1:4) = %f, %f, %f, %f', omega, 0, timesteps*dt/2, FWHM)
    ['vp_param(11:20) = ', sprintf('%f, ', weightsZeroPadded)]
    'cap_name = ''none'','
    'pt_mix_solver = ''default'','
    'bicg_epsilon = 0'
    'skip_tests = .T.'
    'output_each = 20,'
    'composition_threshold = 1e-10,'
    'initial_wf_dump_prefix = '' '','
    'field_preview = '' '','
    'wt_atomic_cache_prefix = ''/data2/finite/mbaghery/SCID_5000_0.4/cache/H'','
    'detail_output = '' '','
    ['final_wf_dump_prefix = ''' wfPrefix ''',\n']
    '/'};
  

  f = fopen(inputFile, 'w');
  fprintf(f, '%s', strjoin(inputfilestream, '\n'));
  fclose(f);


%   copyfile('hydrogen_qho.inp', inputFile);
%   f = fopen(inputFile, 'a');
% 
%   fprintf(f, ['final_wf_dump_prefix = ''' wfPrefix ''',\n']);  
%   fprintf(f, 'vp_param(11:20) = ');
%   fprintf(f, '%.6f, ', weightsZeroPadded);
%   fprintf(f, '\n /\n');
%   
%   fclose(f);
  

  % 'ulimit -s umlimited; ' ...
  system(['./spherical_tdse.x < ' inputFile ' > ' outputFile ' 2>&1']);
  
  
  % 1st column: time
  % 4th column: dipole
  observables = targetFuns.extractObser(outputFile);
  [dipoledot_fft, omega] = targetFuns.hhgSpectrum(observables);
  
end

