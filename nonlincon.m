function [c, ceq] = nonlincon(x)
%NONLINCON non-linear constraint
%   x can be vertical or horizontal. 

  % set the non-linear inequalities
  c = abs(norm(x)-1) - 1e-6;
  
  % set the non-linear equalities
  ceq = 0;

end

