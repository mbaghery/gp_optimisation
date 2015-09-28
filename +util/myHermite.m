function output = myHermite(r, n)
%MYHERMITE Summary of this function goes here
%   r is a column vector representing the points at which the value of the
%   Hermite polynomial is needed. n is the order of the Hermite polynomial.
%   The output is a matrix whose columns are Hermite polynomials
%   corresponding to the row vector n. n could be a scalar as well as a
%   row vector. n runs from 0.

  N = max(n)+1;
  
  H=zeros(N);
  
  H(1,1)=1; % H_0
  
  if (N>1)
    H(2,2)=2; % H_1
  end
  
  for i=3:N
    H(:,i)=[0; 2*H(1:end-1,i-1)]-2*(i-2)*H(:,i-2);
  end
  
  R = [ones(size(r)), bsxfun(@power, r, 1:N-1)];
  
  output= R * H(:, n + 1);
end

