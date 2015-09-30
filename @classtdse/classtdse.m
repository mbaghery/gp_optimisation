classdef classtdse < handle
  %CLASSTDSE TD Schroedinger equation class
  %   Detailed explanation goes here
  
  properties (Access = public)
    propParams;
    simBoxParams;
    potParams;
  end
  
  properties (Access = protected)
    M; % number of time steps
    dx;
    psi;
    boundStates; % bound states of the given potential
    
    auxLaserPot;
    auxMatPlus;
    auxMatMinus;
  end
  
  methods (Access = public)
    initialise(this)
    setWavefunction(this, initState)
    propagate(this, laserFun, howOften, outputFun)
    c = getCharge(this)
  end
  
end
