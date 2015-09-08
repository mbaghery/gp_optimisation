function V = koudai(r)
%KOUDAI Koudai's weird potential
%   This is a potential function Koudai has used in his paper
%   New J. Phys. 17, 073005 (2015)
%   This potential has 1 bound state.

  a1 = 24.856;
  a2 = 0.16093; 
  a3 = 0.25225;
  V = -exp(-a1*sqrt((r/a1).^2+a2^2))./sqrt((r/a1).^2+a3^2);

end

