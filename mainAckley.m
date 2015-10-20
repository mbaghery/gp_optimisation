clear all; clc;

noWorkers=8;

noLoops=8;

noFeatures=1;

filename='Ackley.mat';

% set the approximate Y range
Ymin = -4;
Ymax = 6;

% set the hypercube limits
Xmin = -50;
Xmax = 100;

randFun=@(m, n) (Xmax - Xmin) * rand(m, n) + Xmin;


% the goal function
% f = @(x) log(testFuns.griewank(x));
% f = @(x) sqrt(testFuns.griewank(x));
f = @testFuns.griewank;

%% Build the training set
disp('Build the training set');

trainSetSize=20;
X = randFun(trainSetSize, noFeatures);
Y = f(X);

% save(filename, 'X', 'Y', 'noFeatures');


%% Set up the gp instnace
disp('Set up the gp instance');
setGP;


%% Optimization algorithm
disp('Optimization algorithm');

problem.lb = Xmin*ones(1,noFeatures);
problem.ub = Xmax*ones(1,noFeatures);

problem.solver = 'fmincon';
problem.options = optimoptions('fmincon', ...
  'GradObj', 'on', 'MaxIter', 100, 'Display', 'none');

% bias defined according to arXiv:1507.04964 = bias*mean-(1-bias)*sigma
bias = linspace(0.5, 1, noWorkers);

for l=1:noLoops
  disp(['Start of round ' num2str(l)]);

  
  % australian scheme
%   x = schemes.australia(noWorkers, gpinstance, problem, randFun);

  % greedy
%   x = schemes.australia(noWorkers, gpinstance, problem, randFun, ones(noWorkers,1));
  
  % depth-first search scheme
  x = schemes.DFS(noWorkers, gpinstance, problem, randFun);
  
  % tradeoff scheme
%   x = schemes.tradeoff(noWorkers, gpinstance, problem, randFun);
  
  % some hybrid scheme % best so far IMO
%   x = schemes.australia(1, gpinstance, problem, randFun, (1+mod(l,5))/5);
%   x = schemes.tradeoff(noWorkers, gpinstance, problem, @(t1,t2) x);
  
  % some other hybrid scheme
%   x = schemes.australia(1, gpinstance, problem, randFun);
%   x = schemes.tradeoff(noWorkers, gpinstance, problem, @(t1,t2) x);

  % yet another hybrid scheme
%   [x, ~] = gpinstance.getMin;
%   x = schemes.tradeoff(noWorkers, gpinstance, problem, @(t1,t2) x);


  disp('next x found');

  postProc.plot2d;
  drawnow;
  while(waitforbuttonpress==0)
  end
%   saveas = ['round' num2str(l) '.png'];
%   export_fig(saveas, '-transparent');
  
  y = f(x);
  
  % normalisation
  y = util.normalise(y, Ymin, Ymax);
  
  gpinstance.addTrainPoints(x, y);
  
  gpinstance.hyp = hyp;
  gpinstance.optimise;
  gpinstance.initialise;
  
  

end

[finalX, finalY] = gpinstance.getTrainSet;

% denormalise
finalY = util.denormalise(finalY, Ymin, Ymax);


postProc.plot2d;
drawnow;
% saveas = ['round' num2str(noLoops+1) '.png'];
% export_fig(saveas, '-transparent');


[minn,idx]=min(finalY);
disp([num2str(finalX(idx,:)) ': ' num2str(minn)]);

% save(filename, 'finalX', 'finalY', '-append');
