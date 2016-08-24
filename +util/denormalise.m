function Y = denormalise(Y, range)
%NORMALISE Rescales Y so that all the elements are between Ymin and Ymax

  normFactor = 10 ./ (range.max - range.min);
  
  Y = bsxfun(@plus, ...
    bsxfun(@rdivide, Y, normFactor), (range.max + range.min) / 2);
  
end


