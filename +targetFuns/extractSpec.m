function C = extractSpec(outputFile, params)
%   params is optional.
%   The output is a 3D matrix, whose 3rd dimension is determined by lmax.
%   The size of the first dimension is determined by nradial.
%   The second dimension consists of:
%       Re[E],Im[E],Re[Wgt],Im[Wgt],Re[<I|W>],Im[<I|W>],Re[<W|I>],Im[<W|I>]

  
  if (nargin < 2)
    params = targetFuns.extractParams(outputFile);
  end
  
  
  % in R2016a apparently it skips empty lines and doesn't import them
  A = importdata(outputFile, '\n');
  A = char(A);
  

  for i = 1:size(A,1)
    isfound = strfind(A(i,:), 'Large amplitudes of individual field-free states');

    if (~isempty(isfound))
      % in R2016a it should be i+2 but in previous version it was i+3
      A(1:i+2,:) = [];
      break;
    end
  end


  B = zeros(size(A,1),11);
  formatSpec = '%f%f%f%f%f%f%f%f%f%f%f';

  for j = 1:size(A,1)
    if (isempty(cell2mat(textscan(A(j,:), formatSpec))))
      B(j:end, :) = [];
      break;
    end

    B(j,:) = cell2mat(textscan(A(j,:), formatSpec));
  end



  C = zeros(params.nradial, 8, params.lmax + 1);

  for i = 0:params.lmax
    C(B(B(:, 1) == i, 3), 3:end, i + 1) = B(B(:, 1) == i, 6:end);
  end
  
  % The states that don't have population don't appear in Patchkowskii's
  % spectrum written in the output file. Therefore, I should add the
  % missing energies manually from the eigenvalue eigenvector files stored
  % on /data2/finite/mbaghery/SCID_****_***
  
  for l = 0:params.lmax

    f = fopen(['/data2/finite/mbaghery/SCID_' num2str(params.nradial) ...
      '_' num2str(params.dr) '/cache/H-L=' num2str(l,'%03d')]);

    % read the header that fortran puts at the beginning of files
    fread(f, 1, 'uint32');

    % read eigenvalues
    energies = fread(f, 2 * params.nradial, 'float64');
    % get rid of the imaginary part
    energiesRe = energies(1:2:end);
    energiesIm = energies(2:2:end);
    
    C(:,1,l+1) = energiesRe;
    C(:,2,l+1) = energiesIm;
    
    fclose(f);
  end

end
