function output = auxMyVer2(iMax, gp)
%AUXMYVER2 An ausiliary function for my 2nd version scheme
%   Detailed explanation goes here

	% Start
  % make sure the new point is on a sphere
problem.nonlcon=@nonlincon;

problem.solver = 'fmincon';
problem.options = optimoptions('fmincon', ...
  'GradObj', 'on', 'MaxIter', 200, 'Display', 'none');

problem.objective = @(x) gp.evalMe(x);
problem.x0 = util.unisphrand(1, gp.noFeatures);
x = fmincon(problem);

  % End

  if (iMax==1)
    output=x;
    return;
  end

  [m,s]=gp.predict(x);
  
  xs=cell(3,1);
  
  for j=1:3
    gpclone=gp.copy;
    y = m + (j-2)*s; % m-s, m, m+s
    
    gpclone.addTrainPoints(x,y);
    % Symmetry
    gpclone.addTrainPoints(-x, y);
    gpclone.initialise;
    
    xs{j}=auxMyVer2(iMax-1, gpclone);
  end
  
  output=[x; cell2mat(xs)];

end

