function output = targetHHG(weights)
%TARGETHHG Summary of this function goes here
%   Detailed explanation goes here

  fileSuffix = [num2str(weights(:)', '_%+.3f') '_' num2str(labindex)];

  ioPrefix = ['iofiles/hydrogen_qho' fileSuffix];
  wfPrefix = ['wfn/wf' fileSuffix];
  
  inputFile = [ioPrefix '.inp'];
  outputFile = [ioPrefix '.out'];

  weightsZeroPadded = zeros(10,1);
  weightsZeroPadded(1:length(weights)) = weights(1:end);
  
  copyfile('hydrogen_qho.inp', inputFile);
  f = fopen(inputFile, 'a');

  fprintf(f, ['final_wf_dump_prefix = ''' wfPrefix ''',\n']);  
  fprintf(f, 'vp_param(11:20) = ');
  fprintf(f, '%.6f, ', weightsZeroPadded);
  fprintf(f, '\n /\n');
  
  fclose(f);
  
  % 'ulimit -s umlimited; ' ...
  system(['./spherical_tdse.x < ' inputFile ' > ' outputFile ' 2>&1']);
  
  
  % 1st column: time
  % 4th column: dipole
  observables = targetFuns.extractObser(outputFile);
  
  targetFuns.hhgSpectrum(observables);
end

