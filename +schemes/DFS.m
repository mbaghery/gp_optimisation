function x = DFS(noPoints, gp, problem, randFun)
%DFS Depth-first search type of thing
%   Detailed explanation goes here


  [~, Y] = gp.getTrainSet;
  eta = min(Y);
  clear Y;

  problem.objective = @(x) evaluate(x);
  problem.x0 = randFun(1, gp.noFeatures);

  x = zeros(noPoints, gp.noFeatures);
  x(1,:) = fmincon(problem);

  if (noPoints == 1)
    return;
  end
  
  
  gpclone = gp.copy;
  
  for i=2:noPoints
    y = gpclone.predict(x(i-1,:));

    gpclone.addTrainPoints(x(i-1,:), y);
    % Symmetry
    gpclone.addTrainPoints(-x(i-1,:), y);

    gpclone.initialise;

    x(i,:) = schemes.DFS(1, gpclone, problem, randFun);
  end
  
  
  function [f, df] = evaluate(xs)
    [m, s, dm, ds] = gp.predict(xs);
    
    f = 1/2 * (m + eta - sqrt(2/pi)*s.*exp(-(m-eta).^2./(2*s.^2)) ...
      + (eta-m).*erf((m-eta)./(sqrt(2)*s)));

    df = -1/2 * bsxfun(@times, dm, erf((m-eta)./(sqrt(2)*s))-1) ...
      - bsxfun(@times, ds, exp(-(eta - m).^2./(2*s.^2))/sqrt(2*pi));
  end
  
end

