function x = BFS(gp, domain, noPoints)
%BFS Breadth-first search type of thing
%   Detailed explanation goes here

  problem.lb = domain.min;
  problem.ub = domain.max;
  problem.solver = 'fmincon';
  problem.options = optimoptions('fmincon', ...
    'GradObj', 'on', 'MaxIter', 100, 'Display', 'none');
  problem.objective = @(x) gp.oneStepLookahead(x);

  x = zeros(noPoints, gp.noFeatures);
  noFound = 0;
  
  xTrainSet = gp.getTrainSet;
  
  for i = 1:1000
    problem.x0 = util.randbox(domain, 1);
    xTemp = fmincon(problem);
    
    if (min(util.sq_dist(xTrainSet', xTemp')) > 1e-3)
      noFound = noFound + 1;
      x(noFound, :) = xTemp;
      disp(num2str(noFound));
    end
    
    if (noFound >= noPoints)
      break
    end
  end

  % I'm not so happy with the next line, it basically means two testing
  % points cannot be closer that 0.01
%   xTemp = unique(floor(xTemp * 100) / 100);

%   costTemp = gp.oneStepLookahead(x);
%   [~,idx] = sort(costTemp);
%   x = x(idx(1:noPoints), :);
  
end