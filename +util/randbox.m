function output = randbox(domain, n)
%RANDBOX Generates random numbers within a box defined by domain
%   Detailed explanation goes here

  output = bsxfun(@plus, ...
    bsxfun(@times, rand(n, length(domain.max)), (domain.max - domain.min)) ...
    , domain.min);

end
