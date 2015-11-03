clear all; clc;

noWorkers = 8;

noLoops = 10;

noFeatures = 1;

filename = 'Ackley2.mat';

% set the approximate Y range
Ymin = -5;
Ymax = 5;

% set the hypercube limits
domain.min = -50 * ones(1, noFeatures);
domain.max = 50 * ones(1, noFeatures);

randFun=@(m) bsxfun(@plus, bsxfun(@times, rand(m, noFeatures), ...
  (domain.max - domain.min)), domain.min);


% the goal function
% f = @(x) log(testFuns.griewank(x));
% f = @(x) sqrt(testFuns.griewank(x));
f = @testFuns.griewank;

%% Build the training set
disp('Build the training set');

trainSetSize = 4;
X = randFun(trainSetSize);
Y = f(X);

% save(filename, 'X', 'Y', 'noFeatures');
% load(filename); % load the training set
% break

%% Set up the gp instnace
disp('Set up the gp instance');
setGP;


% hess=@(x) exp(-gpinstance.infer(struct('mean',x(1),'cov',x(2:end))));
% hesslog=@(x) gpinstance.infer(struct('mean',x(1),'cov',x(2:end)));
% hypopt=gpinstance.hyp;
% clc
xx=linspace(domain.min, domain.max, 500)';
[m,k,dm,dk] = gpinstance.predictMAP(xx);
[m2,k2,dm2,dk2] = gpinstance.predictBBQ(xx);
% figure, plot(xx,k2,'b', xx,dk2,'r', xx(1:end-1)+(domain.max-domain.min)/1000,diff(k2)*500/(domain.max-domain.min))
figure, plot(xx,k,'b',xx,k2,'r')
% figure, myvarianceplot(xx,m,sqrt(k));
% figure, myvarianceplot(xx,m2,sqrt(k2));


% fun = @(x) covDFuns.covSEardD(x, [1,1,1], [1.5,2,1.1]) * [0;1;0];
% gradest(fun, gpinstance.hyp.cov)
% covDFuns.covSEardD(gpinstance.hyp.cov, [1,1,1], [1.5,2,1.1])



break

%% Optimization algorithm
disp('Optimization algorithm');

problem.lb = domain.min;
problem.ub = domain.max;

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
  x = schemes.BFS(noWorkers, gpinstance, problem, randFun);
  
  disp('next x found');

%   figure
%   postProc.plotEvidence;
  
  postProc.plotLatentFun;
  drawnow;
%   while(waitforbuttonpress==0)
%   end
%   saveas = ['round' num2str(l) '.png']; export_fig(saveas, '-transparent');
  
  y = f(x);
  
  % normalisation
  y = util.normalise(y, Ymin, Ymax);
  
  gpinstance.addTrainPoints(x, y);
  
  
  gpinstance.infer(gpinstance.optimise(hyp));
  
  
end

x=[];
y=[];

[finalX, finalY] = gpinstance.getTrainSet;

% denormalise
finalY = util.denormalise(finalY, Ymin, Ymax);

% figure
postProc.plotLatentFun;
drawnow;
% saveas = ['round' num2str(noLoops+1) '.png'];
% export_fig(saveas, '-transparent');


[minn,idx]=min(finalY);
disp([num2str(finalX(idx,:)) ': ' num2str(minn)]);

% save(filename, 'finalX', 'finalY', '-append');
