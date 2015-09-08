classdef classtdse < handle
  %CLASSTDSE TD Schroedinger equation class
  %   Detailed explanation goes here
  
  properties (Access=public)
    propParams;
    simBoxParams;
    potParams;
  end
  
  properties (Access=protected)
    M; % number of time steps
    dx;
    psi;
    boundStates;
    auxLaserPot;
    auxMatPlus;
    auxMatMinus;
  end
  
  methods
    function initialise(this)
      % this function has to be called when any of potParams, simBoxParams,
      % or propParams has changed.
      
      
      % number of time steps
      this.M=ceil(this.propParams.duration/this.propParams.dt);


      % set the grip points and dx
      x=linspace(-this.simBoxParams.length/2, ...
        this.simBoxParams.length/2, this.simBoxParams.noGridPoints)';
      this.dx=x(2)-x(1);


      % set the kintetic energy, potential energy and the hamiltonian
      kin=-sptoeplitz([-2;1;zeros(this.simBoxParams.noGridPoints-2,1)]) ...
        /(2*this.dx^2);
      pot=sparse(1:this.simBoxParams.noGridPoints, ...
        1:this.simBoxParams.noGridPoints, this.potParams.potFun(x));
      H0=kin+pot;


      % find the bound states
      [this.boundStates,~]=eigs(H0,this.potParams.noBoundStates,'sa');
      this.boundStates=this.boundStates/sqrt(this.dx);
      

      % These are some variables that don't change during the simulation,
      % therefore it is most efficient to calculate them outside the loop.
      this.auxLaserPot=sparse(1:this.simBoxParams.noGridPoints, ...
        1:this.simBoxParams.noGridPoints, x);
      this.auxMatPlus=H0-2i/this.propParams.dt * ...
        speye(this.simBoxParams.noGridPoints);
      this.auxMatMinus=-H0-2i/this.propParams.dt * ...
        speye(this.simBoxParams.noGridPoints);
    end
    
    
    function setWavefunction(this, initState)
      % set the initial wavefunction
      if (strcmp(initState.type, 'groundstate'))
        this.psi=this.boundStates(:,1);
      else
        this.psi=initState.wavefcn;
      end
    end
    
    
    function propagate(this, laserFun, howOften, outputFun)
      % time propagation
      % howOften takes on values from [0, duration], and shows how often
      % outputFun is called.
      
      t=0;
      
      if(nargin<3)
        howOften=0;
      else
        % once every how many time steps is output displayed?
        howOften = ceil(howOften / this.propParams.dt);

        outputFun(t);
      end
      
      
      for i=1:this.M
        t = i * this.propParams.dt;
        
        % crank-nicolson scheme
        HLaser = laserFun(t) * this.auxLaserPot;
        this.psi = (this.auxMatPlus + HLaser) \ ...
          (this.auxMatMinus * this.psi - HLaser * this.psi);
        
        % print things out on the screen
        if (mod(i, howOften) == 0), outputFun(t); end
        
      end
    end
    
    
    function c = getCharge(this)
      chargeVector = this.psi' * this.boundStates;
      c = chargeVector * chargeVector' * this.dx ^ 2;
    end
    
  end
  
end
