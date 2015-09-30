classdef classgp < matlab.mixin.Copyable
  %CLASSGP Gaussian Process class
  %   This class assumes the covariance function is squared exponential,
  %   and the likelihood is gaussian.
  
  properties (Access = protected)
    X; % training set
    Y; % target values
    
    % the following matrices are stored for the sake of efficiency
    alpha;
    beta;
  end
  
  properties (Access = public)
    hyp;
    noFeatures;
  end
  
  methods (Access = public)
    addTrainPoints(this, xs, ys)
    initialise(this)
    optimise(this)
    [m, s, dm, ds] = predict(this, xs)
    [x, y] = getTrainSet(this)
    
    function obj = classgp(trainX, trainY)
      obj.X = trainX;
      obj.Y = trainY;
      
      obj.noFeatures = size(trainX, 2);
    end
  end
  
end
