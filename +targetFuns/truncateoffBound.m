function wf = truncateoffBound(wf, params)
%EXTRACTEF Truncates the bound part of the wavefunction
%   wf: 1st and 2nd dimensions:
%           R, Re[left wfn], Im[left wfn], Re[right wfn], Im[right wfn]
%       3rd dimension: l


  lmax = size(wf, 3) - 1;
  
  for l = 0:lmax

    f = fopen(['/data2/finite/mbaghery/SCID_' num2str(params.nradial) ...
      '_' num2str(params.dr) '/cache/H-L=' num2str(l,'%03d')]);

    % read the header that fortran puts at the beginning of files
    fread(f, 1, 'uint32');

    % read eigenvalues
    energies = fread(f, 2 * params.nradial, 'float64');
    % get rid of the imaginary part
    energies = energies(1:2:end);
    
    noBound = sum(energies < 0);
    
    lefteigenvector = complex(zeros(params.nradial, noBound));
    righteigenvector = complex(zeros(params.nradial, noBound));

    % read wf_l
    for i = 1:noBound
      temp = fread(f, 2 * params.nradial, 'float64');
      lefteigenvector(:,i) = complex(temp(1:2:end), temp(2:2:end));
    end
    
    % skip the rest of the states
    % float64 takes up 8 bytes
    fseek(f, (params.nradial - i) * 2 * params.nradial * 8, 'cof');
    
    % read wf_r: these start at nradial+1 all the way to EOF
    for i = 1:noBound
      temp = fread(f, 2 * params.nradial, 'float64');
      righteigenvector(:,i) = complex(temp(1:2:end), temp(2:2:end));
    end
    
    
    for i = 1:noBound
      overlap = sum(lefteigenvector(:,i) .* complex(wf(:, 4, l+1), wf(:, 5, l+1)));
      temp = overlap * righteigenvector(:,i);
      wf(:, 4, l+1) = wf(:, 4, l+1) - real(temp);
      wf(:, 5, l+1) = wf(:, 5, l+1) - imag(temp);
      
      overlap = sum(righteigenvector(:,i) .* complex(wf(:, 2, l+1), wf(:, 3, l+1)));
      temp = overlap * lefteigenvector(:,i);
      wf(:, 2, l+1) = wf(:, 2, l+1) - real(temp);
      wf(:, 3, l+1) = wf(:, 3, l+1) - imag(temp);
    end
    
    fclose(f);
    
  end

end

