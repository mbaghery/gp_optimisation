% normalization
Y = util.normalise(Y, range);

gpinstance = classgp(X, Y);

sn = util.normalise(0.02, range, true);
gpinstance.uncertainty = log(sn);

gpinstance.mean = {@meanFuns.meanZero};
gpinstance.meanD = {@meanDFuns.meanZeroD};

gpinstance.cov = {@covFuns.covSEard};
gpinstance.covD = {@covDFuns.covSEardD};

% mean function hyperparameters
hyp.mean=[];

% covariance function hyperparameters
%     [log(lambda_1); ...; log(lambda_n); log(sf)]
hyp.cov = [log(1) * ones(noFeatures, 1); log(1)];

gpinstance.optimise(hyp);
