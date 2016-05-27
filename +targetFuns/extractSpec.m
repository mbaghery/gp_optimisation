function C = extractSpec(outputFile, params)
%   params is optional.
%   The output is a 3D matrix, whose 3rd dimension is determined by lmax.
%   The size of the first dimension is determined by nradial.
%   The second dimension consists of:
%       Re[E],Im[E],Re[Wgt],Im[Wgt],Re[<I|W>],Im[<I|W>],Re[<W|I>],Im[<W|I>]

  
  if (nargin < 2)
    params = targetFuns.extractParams(outputFile);
  end
  
  
  A = importdata(outputFile, '\n');
  A = char(A);
  

  for i = 1:size(A,1)
    isfound = strfind(A(i,:), 'Large amplitudes of individual field-free states');

    if (~isempty(isfound))
      A(1:i+3,:) = [];
      break;
    end
  end


  B = zeros(size(A,1),11);
  formatSpec = '%f%f%f%f%f%f%f%f%f%f%f';

  for j = 1:size(A,1)
    if (isempty(strtrim(A(j,:))))
      B(j:end, :) = [];
      break;
    end

    B(j,:) = cell2mat(textscan(A(j,:), formatSpec));
  end



  C = zeros(params.nradial, 8, params.lmax + 1);

  for i = 0:params.lmax
    C(B(B(:, 1) == i, 3), :, i + 1) = B(B(:, 1) == i, 4:end);
  end

end
