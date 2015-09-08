classdef classgp < handle
  %CLASSGP Gaussian Process class
  %   Detailed explanation goes here
  
  properties (Access = protected)
    N; % no. of training cases
    
    % the following four matrices are stored to prevent being calculated
    % each time for better efficiency
    alpha;
    beta;
    Lambda;
    K;
  end
  
  properties (Access = public)
    hyp;
    mean;
    cov;
    lik;
    inf;
    X;
    Y;
  end
  
  methods
    function initialise(this)
      this.optimizeMe;
      
      this.N = length(this.Y);
      this.K = feval(this.cov{:}, this.hyp.cov, this.X);
      
      sn2 = exp(2*this.hyp.lik); % this line is possible because the liklihood function is Gaussian
%       L = chol(this.K+sn2*eye(this.N));
%       this.beta = solve_chol(L,eye(this.N));
      L = chol(this.K/sn2 + eye(this.N));
      this.beta = solve_chol(L,eye(this.N))/sn2;
      this.alpha = this.beta*this.Y;
      this.Lambda=exp(-2*this.hyp.cov(1:end-1))'; % note that Lambda is defined as a row vector
    end
    
    function addPoint(this, xs, ys)
      this.X=[this.X; xs];
      this.Y=[this.Y; ys];

      this.initialise;
    end
    
    function [f,df] = evaluate(this, xs, bias)
      % return b*mean-(1-b)*sigma
      % xs is a row vector
      
      ks = feval(this.cov{:}, this.hyp.cov, this.X, xs);

      ms = ks'*this.alpha; % mean(xs)
      s2s = feval(this.cov{:}, this.hyp.cov, xs) - ks'*this.beta*ks; % sigma^2(xs)
      ss = sqrt(s2s); % sigma(xs)

      XxLambda = bsxfun(@times,bsxfun(@minus,this.X,xs),this.Lambda);

      dms = (this.alpha.*ks)'*XxLambda; % d mean(xs) / dx
      ds2s = -2 * ((this.beta*ks).*ks)'*XxLambda; % d sigma^2(xs) / dx
      dss = 1/(2*ss)*ds2s; % d sigma(xs) / dx

      % for now I assume that the mean function ranges from 0 to 1, and the
      % variance ranges from 0 to exp(hyp.cov(end)). Therefore, in order to
      % normalise them, I haven't changed the first terms on RHS of the
      % following equations but have divided the second terms by
      % exp(hyp.cov(end)).
      f=bias*ms-(1-bias)*ss/exp(this.hyp.cov(end));
      df=bias*dms-(1-bias)*dss/exp(this.hyp.cov(end));
    end
    
%     function plotMe(this)
%       % this function works only if the number of features is less than 2
%     end
  end
  
  methods (Access = protected)
    function optimizeMe(this)
      % optimize the hyperparameters
      optimizedhyp = minimize(this.hyp, @gp, -300, this.inf, this.mean, ...
        this.cov, this.lik, this.X, this.Y);
      this.hyp=optimizedhyp;
    end
  end
end
