function [x, fval] = sphimise(objective, x0, options)
%SPHIMISER Minimise on a sphere; hence the name (sph + imise)
%   It finds the minimum of a given function, assuming that the point
%   should stay on a sphere of radius one at all times.
%   'objective' is a function handle that returns two variables, f and df.
%   'x0' is the starting point of the algorithm, which is a ROW vector.


  if (nargin < 3)
    options = optimoptions('fminunc', ...
      'MaxFunEvals', 1000, ...
      'MaxIter', 300, ...
      'TolX', 1e-6, ...
      'TolFun', 1e-6, ...
      'GradObj', 'on', ...
      'Algorithm','quasi-newton', ...
      'HessUpdate', 'steepdesc', ...
      'Display', 'off');
%     options.MaxFunctionEvaluations = 1000;
%     options.MaxIterations = 300;
%     options.StepTolerance = 1e-6;  % x tolerance
%     options.FunctionTolerance = 1e-6; % function tolerance
  end
  
  options2 = options;
  options2.MaxIter = 1;

  x_old = x0;
  [fval_old, dfval_old] = feval(objective, x0);
  
  delta = 1;

  for i = 1: options.MaxIter    
    x = x_old - delta * dfval_old;

    x = x / norm(x); % because it has to lie on a sphere of radius 1
    
    [fval, dfval] = feval(objective, x);

    
%     merit = norm(dfval - (x * dfval') * x);
%     
%     if (merit < options.TolFun)
%       break;
%     end
    
    
    delta_x = norm(x - x_old);
    delta_fval = abs(fval - fval_old);
    
    if (delta_x < options.TolX || delta_fval < options.TolFun)
      break;
    end

    x_old = x;
    fval_old = fval;
    dfval_old = dfval;
  end

end

