function V = neon(r)
%NEON neon potential
%   ground state energy = 0.7925 = 21.56eV (neon)
%   This potential has 5 bound state.

  V = -1./sqrt(r.^2+0.816^2);

end
