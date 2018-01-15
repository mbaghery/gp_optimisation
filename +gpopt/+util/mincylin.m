function [x, f] = mincylin(objective, x0, n, options)
%CYLIMISE Minimise on a cylinder; hence the name (cyl + imise)
%   It finds the minimum of a given function, assuming that the first n
%   variables are in a box of length 10 in all dimensions (from 0 to 10), See
%   util.normalise for further details, while the rest are on a sphere of
%   radius one at all times.
%   'objective' is a function handle that returns two variables, f and df.
%   'x0' is the starting point of the algorithm, which is a ROW vector.
%   The algorithm used is called "monotonous Gradient descent with stepsize
%   adaptation". See the pdf file under the same directory.


  if (nargin < 4)
    options = optimoptions('fminunc', ...
      'Algorithm','quasi-newton', ...
      'MaxFunctionEvaluations', 1000, ...
      'MaxIterations', 300, ...
      'StepTolerance', 1e-6, ...
      'FunctionTolerance', 1e-6);
  end


  x_old = x0;
  [f_old, df_old] = feval(objective, x0);

  
  gamma = 1;
  
  for i = 1: options.MaxIter
        
    % monotonous Gradient descent with stepsize adaptation
    x = x_old - gamma * df_old / norm(df_old);
        
    % the first n variables stay within the box 0..10
    x(x(1:n) > 10) = 10;
    x(x(1:n) < 0) = 0;
    
    % the rest of the variables stay on a sphere
    x(n+1:end) = x(n+1:end) / norm(x(n+1:end));
    
    
    [f, df] = feval(objective, x);

    if (f < f_old)
      delta_x = norm(x - x_old);
      delta_f = abs(f - f_old);

      if (delta_x < options.StepTolerance || delta_f < options.FunctionTolerance)
        break;
      end
      
      
      % old values:
      x_old = x;
      f_old = f;
      df_old = df;
      
      gamma = gamma * 1.2;    
    else
      gamma = 0.5 * gamma;
    end
    
  end

end
