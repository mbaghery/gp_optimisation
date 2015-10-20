% load(filename); % load the training set


% set the hyperparameters
% [log(lambda_1); ...; log(lambda_n); log(sf)]
hyp.cov = [log(1) * ones(noFeatures, 1); log(1)];

% set the uncertainty
sn = util.normalise(0.01, Ymin, Ymax, true);
hyp.lik = log(sn);


% normalization
Y = util.normalise(Y, Ymin, Ymax);

gpinstance = classgp(X, Y);
% Symmetry
% gpinstance.addTrainPoints(-X, Y);

gpinstance.hyp = hyp;

prior.lik = {{@priorDelta}};
gpinstance.inf = {@infPrior,@infExact,prior};
gpinstance.mean = [];
gpinstance.cov = {@covSEard};
gpinstance.lik = {@likGauss};



gpinstance.optimise;
gpinstance.initialise;
