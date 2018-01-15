function output = randcylin(m, domain, k)
%RANDCYLIN Generate m random numbers uniformly distributed on cylinder
%   Of the dimensions of the cylinder, the first l=length(domain.max) are in a
%   box, and k are on a sphere of radius 1. Therefore, points are in a
%   l+k dimensional space.
%   domain only determines the limits of the first l elements.
%   The output is the components of a vector whose tip is on a cylinder.
%   The output consists of m rows each of which is a random point.

  box = gpopt.util.randbox(m, domain);
  sph = gpopt.util.randsphere(m, k);
  
  output = [box, sph];

end
