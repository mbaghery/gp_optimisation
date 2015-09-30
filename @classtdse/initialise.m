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
