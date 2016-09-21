function params = extractParams(outputFile)
%EXTRACTPARAMS Summary of this function goes here
%   Detailed explanation goes here

% params is a struct with the following fields:
%    nradial, dr, lmax, pulseshape, A0, omega, FWHM, midlaser, ...
%    A0_x, omega_x, FWHM_x, midlaser_x, dt, timesteps, simlength

  A = importdata(outputFile, '\n');
  A = char(A);
  
  
  for i = 1:size(A,1)
    isfound = strfind(A(i,:), 'SD_NRADIAL');

    if (~isempty(isfound))
      temptext = A(i,:);
      temptext(strfind(temptext, '=')) = ' ';
      a = textscan(temptext, '%s %f');
      params.nradial = a{2};
      
      break;
    end
  end
  
  
  for i = 1:size(A,1)
    isfound = strfind(A(i,:), 'SD_RGRID_DR');

    if (~isempty(isfound))
      temptext = A(i,:);
      temptext(strfind(temptext, '=')) = ' ';
      a = textscan(temptext, '%s %f');
      params.dr = a{2};
      
      break;
    end
  end
  
  
  
  
  for i = 1:size(A,1)
    isfound = strfind(A(i,:), 'SD_LMAX');

    if (~isempty(isfound))
      temptext = A(i,:);
      temptext(strfind(temptext, '=')) = ' ';
      a = textscan(temptext, '%s %d');
      params.lmax = a{2};
      
      break;
    end
  end
  
  
  for i = 1:size(A,1)
    isfound = strfind(A(i,:), 'VP_SHAPE ');

    if (~isempty(isfound))
      temptext = A(i,:);
      temptext(strfind(temptext, '=')) = ' ';
      temptext = strtrim(temptext);
      temptext(1:8) = '';
      params.pulseshape = strtrim(temptext);
      
      break;
    end
  end
  
  
  for i = 1:size(A,1)
    isfound = strfind(A(i,:), 'VP_SCALE ');

    if (~isempty(isfound))
      temptext = A(i,:);
      temptext(strfind(temptext, '=')) = ' ';
      a = textscan(temptext, '%s %f');
      params.A0 = a{2};
      
      break;
    end
  end
  
  
  for i = 1:size(A,1)
    isfound = strfind(A(i,:), 'VP_PARAM ');

    if (~isempty(isfound))
      temptext = A(i,:);
      temptext(strfind(temptext, '=')) = ' ';
      temptext(strfind(temptext, ',')) = ' ';
      a = textscan(temptext, '%s %f %f %f %f');
      params.omega = a{2};
      params.midlaser = a{4};
      params.FWHM = a{5};
      
      break;
    end
  end
  
  
%   if (strcmp(vp_shape, 'z 2QHOStates'))
    
  for i = 1:size(A,1)
    isfound = strfind(A(i,:), 'VP_SCALE_X');

    if (~isempty(isfound))
      temptext = A(i,:);
      temptext(strfind(temptext, '=')) = ' ';
      a = textscan(temptext, '%s %f');
      params.A0_x = a{2};

      break;
    end
  end


  for i = 1:size(A,1)
    isfound = strfind(A(i,:), 'VP_PARAM_X');

    if (~isempty(isfound))
      temptext = A(i,:);
      temptext(strfind(temptext, '=')) = ' ';
      temptext(strfind(temptext, ',')) = ' ';
      a = textscan(temptext, '%s %f %f %f %f');
      params.omega_x = a{2};
      params.midlaser_x = a{4};
      params.FWHM_x = a{5};

      break;
    end
  end
  
%   end
  
  
  for i = 1:size(A,1)
    isfound = strfind(A(i,:), 'DT');

    if (~isempty(isfound))
      temptext = A(i,:);
      temptext(strfind(temptext, '=')) = ' ';
      a = textscan(temptext, '%s %f');
      params.dt = a{2};
      
      break;
    end
  end
  

  
  for i = 1:size(A,1)
    isfound = strfind(A(i,:), 'TIMESTEPS');

    if (~isempty(isfound))
      temptext = A(i,:);
      temptext(strfind(temptext, '=')) = ' ';
      a = textscan(temptext, '%s %f');
      params.timesteps = a{2};
      params.simlength = params.timesteps * params.dt;
      
      break;
    end
  end
  
end

