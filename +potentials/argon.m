function V = argon(r)
%ARGON argon potential
%   ground state energy = 0.5792 = 15.76eV (argon)
%   This potential has 5 bound state.

  V = -1./sqrt(r.^2+1.189^2);

end