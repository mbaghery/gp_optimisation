function setWavefunction(this, initState)
  % set the initial wavefunction
  if (strcmp(initState.type, 'groundstate'))
    this.psi=this.boundStates(:,1);
  else
    this.psi=initState.wavefun;
  end
end
