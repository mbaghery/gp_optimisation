function filename = genPrefix(weights)
%GENFILENAME Generates the prefix for saving the final wavefunction
%   weights is a vector containing the weights

  filename = [num2str(weights(:)', '_%+.3f') '_' num2str(labindex)];

end

