function V = smoothCoulomb(r, Q, alpha)
%SMOOTHCOULOMB smoothed Coulomb potential
%      smootheCoulomb(r, Q, alpha)
%   r is a column vector of the points at which the value of the potential
%   funciton is needed. Q is the charge of the nucleus, and alpha is the
%   smoothing parameter.
%
%      V = -Q./sqrt(r.^2 + alpha^2);
%
%   Default:
%      Q = 1;
%      alpha = 1;
%   This potential has 5 bound state.

  if (nargin < 2)
    Q = 1;
    alpha = 1;
  end

  V = -Q./sqrt(r.^2 + alpha^2);

end
