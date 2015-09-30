% clear all; clc;

noWorkers=13;

parpool('hubert', noWorkers);

noLoops=10;

% this line is specified by the user through the command line
% noFeatures=8; % no. of QHO terms to be included

filename=['trainSets/Koudai' num2str(noFeatures) '.mat'];

trainSetSize=32;

% set the approximate Y range
Ymin = 0;
Ymax = 1;

%% Set up a tdse instance
disp('Set up a tdse instance');
setTDSE;


%% Build the training set
disp('Build the training set');
buildTrainSet;


%% Set up a gp instnace
disp('Set up a gp instance');
setGP;


%% Optimization algorithm
disp('Optimization algorithm');

% make sure the new point is on a sphere
problem.nonlcon=@nonlincon;

problem.solver = 'fmincon';
problem.options = optimoptions('fmincon', ...
  'GradObj', 'on', 'MaxIter', 100, 'Display', 'none');

laserFuns = cell(noWorkers, 1);

for l=1:noLoops
  disp(['Start of round ' num2str(l)]);
  
  gpinstance.optimise;
  gpinstance.initialise;
  disp('gp optimised and initialised');

%   % Australian version Start
%   objectives = cell(noWorkers,1);
%   
%   for i=1:noWorkers
%     objectives{i} = @(x) gpinstance.evalAus(x, bias(i)); %Objective function
%   end
%   
%   spmd
%     problem.objective=objectives{labindex};
%     problem.x0 = util.unisphrand(1,noFeatures); % initial guess    
%     
%     Distributedx = fmincon(problem);
%   end
%   
%   x=cell2mat(Distributedx(:));
%   % Australian version End



  
%   problem.objective = @(x) gpinstance.evalAus(x, bias(mod(l,noWorkers)+1)); %Objective function;
%   problem.x0 = randfun(1, noFeatures); % initial guess    
% 
%   x0 = fmincon(problem);


%   % my version Start
%   gpclone=gpinstance.copy;
%   x=zeros(noWorkers, noFeatures);
%   
%   for i=1:noWorkers
%     problem.objective = @(x) gpclone.evalMe(x);
%     problem.x0 = util.unisphrand(1,noFeatures);
%     x(i,:) = fmincon(problem);
%     y = gpclone.predict(x(i,:));
%     gpclone.addTrainPoints(x(i,:),y);
%     % Symmetry
%     gpclone.addTrainPoints(-x(i,:), y);
%     gpclone.initialise;
%   end
%   % my version End


  

  % my 2nd version Start
%   x = auxMyVer2(int8(log(2*noWorkers+1)/log(3)), gpinstance, ...
%     problem, @(x,y) x0); %@util.unisphrand);
  % my 2nd version End
  
  
  
  
  
  
  % australian scheme
  x = schemes.australia(noWorkers, gpinstance, problem, @util.unisphrand);
  
  % depth-first search scheme
  x = schemes.DFS(noWorkers, gpinstance, problem, @util.unisphrand);
  
  % tradeoff scheme
  x = schemes.tradeoff(noWorkers, gpinstance, problem, @util.unisphrand);
  
  % some hybrid scheme
  x = schemes.australia(1, gpinstance, problem, @util.unisphrand, (1+mod(l,5))/5);
  x = schemes.tradeoff(noWorkers, gpinstance, problem, @(t) x);
  
  % some other hybrid scheme
  x = schemes.australia(1, gpinstance, problem, @util.unisphrand);
  x = schemes.tradeoff(noWorkers, gpinstance, problem, @(t) x);


  disp('next x found');
  
  for i = 1:noWorkers
    laserFuns{i} = @(t) ...
      pulses.qhoEnv(t - propParams.duration / 2, ...
      laserParams.amplitude, laserParams.omega, ...
      laserParams.FWHM, x(i,:));
  end
  
%   spitterFun=@spitters.timeOnly;
  
  tdseinstance.setWavefunction(initState);
  
  spmd
    tdseinstance.propagate(laserFuns{labindex}, 250, @spitters.timeOnly); %spitterFun);
    
    Distributedy = tdseinstance.getCharge;
  end
  
  y=cell2mat(Distributedy(:));
  
  % normalise
  y = util.normalise(y, Ymin, Ymax);
  
  gpinstance.addTrainPoints(x, y);
  % Symmetry
  gpinstance.addTrainPoints(-x, y);
  
end

[finalX, finalY]=gpinstance.getTrainSet;

% denormalise
finalY = util.denormalise(finalY, Ymin, Ymax);

save(filename, 'finalX', 'finalY', '-append');


delete(gcp('nocreate'));
