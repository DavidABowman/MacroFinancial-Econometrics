%% ARCH(1)
% y_t = e_t, e_t~N(0,sig2_t),
% sig2_t = alpha0 + alpha1*y_t-1^2,
clear all; clc;
load('SP500.mat')
y = SP500;
T = length(y);

dates = datetime('Jan-1960'):calmonths(1):datetime('Sep-2024');

figure
plot(dates,y)
yline(0,'k--')
title('S&P 500')

% Initial parameter guesses
initParams = [0.1, 0.1]; % [alpha0, alpha1]
logLikelihood = @(params) archLogLikelihood(params, y);

% Optimise using fminunc
options = optimoptions('fminunc', 'Display', 'iter', 'Algorithm', 'quasi-newton');
[estParams, negLogL] = fminunc(logLikelihood, initParams, options);

alpha0hat = estParams(1);
alpha1hat = estParams(2);

%% Plot sig2_t
sig2_that = zeros(T,1);
sig2_that(1) = alpha0hat/(1-alpha1hat);
sig2_that(2:end) = alpha0hat + alpha1hat*y(1:end-1).^2;


%% Matlab in-built function
% Specify ARCH(1) Model
model = garch('Constant', NaN, 'ARCHLags', 1);

% Estimate the Model
[estModel, estParams, logL] = estimate(model, y);
sig2_that1 = infer(estModel, y); % Inferred conditional variances


figure
plot(dates,sig2_that,dates,sig2_that1)
title('Conditional Variances')
legend('MLE','Matlab')

function nll = archLogLikelihood(params, y)
    alpha0 = params(1);
    alpha1 = params(2);
    n = length(y);
    h = zeros(n,1); % Conditional variance
    h(1) = alpha0/(1-alpha1); % Initial variance (assume unconditional variance)

    % Compute h_t for t = 2 to n
    for t = 2:n
        h(t) = alpha0 + alpha1 * y(t-1)^2;
    end

    % Negative log-likelihood
    nll = 0.5 * sum(log(2 * pi) + log(h) + (y).^2 ./ h);
end