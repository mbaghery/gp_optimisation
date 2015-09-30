function x = tradeoff(noPoints, gp, problem, randFun)
%AUXMYVER2 Trade-off between DFS and BFS
%   Detailed explanation goes here

  x = zeros(noPoints, gp.noFeatures);
  x(1,:) = schemes.DFS(1, gp, problem, randFun);

  if (noPoints == 1)
    return;
  end

  [mu, sigma] = gp.predict(x(1,:));
  
  for j=1:3
    y = mu + (j-2) * sigma; % m-s, m, m+s
    
    gpclone = gp.copy;
    
    gpclone.addTrainPoints(x(1,:), y);
    % Symmetry
    gpclone.addTrainPoints(-x(1,:), y);
    
    gpclone.initialise;

    x(2+(j-1)*(noPoints-1)/3:1+j*(noPoints-1)/3,:) ...
      = schemes.tradeoff((noPoints-1)/3, gpclone, problem, randFun);
  end

end
