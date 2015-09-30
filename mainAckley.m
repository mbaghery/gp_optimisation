clear all; clc;

noWorkers=8;

noLoops=20;

noFeatures=2;

filename='Griewank.mat';


% Griewank
% f =@(x,y) 1 + 1/4000*((x/5*600).^2+(y/5*600).^2) - cos((x/5*600)).*cos((y/5*600)/sqrt(2));

% Rastirgin
% f =@(x,y) 20 + x.^2 - 10*cos(2*pi*x) + y.^2 - 10*cos(2*pi*y);

% Ackley's
f =@(x,y) -20*exp(-0.2*sqrt(0.5*(x.^2+y.^2))) ...
  - exp(0.5*(cos(2*pi*x)+cos(2*pi*y))) + exp(1) + 20;

randFun=@(m,n) 10 * rand(m, n) - 5;


%% Build the training set
disp('Build the training set');

trainSetSize=32;
X = randFun(trainSetSize, noFeatures);
Y = f(X(:,1),X(:,2));

save(filename, 'X', 'Y', 'noFeatures');




%% Set up the gp instnace
disp('Set up the gp instance');

load(filename); % load the training set


% normalization
minY = min(Y);
maxY = max(Y);
Y = (Y - (maxY+minY)/2) * 10/(maxY-minY);

% set the hyperparameters
% [log(lambda_1); log(lambda_2); log(sf)]
hyp.cov = [log(1)*ones(noFeatures,1); log(1)];

sn = 0.05 * 10/(maxY-minY); % uncertainty, factor 10 because y is rescaled to [0..10]
hyp.lik = log(sn); % log(sn)


gpinstance=classgp(X,Y);

gpinstance.hyp=hyp;


%% Optimization algorithm
disp('Optimization algorithm');

problem.lb=[-5,-5];
problem.ub=[5,5];

problem.solver = 'fmincon';
problem.options = optimoptions('fmincon', ...
  'GradObj', 'on', 'MaxIter', 100, 'Display', 'none');

% bias defined according to arXiv:1507.04964 = bias*mean-(1-bias)*sigma
bias = linspace(0.5,1,noWorkers);

for l=1:noLoops
  disp(['Start of round ' num2str(l)]);
  
  gpinstance.hyp=hyp;
  gpinstance.optimise;
  gpinstance.initialise;
  disp('gp optimised and initialised');

  
%   % Australian version Start
%   x=zeros(noWorkers, noFeatures);
%   
%   for i=1:noWorkers
%     problem.objective = @(x) gpinstance.evalAus(x, bias(i)); %Objective function;
%     problem.x0 = randfun(1, noFeatures); % initial guess    
%     
%     x(i,:) = fmincon(problem);
%   end
%   % Australian version End



  problem.objective = @(x) gpinstance.evalAus(x, bias(mod(l,noWorkers)+1)); %Objective function;
  problem.x0 = randFun(1, noFeatures); % initial guess    

  x0 = fmincon(problem);

%   % my version Start
%   gpclone=gpinstance.copy;
%   x=zeros(noWorkers, noFeatures);
%   
%   problem.objective = @(x) gpclone.evalMe(x);
%   
%   for i=1:noWorkers
%     problem.x0 = x0; %randfun(1, noFeatures);
%     
%     x(i,:) = fmincon(problem);
%     y = gpclone.predict(x(i,:));
%     
%     gpclone.addTrainPoints(x(i,:),y);
%     gpclone.initialise;
%   end
%   % my version End
  
  
  
  % my 2nd version Start
  x=auxMyVer2(int8(log(2*noWorkers+1)/log(3)), gpinstance, problem, @(x,y) x0); % randfun);
  % my 2nd version End



  disp('next x found');
  
  y = f(x(:,1),x(:,2));
  
  % normalization
  y = (y - (maxY+minY)/2) * 10/(maxY-minY);
  
  gpinstance.addTrainPoints(x, y);
  
end

[finalX, finalY]=gpinstance.getTrainSet;


gpinstance.optimise;
gpinstance.initialise;


% reverse normalization
finalY=finalY*(maxY-minY)/10+(maxY+minY)/2;

[minn,idx]=min(finalY);
disp([num2str(finalX(idx,:)) ': ' num2str(minn)]);

% save(filename, 'finalX', 'finalY', '-append');
