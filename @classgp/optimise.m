function [hyp, l] = optimise(this)
  % optimise the hyperparameters
  
  for i = 1:20
    hyp.mean = log(10 * rand(size(this.hyp.mean)));
    hyp.cov = log(10 * rand(size(this.hyp.cov)));
    [hypvec(i), lvec(i)] = aux(hyp);
    
    disp(['-log(Likelihood) = ' num2str(lvec(i))]);
  end
  
  disp('---');
  
  % This line is necessary for both methods to update all private
  % variables in classgp.
  [~,idx] = min(lvec);
  [l,~,~] = this.infer(hypvec(idx));
  
  disp(['-log(Likelihood) = ' num2str(l)]);
  
  
  function [hyp, l] = aux(hyp)
    problem.x0 = [hyp.mean; hyp.cov];
    problem.solver = 'fmincon';
    problem.options = optimoptions('fmincon', ...
      'GradObj', 'on', ...
      'Hessian','on', ...
      'Algorithm', 'trust-region-reflective', ...
      'MaxIter', 100, ...
      'Display', 'none');

    problem.objective = @(x) this.infer( ...
      struct('mean',x(1:length(hyp.mean)), ...
             'cov' ,x(length(hyp.mean)+1:end)) );

    [out, l] = fmincon(problem);

    hyp.mean = out(1:length(hyp.mean));
    hyp.cov = out(length(hyp.mean)+1:end);  
  end

end
