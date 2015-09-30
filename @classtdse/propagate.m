function propagate(this, laserFun, howOften, spitterFun)
  % time propagation
  % howOften takes on values from [0, duration], and shows how often
  % outputFun is called.

  t=0;

  if(nargin<3)
    howOften=0;
  else
    % once every how many time steps is output displayed?
    howOften = ceil(howOften / this.propParams.dt);

    spitterFun(t);
  end


  for i=1:this.M
    t = i * this.propParams.dt;

    % crank-nicolson scheme
    HLaser = laserFun(t) * this.auxLaserPot;
    this.psi = (this.auxMatPlus + HLaser) \ ...
      (this.auxMatMinus * this.psi - HLaser * this.psi);

    % print things out on the screen
    if (mod(i, howOften) == 0), spitterFun(t); end

  end
end
