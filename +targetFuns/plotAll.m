function plotAll(outputFile)

  params = targetFuns.extractParams(outputFile);
  
  [path, ~, ~] = fileparts(outputFile);
  
  delta = 0;
  gamma = 0;
  
  targetFuns.plotObser(targetFuns.extractObser(outputFile), ...
    params, delta, gamma);
  export_fig([path '/Obser.pdf'], '-transparent');
  
  ylim([-2,2]);
  export_fig([path '/Obser2.pdf'], '-transparent');
  close all;
  
  
  targetFuns.plotPES(targetFuns.extractSpec(outputFile), ...
    params, delta, gamma);
  export_fig([path '/PES.pdf'], '-transparent');
%   return
  close all;
  
  
  % this line is only valid for wavefunction files not from matlab
  % optimisation algorithm, otherwise I should add the weights to the file
  % name.
  wf = targetFuns.extractWF([path '/wfn/wf'], params);
  wf = targetFuns.truncateoffBound(wf, params);
  [n,s] = targetFuns.hemispheres(wf);
  real(n-s)
  targetFuns.plotPAD(wf);
  export_fig([path '/PAD.pdf'], '-transparent');
  close all;
  
end

