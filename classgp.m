classdef classgp < handle
  %CLASSGP Gaussian Process class
  %   Detailed explanation goes here
  
  properties (Access = protected)
    X; % training set
    Y; % target values
    
    minY;
    maxY;
    
    % the following matrices are stored for the sake of efficiency
    alpha;
    beta;
  end
  
  properties (Access = public)
    hyp;
  end
  
  methods (Access = public)
    function obj = classgp(trainX, trainY)
      obj.X = trainX;
      
      obj.minY = min(trainY);
      obj.maxY = max(trainY);
      
      obj.Y = (2*trainY-obj.maxY-obj.minY)*5/(obj.maxY-obj.minY);
    end
    
    function initialise(this)
      K = covSEard(this.hyp.cov, this.X);
      
      % the following line assumes the liklihood is Gaussian
      sn2 = exp(2*this.hyp.lik);
      
      N = length(this.Y);
      
      % very small sn2 can cause numerical instabilities
      if (sn2 < 1e-6)
        L = chol(K + sn2 * eye(N));
        this.beta = solve_chol(L, eye(N));
      else
        L = chol(K / sn2 + eye(N));
        this.beta = solve_chol(L, eye(N)) / sn2;
      end

      this.alpha = this.beta*this.Y;
    end
    
    function addTrainPoints(this, xs, ys)
      % xs is a matrix whose rows are the new training points
      
      this.X=[this.X; xs];

      this.Y=[this.Y;
        (2*ys-this.maxY-this.minY)*5/(this.maxY-this.minY)];
    end
    
    function [x, y] = getTrainSet(this)
      x=this.X;
      y=this.Y*(this.maxY-this.minY)/10+(this.maxY+this.minY)/2;
    end
    
    function [m, s2] = predict(this, xs)
      % xs is a matrix whose rows are test points
      
      ks = covSEard(this.hyp.cov, this.X, xs);

      % mean(xs)
      m = ks'*this.alpha;
      m = m*(this.maxY-this.minY)/10+(this.maxY+this.minY)/2;
      
      % sigma^2(xs)
      s2 = covSEard(this.hyp.cov, xs) - ks'*this.beta*ks;
      s2 = s2*((this.maxY-this.minY)/10)^2;
    end
    
    function optimise(this)
      % optimise the hyperparameters
      prior.lik = {{@priorDelta}};
      
      optimizedhyp = minimize(this.hyp, @gp, -300, ...
        {@infPrior,@infExact,prior}, [], ...
        {@covSEard}, {@likGauss}, this.X, this.Y);
      
      this.hyp=optimizedhyp;
    end
    
    function [f, df] = evaluate(this, xs, bias)
      % return b*mean-(1-b)*sigma
      % xs is a row vector
      
      ks = covSEard(this.hyp.cov, this.X, xs);

      ms = ks'*this.alpha; % mean(xs)
      s2s = covSEard(this.hyp.cov, xs) - ks'*this.beta*ks; % sigma^2(xs)
      ss = sqrt(s2s); % sigma(xs)

      Lambda=exp(-2*this.hyp.cov(1:end-1))'; % Lambda is defined as a row vector
      XxLambda = bsxfun(@times,bsxfun(@minus,this.X,xs),Lambda);

      dms = (this.alpha.*ks)'*XxLambda; % d mean(xs) / dx
      ds2s = -2 * ((this.beta*ks).*ks)'*XxLambda; % d sigma^2(xs) / dx
      dss = 1/(2*ss)*ds2s; % d sigma(xs) / dx

      % for now I assume that the mean function ranges from -5 to 5, and
      % the variance ranges from 0 to exp(hyp.cov(end)). Therefore, in
      % order to normalise them, I have divided the first terms on RHS of
      % the following equations by 10, and have divided the second terms
      % by exp(hyp.cov(end)).
      f=bias*ms/10-(1-bias)*ss/exp(this.hyp.cov(end));
      df=bias*dms/10-(1-bias)*dss/exp(this.hyp.cov(end));
    end
  end
end
