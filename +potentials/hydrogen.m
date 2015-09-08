function V = hydrogen(r)
%HYDROGEN hydrogen potential
%   ground state energy = 0.5 = 13.6eV (hydrogen)
%   This potential has 5 bound state.

  V = -1./sqrt(r.^2+1.4143^2);

end

