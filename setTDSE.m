% propagation parameters
propParams.duration = 1000; % simulation runs from 0 to duration
propParams.dt = 1e-2;


% simulation box parameters
simBoxParams.length = 1000; % box is from -length/2 to +length/2
simBoxParams.noGridPoints = 10000;


% set the potential parameters
potParams.potFun = @(x) potentials.koudai(x);
potParams.noBoundStates = 1;


% set the initial wavefunction
initState.type = 'groundstate'; % or 'manual'
% initState.wavefun = [1;2;2.1]; % or nothing in case of 'groundstate'


% laser parameters
laserParams.amplitude = 1;
laserParams.omega = 0.314; % 0.456=100nm, 0.314=145nm
laserParams.FWHM = 100;


% setting up tdse
tdseinstance = classtdse;
tdseinstance.propParams = propParams;
tdseinstance.simBoxParams = simBoxParams;
tdseinstance.potParams = potParams;

tdseinstance.initialise;
