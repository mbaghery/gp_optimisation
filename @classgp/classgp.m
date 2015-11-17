classdef classgp < matlab.mixin.Copyable
  %CLASSGP Gaussian Process class
  %   This class assumes the covariance function is squared exponential,
  %   and the likelihood is gaussian.
  
  properties (Access = protected)
    X; % training set
    Y; % target values
    
    % the following matrices are stored for the sake of efficiency
    alpha;
    invK;
    invK_dK_alpha;
    invK_dmu;
  end
  
  properties (Access = public)
    uncertainty;
    hyp;
    mean;
    cov;
    meanD;
    covD;
    
    LaplaceCov;
    
    noFeatures; % dimension of each training point
  end
  
  methods (Access = public)
    [l, dl, ddl] = infer(this, hyp)
    output = optimise(this, hyp)
    addTrainPoints(this, xs, ys)
    [m, s, dm, ds] = predictMAP(this, xs)
    [m, s, dm, ds] = predictBBQ(this, xs)
    [f, df] = oneStepLookahead(this, xs)
    [x, y] = getTrainSet(this)
    [x, y] = getMin(this)
%     k = covariance(this, x1, x2); % temporary, to be removed later
%     k = correlation(this, x1, x2); % temporary, to be removed later
    
    function obj = classgp(trainX, trainY)
      obj.X = trainX;
      obj.Y = trainY;
      
      obj.noFeatures = size(trainX, 2);
    end
  end
  
end
