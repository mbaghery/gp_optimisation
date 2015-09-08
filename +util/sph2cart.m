function output = sph2cart(input)
%SPH2CART Spherical with radius 1 to Cartesian
%   input is a column vector, and so is output.

  n=length(input);
	
  if (n==1)
    output=[cos(input(1)); sin(input(1))];
  else
    output=[cos(input(1)); sin(input(1)) * util.sph2cart(input(2:end))];
  end
  
end

