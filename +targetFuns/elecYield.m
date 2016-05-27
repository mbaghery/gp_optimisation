function ionization = elecYield(spectrum)
%ELECYIELD Calculate the amount of ionized electron
%   spectrum is the output of extractSpec.
  
  normalizingFactor = sum(sum(spectrum(:,3,:), 1), 3);
  
  lmax = size(spectrum, 3) - 1;
  
  ionization = 0;
  for l = 0:lmax
    ionization = ionization + sum(spectrum(spectrum(:,1,l+1) > 0, 3, l+1), 1);
  end
  
  ionization = ionization / normalizingFactor;

end

