function [north, south] = hemispheres(wf)
%NORTHHEMISPHERE Calculates the ionization into the northern hemisphere
%   The output can be complex due to right and left wavefunctions, but the
%   real part is to be taken seriously. In other words, if the complex part
%   is too big, it means the simulation parameters have not been chosen
%   accurately, e.g. too big dr, too big dt, etc.
%   wf: 1st and 2nd dimensions:
%           R, Re[left wfn], Im[left wfn], Re[right wfn], Im[right wfn]
%       3rd dimension: l
  
  lmax = size(wf, 3) - 1;
  
  ylmIntegralsNorth = importdata('+targetFuns/ylmIntegralsNorth.dat');
  ylmIntegralsSouth = eye(size(ylmIntegralsNorth)) - ylmIntegralsNorth; %importdata('+targetFuns/ylmIntegralsSouth.dat');
  
  north = 0;
  south = 0;
  
  
  for l1 = 0:lmax
    for l2 = 0:lmax
      R_sum = sum(complex(wf(:,2,l1+1), wf(:,3,l1+1)) ...
         .* complex(wf(:,4,l2+1), wf(:,5,l2+1)));
       
      north = north + ylmIntegralsNorth(l1+1,l2+1) * R_sum;
       
      south = south + ylmIntegralsSouth(l1+1,l2+1) * R_sum;
    end
  end

end

