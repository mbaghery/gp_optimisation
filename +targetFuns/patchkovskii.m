function output = patchkovskii(weights)
%PATCHKOVSKII Runs SCID TDSE and returns the desired output
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
  
  params = targetFuns.extractParams(outputFile);
  
  output = 1 - targetFuns.elecYield(targetFuns.extractSpec(outputFile, params));

%   [north, south] = targetFuns.hemispheres(targetFuns.extractWF(wfPrefix, params));
%   output = real(north - south);
  
end

