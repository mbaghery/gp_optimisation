X = util.unisphrand(trainSetSize, noFeatures);

laserFuns=cell(trainSetSize,1);
for i = 1:trainSetSize
  laserFuns{i} = @(t) ...
    pulses.qhoEnv(t - propParams.duration / 2, ...
    laserParams.amplitude, laserParams.omega, ...
    laserParams.FWHM, X(i,:));
end

spmd
  DistributedY=zeros(trainSetSize/noWorkers,1);
  
  for i=1:trainSetSize/noWorkers
    disp(['loop no. ' num2str(i)]);
    
    tdseinstance.setWavefunction(initState);
    
    tdseinstance.propagate(laserFuns{(labindex-1)*trainSetSize/noWorkers+i});
    DistributedY(i) = tdseinstance.getCharge;
  end
end

Y = cell2mat(DistributedY(:));

save(filename, 'X', 'Y', 'noFeatures');
