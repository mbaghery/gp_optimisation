function components = randsphere(m, n)
%RANDSPHERE Generate m random numbers uniformly distributed on an
%n-dimensional sphere of radius 1
%   The output is the components of a vector whose tip is on an
%   n-dimensional sphere; the output consists of m rows each of which
%   has n-dimensions.

% reference: W. P. Petersen, A. Bernasconi, Uniform sampling from an
% n-sphere, Swiss Center for Scientific Computing, ETH Zentrum, CH8092,
% Zürich, 10-July, 1997

   
  components = randn(m, n);
  
  components = bsxfun(@rdivide, components, sqrt(sum(components.^2,2)));

end
