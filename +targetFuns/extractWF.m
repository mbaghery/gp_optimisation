function wf = extractWF(wfPrefix, params)
%EXTRACTWF Reads the wavefunction files and combines them into a 3d matrix
%   nradial and lmax are optional
%   wfPrefix may be relative or absolute
%   wf: 1st and 2nd dimensions:
%           R, Re[left wfn], Im[left wfn], Re[right wfn], Im[right wfn]
%       3rd dimension: l

  if (nargin < 3)
    params.lmax = -1;

    while 1
      if exist([wfPrefix '-L' num2str(params.lmax + 1,'%03d') '-M+0000'], 'file')
        params.lmax = params.lmax + 1;
      else
        break;
      end
    end
    
    tmp = importdata([wfPrefix '-L000-M+0000'], ' ', 1);
    
    params.nradial = size(tmp.data, 1);
    
  end


  % second dimension has five elements because:
  %   R, Re[left wfn], Im[left wfn], Re[right wfn], Im[right wfn]
  wf = zeros(params.nradial, 5, params.lmax + 1);
  
  
  for l = 0:params.lmax
    tmp = importdata([wfPrefix '-L' num2str(l,'%03d') '-M+0000'], ' ', 1);
    
    wf(:,:,l+1) = tmp.data(:,2:end);
  end
  
end

