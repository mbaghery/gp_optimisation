function x = australia(noPoints, gp, problem, randFun, bias)
%AUSTRALIA arXiv:1507.04964 method from Australia
%   Detailed explanation goes here

  if (nargin == 4)
    % bias defined so that B = bias*mean-(1-bias)*sigma
    bias = linspace(0.5, 1, noPoints);
  end

  x = zeros(noPoints, gp.noFeatures);

  for i=1:noPoints
    problem.objective = @(x) evaluate(x, bias(i)); % Objective function
    problem.x0 = randFun(1, gp.noFeatures); % initial guess    
    
    x(i,:) = fmincon(problem);
  end
  
  function [f, df] = evaluate(xs, b)
    % return b*mean-(1-b)*sigma and its derivative
    % xs is a row vector
    
    [m, s, dm, ds] = gp.predict(xs);
    
    % for now I assume that the mean function ranges from -5 to 5, and
    % the variance ranges from 0 to exp(hyp.cov(end)). Therefore, in
    % order to normalise them, I have divided the first terms on RHS of
    % the following equations by 10, and have divided the second terms
    % by exp(hyp.cov(end)).
    f = b*m/10 - (1-b)*s/exp(gp.hyp.cov(end));
    df = b*dm/10 - (1-b)*ds/exp(gp.hyp.cov(end));
  end
end

