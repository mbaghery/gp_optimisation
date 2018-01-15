function Y = normalise(Y, range)
%NORMALISE Rescales Y so that all the elements are between 0, 10

  normFactor = 10 ./ (range.max - range.min);
  
  Y = bsxfun(@times, bsxfun(@minus, Y, range.min), normFactor);

end

