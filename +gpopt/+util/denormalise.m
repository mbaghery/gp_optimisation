function Y = denormalise(Y, range)
%NORMALISE Rescales Y back to original assuming they were between 0 and -10

  normFactor = 10 ./ (range.max - range.min);
  
  Y = bsxfun(@plus, bsxfun(@rdivide, Y, normFactor), range.min);

end


