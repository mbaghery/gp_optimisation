function Y = normalise(Y, range)
%NORMALISE Rescales Y so that all the elements are between -5 and 5

  normFactor = 10 ./ (range.max - range.min);
  
  Y = bsxfun(@times, ...
    bsxfun(@minus, Y, (range.max + range.min) / 2), normFactor);
  
end

