function C = extractSpec(weights)
%   The output is a 3D matrix, whose 3rd dimension is determined by maxL.
%   The size of the first dimension is determined by noGridpoints.
%   The second dimension consists of:
%       Re[E],Im[E],Re[Wgt],Im[Wgt],Re[<I|W>],Im[<I|W>],Re[<W|I>],Im[<W|I>]


  A = importdata(['iofiles/hydrogen_qho' genPrefix(weights) '.out'], '\n');
  A = char(A);
  
  
  for i = 1:size(A,1)
    isfound = strfind(A(i,:), 'SD_NRADIAL');

    if (~isempty(isfound))
      temptext = A(i,:);
      temptext(strfind(temptext, '=')) = ' ';
      a = textscan(temptext, '%s %f');
      noGridPoints = a{2};
      
      break;
    end
  end
  
  
  
  
  for i = 1:size(A,1)
    isfound = strfind(A(i,:), 'SD_LMAX');

    if (~isempty(isfound))
      temptext = A(i,:);
      temptext(strfind(temptext, '=')) = ' ';
      a = textscan(temptext, '%s %d');
      maxL = a{2};
      
      break;
    end
  end
  
  

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



  C = zeros(noGridPoints, 8, maxL + 1);

  for i = 0:maxL
    C(B(B(:, 1) == i, 3), :, i + 1) = B(B(:, 1) == i, 4:end);
  end

end
