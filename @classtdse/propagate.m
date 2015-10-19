function propagate(this, laserFun, howOften, spitterFun)
%   time propagation
%   howOften takes on values from [0, duration], and shows how often
%   outputFun is called.
% 
%   variableInputs contains values which can be used directly:
%   time, and laser amplitude
%   handleInputs contains function handlers, thus they should be called
%   first to produce their values. This means if the spitter doesn't need
%   them, they won't be comuted at all.
%   charge, wavefunction
%   Other quantities might be added in the future.
  
  
  % once every how many time steps should the spitter function be called?
  if(nargin<3)
    howOften=0;
  else
    howOften = ceil(howOften / this.propParams.dt);
  end
  
  
  handlerInputs = {@this.getCharge, @this.getWavefunction};
  
  t = 0;
  laserAmplitude = 0;
  
  if (howOften == 0)
    varriableInputs = {t, laserAmplitude}; % {time, laser amplitude}
    spitterFun(varriableInputs, handlerInputs);
  end
  
  
  for i=1:this.M
    t = i * this.propParams.dt;
    
    % crank-nicolson scheme
    laserAmplitude = laserFun(t);
    HLaser = laserAmplitude * this.auxLaserPot;
    this.psi = (this.auxMatPlus + HLaser) \ ...
      (this.auxMatMinus * this.psi - HLaser * this.psi);
    
    % print things out on the screen
    if (mod(i, howOften) == 0)
      varriableInputs = {t, laserAmplitude};
      spitterFun(varriableInputs, handlerInputs);
    end
  end
  
end
