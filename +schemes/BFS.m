function x = BFS(gp, domain, noPoints)
%BFS Breadth-first search type of thing
%   Detailed explanation goes here

  noTries = noPoints * 5;

  problem.lb = domain.min;
  problem.ub = domain.max;
  problem.solver = 'fmincon';
  problem.options = optimoptions('fmincon', ...
    'GradObj', 'on', 'MaxIter', 100, 'Display', 'none');
  problem.objective = @(x) gp.oneStepLookahead(x);

  xTemp = zeros(noTries, gp.noFeatures);
  
  for i = 1:noTries
    problem.x0 = util.randbox(domain, 1);
    xTemp(i,:) = fmincon(problem);
  end

  % I'm not so happy with the next line, it basically means two testing
  % points cannot be closer that 0.01
%   xTemp = unique(floor(xTemp * 100) / 100);

  costTemp = gp.oneStepLookahead(xTemp);
  [~,idx] = sort(costTemp);
  x = xTemp(idx(1:noPoints), :);
  
end
