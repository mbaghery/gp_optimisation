close all; clear all; clc;

noWorkers=8;
noLoops=5;
noFeatures=2; % no. of QHO terms to be included
filename='Koudai2.mat';


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
% initState.wavefcn=[1;2;2.1]; % or nothing in case of 'groundstate'


% laser parameters
laserParams.amplitude=0.5;
laserParams.omega=0.314; % 0.456=100nm, 0.314=145nm
laserParams.FWHM=100;



tdseinstance=classtdse;
tdseinstance.propParams=propParams;
tdseinstance.simBoxParams=simBoxParams;
tdseinstance.potParams=potParams;

tdseinstance.initialise;


% build the training set
trainSetSize=32;
X=zeros(trainSetSize, noFeatures);

laserFuns=cell(trainSetSize,1);
for i=1:trainSetSize % no of workers
  x=util.sph2cart(util.sphrand(noFeatures-1));
  X(i,:)=x';

  laserFuns{i} = @(t) ...
    pulses.QHOEnv(t - propParams.duration / 2, ...
    laserParams.amplitude, laserParams.omega, ...
    laserParams.FWHM, x');
end

spmd
  DistributedY=zeros(trainSetSize/noWorkers,1);
  
  for i=1:trainSetSize/noWorkers
    disp(['loop no. ' num2str(i)]);
    
    tdseinstance.setWavefunction(initState);
    
    tdseinstance.propagate(laserFuns{(labindex-1)*trainSetSize/noWorkers+i});
    DistributedY(i) = tdseinstance.getCharge;
  end
end

Y=cell2mat(DistributedY(:));

save(filename, 'X', 'Y', 'noFeatures');
disp('initial training set done');
% break


% If the training set already exists
load(filename); % load X and Y

% X=finalX;
% Y=finalY;


% set covariance function, likelihood function, 
% and hyperparameters initial values
hyp.cov = [log(1)*ones(noFeatures,1); log(1)]; % [log(lambda_1); log(lambda_2); log(sf)]
hyp.lik = log(0.05); % log(sn)
hyp.mean = 82;
prior.lik = {{@priorDelta}};
% prior.lik = {{@priorGauss,log(0.1), log(0.01)}};


gpinstance=classgp;

gpinstance.mean={@meanConst};
gpinstance.cov={@covSEard};
gpinstance.lik={@likGauss};
gpinstance.inf={@infPrior,@infExact,prior};
gpinstance.hyp=hyp;

gpinstance.addPoint(X,Y);


% problem.lb = zeros(noFeatures, 1); % Vector of lower bounds
% problem.ub = pi * [ones(noFeatures-1,1); 2]; % Vector of upper bounds

problem.nonlcon=@nonlincon;

problem.solver = 'fmincon';
problem.options = optimoptions('fmincon', 'GradObj', 'on', 'MaxIter', ...
  100, 'Display', 'none');

laserFuns = cell(noWorkers,1);
objectives = cell(noWorkers,1);

% bias defined according to arXiv:1507.04964 = bias*mean-(1-bias)*sigma
bias = linspace(0,1,noWorkers);

for l=1:noLoops
  disp(['Start of round ' num2str(l)]);
  
  for i=1:noWorkers
    objectives{i} = @(x) gpinstance.evaluate(x, bias(i)); %Objective function
  end
  
  spmd
    problem.objective=objectives{labindex};
    
%     if (labindex==noWorkers) % evaluate return the mean
%       [~,index]=min(gpinstance.Y);
%       problem.x0=gpinstance.X(index,:);
%     else
    problem.x0 = util.sphrand(noFeatures)'; % initial guess
%     end

% problem.x0 = 2 * rand(1, noFeatures) - 1; % initial guess
    
    Distributedx=fmincon(problem);
  end
  
  x=cell2mat(Distributedx(:));
  
  for i = 1:noWorkers
    laserFuns{i} = @(t) ...
      pulses.QHOEnv(t - propParams.duration / 2, ...
      laserParams.amplitude, laserParams.omega, ...
      laserParams.FWHM, util.sph2cart(x(i,:)')');
  end
  
  outputFun=@outputs.timeOnly;
  
  spmd
    tdseinstance.setWavefunction(initState);
    
    tdseinstance.propagate(laserFuns{labindex}, 250, outputFun);
    Distributedy = tdseinstance.getCharge;
  end
  
  y=cell2mat(Distributedy(:));
  
    
  gpinstance.addPoint(x, y);
  
  chargehistory(l)=min(gpinstance.Y);
end

chargehistory

finalX=gpinstance.X;
finalY=gpinstance.Y;

save(filename, 'X', 'Y', 'noFeatures', 'finalX', 'finalY');

