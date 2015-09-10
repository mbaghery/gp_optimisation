% close all; clear all; clc;

noWorkers=8;

parpool(noWorkers);

noLoops=15;

% this line is specified by the user through the command line
% noFeatures=3; % no. of QHO terms to be included

filename=['Koudai' num2str(noFeatures) '.mat'];


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
laserParams.amplitude=1;
laserParams.omega=0.314; % 0.456=100nm, 0.314=145nm
laserParams.FWHM=100;


% setting up tdse
disp('setting up tdse');
tdseinstance=classtdse;
tdseinstance.propParams=propParams;
tdseinstance.simBoxParams=simBoxParams;
tdseinstance.potParams=potParams;

tdseinstance.initialise;

break
% build the training set
disp('building the training set');
trainSetSize=32;
X=util.cartrand(trainSetSize, noFeatures);

laserFuns=cell(trainSetSize,1);
for i=1:trainSetSize % no of workers
  laserFuns{i} = @(t) ...
    pulses.QHOEnv(t - propParams.duration / 2, ...
    laserParams.amplitude, laserParams.omega, ...
    laserParams.FWHM, X(i,:));
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
disp('training set done');
% break


% % If the training set already exists
% load(filename); % load X and Y

% X=finalX;
% Y=finalY;


% set covariance function, likelihood function, 
% and hyperparameters initial values
hyp.cov = [log(1)*ones(noFeatures,1); log(1)]; % [log(lambda_1); log(lambda_2); log(sf)]
hyp.lik = log(0.05); % log(sn)


gpinstance=classgp(X,Y);
% Symmetry
gpinstance.addTrainPoints([X(:,1:end-1),-1*X(:,end)], Y);

gpinstance.hyp=hyp;

gpinstance.optimise;
gpinstance.initialise;


% % make sure the last component is always positive
% problem.Aineq=diag([zeros(noFeatures-1,1); -1]);
% problem.bineq=zeros(noFeatures,1);

% make sure the new point is on a sphere
problem.nonlcon=@nonlincon;

problem.solver = 'fmincon';
problem.options = optimoptions('fmincon', ...
  'GradObj', 'on', 'MaxIter', 100, 'Display', 'none');

laserFuns = cell(noWorkers,1);
objectives = cell(noWorkers,1);

% bias defined according to arXiv:1507.04964 = bias*mean-(1-bias)*sigma
bias = linspace(0.5,1,noWorkers);

for l=1:noLoops
  disp(['Start of round ' num2str(l)]);
  
  for i=1:noWorkers
    objectives{i} = @(x) gpinstance.evaluate(x, bias(i)); %Objective function
  end
  
  spmd
    problem.objective=objectives{labindex};
    problem.x0 = util.cartrand(1,noFeatures); % initial guess    
    
    Distributedx=fmincon(problem);
  end
  
  x=cell2mat(Distributedx(:));
  
  for i = 1:noWorkers
    laserFuns{i} = @(t) ...
      pulses.QHOEnv(t - propParams.duration / 2, ...
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
  
  gpinstance.addTrainPoints(x, y);
  % Symmetry
  gpinstance.addTrainPoints([x(:,1:end-1),-1*x(:,end)], y);
  gpinstance.optimise;
  gpinstance.initialise;
end

[finalX, finalY]=gpinstance.getTrainSet;

save(filename, 'finalX', 'finalY', '-append');


delete(gcp('nocreate'));


break
%% Plot section

hyp.cov = [log(1)*ones(noFeatures,1); log(1)]; % [log(lambda_1); log(lambda_2); log(sf)]
hyp.lik = log(0.05); % log(sn)

gpinstance=classgp(finalX,finalY);

gpinstance.hyp=hyp;

gpinstance.optimise;
gpinstance.initialise;
