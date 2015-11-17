function Y = denormalise(Y, range, noShift)
%NORMALISE Rescales Y so that all the elements are between Ymin and Ymax
%   if noShift is true, then the mean of Y is not shifted to normal, it is
%   merely multiplied by a constant to rescale the range to the original
%   value.

  if (nargin == 2)
    noShift = false;
  end

  normFactor = 10 / (range.max - range.min);
  
  if (noShift)
    Y = Y / normFactor;
  else
    Y = Y / normFactor + (range.max + range.min) / 2;
  end
  
end

