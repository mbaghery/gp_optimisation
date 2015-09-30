function Y = normalise(Y, Ymin, Ymax, noShift)
%NORMALISE Rescales Y so that all the elements are between -5 and 5
%   if noShift is true, then the mean of Y is not shifted to zero, it is
%   merely multiplied by a constant to rescale the range to 10.

  if (nargin == 3)
    noShift = false;
  end

  normFactor = 10/(Ymax-Ymin);
  
  if (noShift)
    Y = Y * normFactor;
  else
    Y = (Y - (Ymax+Ymin)/2) * normFactor;
  end
  
end

