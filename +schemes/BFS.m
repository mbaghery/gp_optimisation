function x = BFS(noPoints, gp, problem, randFun)
%BFS Breadth-first search type of thing
%   Detailed explanation goes here

  noInitPoints = noPoints * 5;

  problem.objective = @(x) gp.oneStepLookahead(x);

  xTemp = zeros(noInitPoints, gp.noFeatures);
  
  for i = 1:noInitPoints
    problem.x0 = randFun(1);
    xTemp(i,:) = fmincon(problem);
  end

  % I'm not so happy with the next line, it basically means two testing
  % points cannot be closer that 0.01
  xTemp = unique(floor(xTemp * 100) / 100);

  costTemp = gp.oneStepLookahead(xTemp);

  [~,idx] = sort(costTemp);

  x = xTemp(idx(1:noPoints));
  
end
