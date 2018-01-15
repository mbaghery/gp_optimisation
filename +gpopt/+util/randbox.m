function output = randbox(m, domain)
%RANDBOX Generates m random numbers within a box defined by domain
%   Detailed explanation goes here

  output = bsxfun(@plus, ...
    bsxfun(@times, rand(m, length(domain.max)), ...
    (domain.max - domain.min)), domain.min);

end
