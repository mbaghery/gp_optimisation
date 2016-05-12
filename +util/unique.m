function [xNext, fval] = unique(objective, rand, noPoints, noFeatures)
%UNIQUE Returns noPoints unique local minima of objective
%   objective is the function we are interested in finding the minimum of.
%   rand is the random number generator function
%   noPoints indicates how many points we would like to have

  options.MaxIter = 100;
  options.noPhase1 = 20 * noPoints;
  
  xNext = zeros(noPoints, noFeatures);
  fval = zeros(noPoints, 1);

  
  %%%%% phase 1
  
  xNextPhase1 = zeros(options.noPhase1, noFeatures);
  fvalPhase1 = zeros(options.noPhase1, 1);
  
  startPoints = rand(options.noPhase1, noFeatures);

  for i = 1:options.noPhase1
    [xNextTemp, fvalTemp] = util.sphimise(objective, startPoints(i,:));
    
    xNextPhase1(i,:) = xNextTemp;
    fvalPhase1(i) = fvalTemp;
  end
  
  [~, order] = unique(round(fvalPhase1, 4)); % it is automatically sorted
  counter = length(order);
  
  if (counter >= noPoints)
    xNext = xNextPhase1(order(1:noPoints), :);
    fval = fvalPhase1(order(1:noPoints), :);
    
    return;
  else
    xNext(1:counter, :) = xNextPhase1(order(1:counter), :);
    fval(1:counter) = fvalPhase1(order(1:counter), :);
  end
  
  
  %%%%% phase 2

  for i = 1:options.MaxIter
    startPoint = rand(1, noFeatures);
    [xNextTemp, fvalTemp] = util.sphimise(objective, startPoint);
    
    if (ismember(round(xNextTemp,4), round(xNext(1:counter,:),4), 'rows') == 0)
      counter = counter + 1;
      
      xNext(counter,:) = xNextTemp;
      fval(counter) = fvalTemp;
      
      if (counter == noPoints)
        break
      end
      
    end
    
  end


  if (counter == noPoints)
    return;
  end
  
  
  %%%%% phase 3
  
  xNext(counter + 1:end,:) = xNext(counter, :);

end
