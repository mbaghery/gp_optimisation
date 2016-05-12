function ionization = patchkovskii(weights)
%PATCHKOVSKII Runs SCID TDSE and returns the ionization of hydrogen
%   Detailed explanation goes here

  setSCID(weights);
  
  [a,b]=system([ ... % 'ulimit -s umlimited; ' ...
    './spherical_tdse.x < iofiles/hydrogen_qho' genPrefix(weights) '.inp' ...
    ' >  iofiles/hydrogen_qho' genPrefix(weights) '.out 2>&1']);
  
  C = extractSpec(weights);
  
  normalizingFactor = sum(sum(C(:,3,:), 1), 3);
  ionization = 0;
  for i=1:size(C,3)
    ionization = ionization + sum(C(C(:,1,i) > 0, 3, i), 1);
  end
  
  ionization = ionization / normalizingFactor;
end

