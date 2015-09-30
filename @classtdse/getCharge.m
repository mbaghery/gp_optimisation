function c = getCharge(this)
  chargeVector = this.psi' * this.boundStates;
  c = chargeVector * chargeVector' * this.dx ^ 2;
end
