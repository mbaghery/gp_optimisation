function varargout = predictTaylor(this, xs)
%PREDICTTAYLOR Predictive probability based on taylor expansion
%   xs is a matrix whose rows are test points

  if (nargout<3)
    [m, k, Ks] = this.predictAffine(xs);
  else
    [m, k, Dm, Dk, Ks, DKs] = this.predictAffine(xs);
  end



  % calculate the derivatives only if they are needed
  if (nargout<3)
    return
  end





end
