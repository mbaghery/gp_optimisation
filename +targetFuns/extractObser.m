function observables = extractObser(outputFile)
%EXTRACTOBSER Summary of this function goes here
%   observables is a 2d matrix:
%     time, vector potential, energy, dipole, gs population, phase(gs), es population, phase(es)

  A = importdata(outputFile, '\n');
  A = char(A);
  
  A(A(:,1) ~= '@',:) = [];
  
  % time, vector potential, energy, dipole, gs population, phase(gs), es population, phase(es)
  observables = zeros(size(A,1),8);
  formatSpec = '%s%f%s%f%s%f%s%f%s%f%s%f%f%s%f%f%s%f%s%f%s%f%s%f%s%f';

  for i=1:size(A,1)
    temp = textscan(A(i,:), formatSpec);
    observables(i,:) = [temp{4}, temp{6}, temp{15}, temp{18}, ...
      temp{20}, temp{22}, temp{24}, temp{26}];
  end

end

