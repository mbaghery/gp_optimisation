% clear all; clc;

noWorkers=13;

parpool('hubert', noWorkers);

noLoops=60;

% this line is specified by the user through the command line
% noFeatures=8; % no. of QHO terms to be included

filename=['trainSets/Koudai' num2str(noFeatures) '.mat'];


%% Set up the tdse instance
disp('Set up the tdse instance');

% propagation parameters
propParams.duration=1000; % simulation runs from 0 to duration
propParams.dt=1e-2;


% simulation box parameters
simBoxParams.length=1000; % box is from -length/2 to +length/2
simBoxParams.noGridPoints=10000;


% set the potential parameters
potParams.potFun=@(x) potentials.koudai(x);
potParams.noBoundStates=1;


% set the initial wavefunction
initState.type='groundstate'; % or 'manual'
% initState.wavefun=[1;2;2.1]; % or nothing in case of 'groundstate'


% laser parameters
laserParams.amplitude=1;
laserParams.omega=0.314; % 0.456=100nm, 0.314=145nm
laserParams.FWHM=100;


% setting up tdse
tdseinstance=classtdse;
tdseinstance.propParams=propParams;
tdseinstance.simBoxParams=simBoxParams;
tdseinstance.potParams=potParams;

tdseinstance.initialise;



% %% Build the training set
% disp('Build the training set');
% 
% trainSetSize=32;
% X=util.unisphrand(trainSetSize, noFeatures);
% % X = lhsdesign(n,p)
% laserFuns=cell(trainSetSize,1);
% for i=1:trainSetSize
%   laserFuns{i} = @(t) ...
%     pulses.freqEnv(t - propParams.duration / 2, ...
%     laserParams.amplitude, laserParams.omega, ...
%     laserParams.FWHM, X(i,:));
% end
% 
% spmd
%   DistributedY=zeros(trainSetSize/noWorkers,1);
%   
%   for i=1:trainSetSize/noWorkers
%     disp(['loop no. ' num2str(i)]);
%     
%     tdseinstance.setWavefunction(initState);
%     
%     tdseinstance.propagate(laserFuns{(labindex-1)*trainSetSize/noWorkers+i});
%     DistributedY(i) = tdseinstance.getCharge;
%   end
% end
% 
% Y=cell2mat(DistributedY(:));
% 
% save(filename, 'X', 'Y', 'noFeatures');




%% Set up the gp instnace
disp('Set up the gp instance');

load(filename); % load the training set


% normalization
minY = min(Y);
maxY = max(Y);
Y = (2*Y-maxY-minY)*5/(maxY-minY);

% set the hyperparameters
% [log(lambda_1); log(lambda_2); log(sf)]
hyp.cov = [log(1)*ones(noFeatures,1); log(1)];

sn = 0.05*10; % uncertainty 10% because y range is 0 to 10
hyp.lik = log(sn); % log(sn)


gpinstance=classgp(X,Y);
% Symmetry
gpinstance.addTrainPoints(-X, Y);

gpinstance.hyp=hyp;


%% Optimization algorithm
disp('Optimization algorithm');

% make sure the new point is on a sphere
problem.nonlcon=@nonlincon;

problem.solver = 'fmincon';
problem.options = optimoptions('fmincon', ...
  'GradObj', 'on', 'MaxIter', 100, 'Display', 'none');

laserFuns = cell(noWorkers,1);

% bias defined according to arXiv:1507.04964 = bias*mean-(1-bias)*sigma
bias = linspace(0.5,1,noWorkers);

for l=1:noLoops
  disp(['Start of round ' num2str(l)]);
  
  gpinstance.optimise;
  gpinstance.initialise;
  disp('gp optimised and initialised');

  % Australian version Start
  objectives = cell(noWorkers,1);
  
  for i=1:noWorkers
    objectives{i} = @(x) gpinstance.evalAus(x, bias(i)); %Objective function
  end
  
  spmd
    problem.objective=objectives{labindex};
    problem.x0 = util.unisphrand(1,noFeatures); % initial guess    
    
    Distributedx = fmincon(problem);
  end
  
  x=cell2mat(Distributedx(:));
  % Australian version End


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
  
  

%   % my 2nd version Start
%   x=auxMyVer2(int8(log(2*noWorkers+1)/log(3)), gpinstance);
%   % my 2nd version End



  disp('next x found');
  
  for i = 1:noWorkers
    laserFuns{i} = @(t) ...
      pulses.freqEnv(t - propParams.duration / 2, ...
      laserParams.amplitude, laserParams.omega, ...
      laserParams.FWHM, x(i,:));
  end
  
  outputFun=@outputs.timeOnly;
  
  spmd
    tdseinstance.setWavefunction(initState);
    
    tdseinstance.propagate(laserFuns{labindex}, 250, outputFun);
    Distributedy = tdseinstance.getCharge;
  end
  
  y=cell2mat(Distributedy(:));
  
  % normalization
  y=(2*y-maxY-minY)*5/(maxY-minY);
  
  gpinstance.addTrainPoints(x, y);
  % Symmetry
  gpinstance.addTrainPoints(-x, y);
  
end

[finalX, finalY]=gpinstance.getTrainSet;

% reverse normalization
finalY=finalY*(maxY-minY)/10+(maxY+minY)/2;

save(filename, 'finalX', 'finalY', '-append');


delete(gcp('nocreate'));
