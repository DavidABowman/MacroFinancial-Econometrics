%% GARCH(1,1)
% y_t = c+ phi*y_t-1 + e_t, e_t~N(0,sig2_t),
% sig2_t = alpha0 + alpha1*e_t-1^2 + beta*sig2_t-1,
clear all; clc;
load('USdata.mat')
y = USdata(:,3);
T = length(y);

dates = USdata(:,1);

figure
plot(dates,y)
xlim([dates(1) dates(end)])
yline(0,'k--')
title('US CPI Inflation Rate')

% Log-Likelihood Function
logLikelihood = @(params) arGarchLogLikelihood(params, y);

% Initial Parameter Guesses: [mu, phi, alpha0, alpha1, beta1]
params0 = [0, 0.4, 0.05, 0.1, 0.5];

% Constraints: alpha0 > 0, alpha1 >= 0, beta1 >= 0, alpha1 + beta1 < 1
A = [0, 0, 0, 1, 1]; % alpha1 + beta1 < 1
b = 0.999;
lb = [-Inf, -1, 0, 0, 0]; % Lower bounds
ub = [Inf, 1, Inf, 1, 1]; % Upper bounds

% Optimisation
options = optimoptions('fmincon', 'Display', 'iter', 'Algorithm', 'sqp');
[params_est, negLogLik] = fmincon(logLikelihood, params0, A, b, [], [], lb, ub, [], options);

muhat = params_est(1);
phihat = params_est(2);
alpha0hat = params_est(3);
alpha1hat = params_est(4);
betahat = params_est(5);

err = zeros(T, 1); % Residuals
sig2_that = zeros(T,1);
sig2_that(1) = alpha0hat/(1-alpha1hat);

%% Plot sig2_t
for t = 2:T
err(t) = y(t) - muhat - phihat*y(t-1);
sig2_that(t) = alpha0hat + alpha1hat*err(t-1).^2 + betahat*sig2_that(t-1);
end

%% Matlab in-built function
% Specify AR(1)-GARCH(1,1) Model
model = arima('Constant', NaN, 'AR', NaN, 'Variance', garch(1, 1));

% Estimate the Model
[estModel, estParamCov, logL] = estimate(model, y);

% Visualise Conditional Variance
[ resid sig2_that1]= infer(estModel, y); % Inferred conditional variances

figure
plot(dates,sig2_that,dates,sig2_that1)
xlim([dates(1) dates(end)])
title('Conditional Variances')
legend('MLE','Matlab')



function negLogLik = arGarchLogLikelihood(params, y)
    % Extract parameters
    mu = params(1);
    phi = params(2);
    alpha0 = params(3);
    alpha1 = params(4);
    beta1 = params(5);
    
    % Ensure positivity constraints
    if alpha0 <= 0 || alpha1 < 0 || beta1 < 0 || (alpha1 + beta1) >= 1
        negLogLik = Inf;
        return;
    end
    
    % Number of observations
    T = length(y);
    
    % Initialise conditional variance
    h = zeros(T, 1);
    epsilon = zeros(T, 1);
    h(1) = alpha0/(1-alpha1); % Initial variance (unconditional)
    
    % Compute epsilon and h_t recursively
    for t = 2:T
        epsilon(t) = y(t) - mu - phi * y(t-1);
        h(t) = alpha0 + alpha1 * epsilon(t-1)^2 + beta1 * h(t-1);
    end
    
    % Log-likelihood calculation
    logLik = -0.5 * sum(log(h) + (epsilon.^2 ./ h));
    negLogLik = -logLik; % Negative log-likelihood for minimisation
end