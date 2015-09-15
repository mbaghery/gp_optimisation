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
  end
  
  methods (Access = public)
    function obj = classgp(trainX, trainY)
      obj.X = trainX;
      obj.Y = trainY;
    end
    
    function initialise(this)
      K = covSEard(this.hyp.cov, this.X);
      
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
      this.Y=[this.Y; ys];
    end
    
    function [x, y] = getTrainSet(this)
      x=this.X;
      y=this.Y;
    end
    
    function [m, s, dm, ds] = predict(this, xs)
      % xs is a matrix whose rows are test points
      
      ks = covSEard(this.hyp.cov, this.X, xs)';

      % mean(xs)
      m = ks*this.alpha;

      % sigma^2(xs)
      s2 = exp(2*this.hyp.cov(end)) - sum((ks*this.beta).*ks,2);

      % sigma(xs)
      s = sqrt(s2);
      
      
      if (nargout==4)
        dm=zeros(size(xs));
        ds=zeros(size(xs));
        
        % matrix of correlation lengths as a row vector
        Lambda=exp(-2*this.hyp.cov(1:end-1))';
        
        for i=1:size(xs,1)
          XxLambda = bsxfun(@times,bsxfun(@minus,this.X,xs(i,:)),Lambda);

          % d mean(xs) / dx
          dm(i,:) = (ks(i,:).*this.alpha') * XxLambda;
          
          % d sigma^2(xs) / dx
          ds2 = -2 * ((this.beta*ks(i,:)')'.*ks(i,:)) * XxLambda;
          
          % d sigma(xs) / dx
          ds(i,:) = ds2 / (2*s(i));
        end
      end
      
    end
    
    function optimise(this)
      % optimise the hyperparameters
      prior.lik = {{@priorDelta}};
      
      optimizedhyp = minimize(this.hyp, @gp, -300, ...
        {@infPrior,@infExact,prior}, [], ...
        {@covSEard}, {@likGauss}, this.X, this.Y);
      
      this.hyp=optimizedhyp;
    end
    
    function [f, df] = evalAus(this, xs, bias)
      % return b*mean-(1-b)*sigma
      % xs is a row vector
      
%       ks = covSEard(this.hyp.cov, this.X, xs);
% 
%       ms = ks'*this.alpha; % mean(xs)
%       s2s = covSEard(this.hyp.cov, xs) - ks'*this.beta*ks; % sigma^2(xs)
%       ss = sqrt(s2s); % sigma(xs)
% 
%       Lambda=exp(-2*this.hyp.cov(1:end-1))'; % Lambda is defined as a row vector
%       XxLambda = bsxfun(@times,bsxfun(@minus,this.X,xs),Lambda);
% 
%       dms = (this.alpha.*ks)'*XxLambda; % d mean(xs) / dx
%       ds2s = -2 * ((this.beta*ks).*ks)'*XxLambda; % d sigma^2(xs) / dx
%       dss = 1/(2*ss)*ds2s; % d sigma(xs) / dx

      [m,s,dm,ds] = this.predict(xs);

      % for now I assume that the mean function ranges from -5 to 5, and
      % the variance ranges from 0 to exp(hyp.cov(end)). Therefore, in
      % order to normalise them, I have divided the first terms on RHS of
      % the following equations by 10, and have divided the second terms
      % by exp(hyp.cov(end)).
      f=bias*m/10 - (1-bias)*s/exp(this.hyp.cov(end));
      df=bias*dm/10 - (1-bias)*ds/exp(this.hyp.cov(end));
    end
    
    function [f, df] = evalMe(this, xs)
      [m,s,dm,ds] = this.predict(xs);
      
      eta = min(this.Y);
      
      f = m + (eta/2-m/2)*erfc((eta-m)/(sqrt(2)*s)) - ...
        s/(2*pi)*exp(-(eta-m)^2/(2*s^2));
      
      df = (1-1/2*erfc((eta-m)/(sqrt(2)*s)))*dm - ...
        -exp(-(eta-m)^2/(2*s^2))/sqrt(2*pi)*ds;
    end
  end
end
