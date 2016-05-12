clear all; clc;

noWorkers = 1;
noLoops = 25;
noFeatures = 1;

filename = 'Ackley.mat';

% set the approximate Y range
range.min = -5;
range.max = 25;

% set the hypercube limits
domain.min = -10 * ones(1, noFeatures);
domain.max = 10 * ones(1, noFeatures);

% the goal function
% f = @(x) log(testFuns.griewank(x));
% f = @(x) sqrt(testFuns.griewank(x));
f = @testFuns.ackley;

% random number generator
r = @util.randbox;

%% Build the training set
disp('Build the training set');

trainSetSize = 0;
X = r(trainSetSize, domain);
Y = f(X);

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
problem.x0 = r(1, domain);
problem.lb = domain.min;
problem.ub = domain.max;

problem.solver = 'fmincon';
problem.options = optimoptions('fmincon', ...
                               'GradObj', 'on', ...
                               'MaxIter', 100, ...
                               'Display', 'none');
problem.objective = @(x) gpinstance.oneStepLookahead(x);


% MultiStart Object
ms = MultiStart('Display', 'off', ...
                'TolX', 1e-3, ...
                'UseParallel', false);


for l = 1:noLoops
  disp(['Round ' num2str(l) ' ... Start']);
  
  % find the next x to evaluate
  startPoints = CustomStartPointSet(r(20 * noWorkers, domain));
  [~,~,~,~,mins] = ms.run(problem, startPoints);
  
  % mins is an array of GlobalOptimSolution instances.
  % take the best ones (the results are already sorted)
  xNext = cell2mat({mins(1:noWorkers).X}');
  
  disp('next x found');

  
%   figure
%   postProc.plotEvidence(gpinstance);
  postProc.plotLatentFun1D(gpinstance, f, domain, range, xNext);
  drawnow;
  ylim([range.min, range.max]);
  
  saveas = ['Ackley' num2str(l) '.pdf'];
  export_fig(saveas, '-transparent');
  
  yNext = f(xNext);
  
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