% covariance function hyperparameters
%     [log(lambda_1);
%       .;
%       .;
%       .;
%      log(lambda_n);
%      log(sf)]
hyp.cov = [log(1) * ones(noFeatures, 1); log(1)];

% mean function hyperparameters
hyp.mean=[];


% normalization
Y = util.normalise(Y, Ymin, Ymax);

gpinstance = classgp(X, Y);

sn = util.normalise(0.01, Ymin, Ymax, true);
gpinstance.uncertainty = log(sn);

gpinstance.mean = {@meanFuns.meanZero};
gpinstance.cov = {@covFuns.covSEard};
gpinstance.meanD = {@meanDFuns.meanZeroD};
gpinstance.covD = {@covDFuns.covSEardD};


gpinstance.infer(gpinstance.optimise(hyp));
