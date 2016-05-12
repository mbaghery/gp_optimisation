function setSCID(weights)
%SETSCID Writes the weights in file "hydrogen_qho_....inp"
%   weights is a vector of at most 10 elements.

  weightsPadded = zeros(10,1);
  
  weightsPadded(1:length(weights)) = weights(1:end);
  
  copyfile('hydrogen_qho.inp', ['iofiles/hydrogen_qho' genPrefix(weights) '.inp']);
  
  f = fopen(['iofiles/hydrogen_qho' genPrefix(weights) '.inp'], 'a');

  fprintf(f, '   final_wf_dump_prefix   = ''wfn/wf');
  fprintf(f, genPrefix(weights));
  fprintf(f, ''',\n');
  
  fprintf(f, '   vp_param(11:20)        = ');
  fprintf(f, '%.6f, ', weightsPadded);
  fprintf(f, '\n /\n');
  
  fclose(f);
end
