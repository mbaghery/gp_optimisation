function Y = normalise(Y, range, noShift)
%NORMALISE Rescales Y so that all the elements are between -5 and 5
%   if noShift is true, then the mean of Y is not shifted to zero, it is
%   merely multiplied by a constant to rescale the range to 10.


  if (nargin == 2)
    noShift = false;
  end

  normFactor = 10 / (range.max - range.min);
  
  if (noShift)
    Y = Y * normFactor;
  else
    Y = (Y - (range.max + range.min) / 2) * normFactor;
  end
  
end

