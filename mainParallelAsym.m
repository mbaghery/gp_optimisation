% Maximise the asymmetry in the wavefunction

%setenv('OMP_NUM_THREADS', '4');
setenv('OMP_STACKSIZE', '2G');

noWorkers = 4;
noLoops = 20;
trainSetSize = 20;

noFeatures = 2;

filename = 'SCID.mat';

% set the approximate Y range
range.min = 0;
range.max = 0.1;

% set the hypercube limits
% 1st column: intensity of the first pulse
% 2nd column: phasediff
domain.min = [32.2362, 0]; % log(1e14) = 32.2362
domain.max = [36.8414, 2*pi]; % log(1e16) = 36.8414

% the target function
f = @(x) targetFuns.patchkovskiiAsym(exp(x(1)),x(2));

% random number generator
r = @(n) util.randbox(n, domain);


parpool('hubert', noWorkers);

%% Build the training set
disp('Build the training set');

% load(filename);

spmd
  % Dist is short for 'Distributed among all nodes'
  DistY = zeros(trainSetSize / noWorkers, 1);
  DistX = r(trainSetSize / noWorkers);
  
  for i = trainSetSize/noWorkers:-1:1
    DistY(i) = f(DistX(i,:));
    disp(['Training set one down, ' num2str(i-1) ' left']);
  end
end

trainX = cell2mat(DistX(:));
trainY = cell2mat(DistY(:));

save(filename, 'trainX', 'trainY', 'noFeatures');

%% Set up the gp instnace
disp('Set up the gp');

% normalization
trainX = util.normalise(trainX, domain);
trainY = util.normalise(trainY, range);

gpinstance = classgp(trainX, trainY);

sn = 0.1; %util.normalise(0.01, range, true);
gpinstance.uncertainty = log(sn);

gpinstance.mean = {@meanFuns.meanConst};
gpinstance.meanD = {@meanDFuns.meanConstD};

gpinstance.cov = {@covFuns.covSEard};
gpinstance.covD = {@covDFuns.covSEardD};

% mean function hyperparameters
hyp.mean = 1;

% covariance function hyperparameters
%     [log(lambda_1); ...; log(lambda_n); log(sf)]
hyp.cov = [log(1) * ones(noFeatures, 1); 1];

gpinstance.optimise(hyp);


%% Optimization algorithm

% even though problem.x0 is not used by MultiSearch, it is required.
problem.x0 = util.normalise(r(1), domain);
problem.lb = util.normalise(domain.min, domain);
problem.ub = util.normalise(domain.max, domain);

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
  startPoints = CustomStartPointSet(util.normalise(r(20 * noWorkers), domain));
  [~,~,~,~,mins] = ms.run(problem, startPoints);
  
  % mins is an array of GlobalOptimSolution instances.
  % take the best ones (the results are unique and already sorted)
  xNext = cell2mat({mins(1:noWorkers).X}');
  
  
  disp('next x found');
  
  
  spmd
    disp(['I am node ' num2str(labindex)]);
    DistyNext = f(util.denormalise(xNext(labindex,:),domain));
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
finalX = util.denormalise(finalX, domain);
finalY = util.denormalise(finalY, range);


[minn, idx] = min(finalY);
disp(['min ' num2str(finalX(idx,:)) ': ' num2str(minn)]);

save(filename, 'finalX', 'finalY', '-append');

delete(gcp('nocreate'));

