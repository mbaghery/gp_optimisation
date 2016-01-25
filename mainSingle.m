clear all; clc;

noWorkers = 20;
noLoops = 5;
noFeatures = 2;

filename = 'Ackley2.mat';

% set the approximate Y range
range.min = -5;
range.max = 5;

% set the hypercube limits
domain.min = -30 * ones(1, noFeatures);
domain.max = 30 * ones(1, noFeatures);

% the goal function
% f = @(x) log(testFuns.griewank(x));
% f = @(x) sqrt(testFuns.griewank(x));
f = @testFuns.saalmann;


%% Build the training set
disp('Build the training set');

trainSetSize = 50;
X = util.randbox(domain, trainSetSize);
Y = f(X);

% save(filename, 'X', 'Y', 'noFeatures');
% load(filename); % load the training set
% break

%% Set up the gp instnace
disp('Set up the gp');

% normalization
Y = util.normalise(Y, range);

gpinstance = classgp(X, Y);

sn = util.normalise(0.02, range, true);
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

problem.x0 = [0,0];
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
                'TolX', 1e-3);


% bias defined according to arXiv:1507.04964 = bias*mean-(1-bias)*sigma
% bias = linspace(0.5, 1, noWorkers);

for l = 1:noLoops
  disp(['Round ' num2str(l) ' ... Start']);
  
  % australian scheme
%   x = schemes.australia(noWorkers, gpinstance, problem, randFun);

  % depth-first search scheme
%   xNext = schemes.BFS(gpinstance, domain, noWorkers);
  

  % find the next x to evaluate
  [~,~,~,~,mins] = ms.run(problem, 10 * noWorkers);
  
  % the results are already sorted
  xNext = cell2mat({mins(1:noWorkers).X}');
  
  disp('next x found');

  
%   figure
%   postProc.plotEvidence(gpinstance);
%   postProc.plotLatentFun(gpinstance, f, domain, range, xNext);
%   drawnow;
%   
%   disp('Plotted');
%   while(waitforbuttonpress == 0)
%   end

%   saveas = ['Saalmann, whole, ' num2str((l-1) * noWorkers + trainSetSize) '.png'];
%   export_fig(saveas, '-transparent');
  
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

% figure
postProc.plotLatentFun2D(gpinstance, f, domain, range);
% drawnow;
% saveas = ['round' num2str(noLoops+1) '.png'];
% export_fig(saveas, '-transparent');


[minn, idx] = min(finalY);
disp([num2str(finalX(idx,:)) ': ' num2str(minn)]);

% save(filename, 'finalX', 'finalY', '-append');
