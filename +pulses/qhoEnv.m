function pulse = qhoEnv(t, E0, omega, T, coeffs)
%QHOENV Describe a laser pulse using QHO, my own version
%   coeffs is a row vector. t could be a column vector or a scalar.

  time=t*(2*sqrt(2*log(2))/T); % Why 2*sqrt(2*log(2)) ? Explanation below.
  N = length(coeffs);
  
  prefactors= [
    1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
    0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
    -2,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0;
    0,-12,0,8,0,0,0,0,0,0,0,0,0,0,0,0;
    12,0,-48,0,16,0,0,0,0,0,0,0,0,0,0,0;
    0,120,0,-160,0,32,0,0,0,0,0,0,0,0,0,0;
    -120,0,720,0,-480,0,64,0,0,0,0,0,0,0,0,0;
    0,-1680,0,3360,0,-1344,0,128,0,0,0,0,0,0,0,0;
    1680,0,-13440,0,13440,0,-3584,0,256,0,0,0,0,0,0,0;
    0,30240,0,-80640,0,48384,0,-9216,0,512,0,0,0,0,0,0;
    -30240,0,302400,0,-403200,0,161280,0,-23040,0,1024,0,0,0,0,0;
    0,-665280,0,2217600,0,-1774080,0,506880,0,-56320,0,2048,0,0,0,0;
    665280,0,-7983360,0,13305600,0,-7096320,0,1520640,0,-135168,0,4096,0,0,0;
    0,17297280,0,-69189120,0,69189120,0,-26357760,0,4392960,0,-319488,0,8192,0,0;
    -17297280,0,242161920,0,-484323840,0,322882560,0,-92252160,0,12300288,0,-745472,0,16384,0;
    0,-518918400,0,2421619200,0,-2905943040,0,1383782400,0,-307507200,0,33546240,0,-1720320,0,32768];

  temp = bsxfun(@times, bsxfun(@power, time, 0:N-1),...
    (coeffs ./ sqrt(2.^(0:N-1) .* factorial(0:N-1))) * prefactors(1:N,1:N));

  pulse = E0 * exp(-time.^2/2) .* ...
    ( sum(temp(:,1:2:end),2) .* sin(omega*t) + ...
      sum(temp(:,2:2:end),2) .* cos(omega*t) ); % Why no 1/pi^(1/4) ? Explanation below.
    
    
  % Explanation:
  % T means FWHM.
  % T and E0 are defined based on the zeroth term, i.e. coeffs=[1], in
  % which case the envelope is simply a gaussian:
  %  (exp(-z^2/2)/pi^(1/4))^2 = exp(-z^2)/pi^(1/2)
  % In order for E0 to represent the true amplitude, the maximum of the
  % gaussian should be one. The maximum occurs at t=0 and has value
  % 1/pi^(1/4). Therefore, E0 is multiplied by pi^(1/4) to compensate for
  % that factor.
  % The relation between the sigma of a gaussian distribution and FWHM is
  %  FWHM = 2*sqrt(2*log(2))*sigma
  % Sigma for coeffs=[1] is 1, therefore FWHM is
  %  FWHM = 2*sqrt(2*log(2))*1 = 2*sqrt(2*log(2))
  % Thus, in order for the envelope to have FWHM T, t should be multiplied
  % by 2*sqrt(2*log(2))/T
end

