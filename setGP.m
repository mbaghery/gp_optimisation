load(filename); % load the training set

% normalization
Y = util.normalise(Y, Ymin, Ymax);

% set the hyperparameters
% [log(lambda_1); log(lambda_2); log(sf)]
hyp.cov = [log(1)*ones(noFeatures,1); log(1)];

% uncertainty, factor 10 because y is rescaled to [0..10]
sn = util.normalise(0.05, Ymin, Ymax, true);
hyp.lik = log(sn);


gpinstance = classgp(X,Y);
% Symmetry
% gpinstance.addTrainPoints(-X, Y);

gpinstance.hyp = hyp;
