function x = DFS(noPoints, gp, problem, randFun)
%DFS Depth-first search type of thing
%   Detailed explanation goes here


% xx=randFun(500,gp.noFeatures);
% cost=gp.oneStepLookahead(xx);
% [~,idx]=min(cost);
% x(1,:)=xx(idx);
% problem.x0 = xx(idx);
% 
%   problem.objective = @(x) gp.oneStepLookahead(x);
% %   problem.x0 = randFun(1, gp.noFeatures);
% 
%   x = zeros(noPoints, gp.noFeatures);
%   x(1,:) = fmincon(problem);




  if (noPoints == 1)
    return;
  end
  
  
  gpclone = gp.copy;
  
  for i=2:noPoints
    y = gpclone.predict(x(i-1,:));

    gpclone.addTrainPoints(x(i-1,:), y);
    % Symmetry
%     gpclone.addTrainPoints(-x(i-1,:), y);

    gpclone.initialise;

    x(i,:) = schemes.DFS(1, gpclone, problem, randFun);
  end
end

