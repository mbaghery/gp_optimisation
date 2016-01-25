%clear all; clc;

noWorkers = 16;
trainSetSize = 3 * noWorkers;

parpool('hubert', noWorkers);

noLoops = 6;
%noFeatures = 6; % set in job file

filename = 'qporp_1_1.mat';

% set the approximate Y range
range.min = -5;
range.max = 5;

% set the hypercube limits
domain.min = -1 * ones(1, noFeatures);
domain.max = 1 * ones(1, noFeatures);

% the goal function
f = @mex.target;

% random number generator
r = @util.unisphrand;


%% Build the training set
disp('Build the training set');

% X = r(trainSetSize, noFeatures);

spmd
  % Dist is short for 'Distributed among all nodes'
  DistY = zeros(trainSetSize / noWorkers, 1);
  DistX = r(trainSetSize / noWorkers, noFeatures);
  
  for i = 1:trainSetSize/noWorkers
    disp(['loop no. ' num2str(i)]);
    % DistributedY(i) = f(X((labindex - 1) * trainSetSize / noWorkers + i,:));
    DistY(i) = f(X(i,:));
  end
end

X = cell2mat(DistX(:));
Y = cell2mat(DistY(:));

save(filename, 'X', 'Y', 'noFeatures');

%% Set up the gp instnace
disp('Set up the gp');

% normalization
Y = util.normalise(Y, range);

gpinstance = classgp(X, Y);

sn = util.normalise(0.01, range, true);
gpinstance.uncertainty = log(sn);

gpinstance.mean = {@meanFuns.meanZero};
gpinstance.meanD = {@meanDFuns.meanZeroD};

gpinstance.cov = {@covFuns.covSEard};
gpinstance.covD = {@covDFuns.covSEardD};

% mean function hyperparameters
hyp.mean=[];

% covariance function hyperparameters
%     [log(lambda_1); ...; log(lambda_n); log(sf)]
hyp.cov = [log(1) * ones(noFeatures, 1); 1];

gpinstance.optimise(hyp);


%% Optimization algorithm

% even though problem.x0 is not used by MultiSearch, it is required.
problem.x0 = r(1, noFeatures);
problem.lb = domain.min;
problem.ub = domain.max;
problem.nonlcon = @util.nonlincon;
problem.solver = 'fmincon';
problem.options = optimoptions('fmincon', ...
                               'GradObj', 'on', ...
                               'MaxIter', 100, ...
                               'Display', 'none');
problem.objective = @(x) gpinstance.oneStepLookahead(x);


% MultiStart Object
ms = MultiStart('Display', 'off', ...
                'TolX', 1e-3, ...
                'UseParallel', true);


for l = 1:noLoops
  disp(['Round ' num2str(l) ' ... Start']);

  % find the next x to evaluate
  startPoints = CustomStartPointSet(r(20 * noWorkers, noFeatures));
  [~,~,~,~,mins] = ms.run(problem, startPoints);
  
  % mins is an array of GlobalOptimSolution instances.
  % take the best ones (the results are already sorted)
  xNext = cell2mat({mins(1:noWorkers).X}');
  
  disp('next x found');
  
  spmd
    % 'Dist' is short for 'Distributed among all nodes'
    DistyNext = f(xNext(labindex,:));
  end
  
  yNext = cell2mat(DistyNext(:));
  
  % normalisation
  yNext = util.normalise(yNext, range);
  
  gpinstance.addTrainPoints(xNext, yNext);
  gpinstance.optimise(hyp);
  
  disp(['Round ' num2str(l) ' ... End']);
end

xNext = [];
yNext = [];

[finalX, finalY] = gpinstance.getTrainSet;

% denormalise
finalY = util.denormalise(finalY, range);


[minn, idx] = min(finalY);
disp(['min ' num2str(finalX(idx,:)) ': ' num2str(minn)]);

save(filename, 'finalX', 'finalY', '-append');

delete(gcp('nocreate'));
