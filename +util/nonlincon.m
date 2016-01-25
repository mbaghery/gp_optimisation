function [c, ceq] = nonlincon(x)
%NONLINCON non-linear constraint: the point should stay on a sphere
%   x can be vertical or horizontal. (It's a row vector:
% I have done some tests, and it turns out x is always a row vector, even
% when MultiStart is used.)

  % set the non-linear inequalities
    % all the points should lie on a sphere of radius 1
    % used to be: c = abs(norm(x)-1) - 1e-6;
    % but now it is parallel
    c = abs(sum(x .* x, 2) - 1) - 1e-5;
  
  % set the non-linear equalities
  ceq = 0;

end

