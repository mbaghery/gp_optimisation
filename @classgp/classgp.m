classdef classgp < matlab.mixin.Copyable
  %CLASSGP Gaussian Process class
  %   This class assumes the covariance function is squared exponential,
  %   and the likelihood is gaussian.
  
  properties (Access = protected)
    X; % training set
    Y; % target values
    
    % the following matrices are stored for the sake of efficiency (aka for
    % fuck's sake)
    
%     alpha;
    beta;
    
    post;
  end
  
  properties (Access = public)
    hyp;
    inf;
    mean;
    cov;
    lik;
    
    noFeatures;
  end
  
  methods (Access = public)
    initialise(this)
    optimise(this)
    addTrainPoints(this, xs, ys)
    [m, s, dm, ds] = predict(this, xs)
    [f, df] = oneStepLookahead(this, xs)
    [x, y] = getTrainSet(this)
    [x, y] = getMin(this)
    
    function obj = classgp(trainX, trainY)
      obj.X = trainX;
      obj.Y = trainY;
      
      obj.noFeatures = size(trainX, 2);
    end
  end
  
end
