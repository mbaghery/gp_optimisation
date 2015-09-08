function [c, ceq] = nonlincon(x)
%NONLINCON non-linear constraint
%   x can be vertical or horizontal. 

  % set the non-linear inequalities
  c=0;
  
  % set the non-linear equalities
  ceq=norm(x)-1;

end

