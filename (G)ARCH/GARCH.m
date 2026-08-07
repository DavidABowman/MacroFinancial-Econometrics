%% GARCH(1,1)
% y_t = e_t, e_t~N(0,sig2_t),
% sig2_t = alpha0 + alpha1*y_t-1^2 + beta*sig2_t-1,
clear all; clc;
load('SP500.mat')
y = SP500;
T = length(y);

dates = datetime('Jan-1960'):calmonths(1):datetime('Sep-2024');

% Log-likelihood function
logLikelihood = @(params) garchLogLikelihood(params, y);

% Initial guesses for parameters
params0 = [ 0.1, 0.1, 0.5]; % [mu, alpha0, alpha1, beta1]

% Constraints: alpha0 > 0, alpha1 >= 0, beta1 >= 0, alpha1 + beta1 < 1
A = [0, 1, 1]; % alpha1 + beta1 < 1
b = 0.999;
lb = [ 0, 0, 0]; % Lower bounds
ub = [ Inf, 1, 1]; % Upper bounds

% Optimisation using fmincon
options = optimoptions('fmincon', 'Display', 'iter', 'Algorithm', 'sqp');
[params_est, negLogLik] = fmincon(logLikelihood, params0, A, b, [], [], lb, ub, [], options);

alpha0hat = params_est(1);
alpha1hat = params_est(2);
betahat = params_est(3);

%% Plot sig2_t
sig2_that = zeros(T,1);
sig2_that(1) = alpha0hat/(1-alpha1hat);

for t = 2:T
sig2_that(t) = alpha0hat + alpha1hat*y(t-1).^2 + betahat*sig2_that(t-1);
end

%% Matlab in-built function
Mdl = garch(1,1);
EstMdl = estimate(Mdl,y);
sig2_that1 = infer(EstMdl, y); % Inferred conditional variances

figure
plot(dates,sig2_that,dates,sig2_that1)
title('Conditional Variances')
legend('MLE','Matlab')

% Supporting function: Log-likelihood calculation
function negLogLik = garchLogLikelihood(params, y)
    % Extract parameters
    alpha0 = params(1);
    alpha1 = params(2);
    beta1 = params(3);
    
    % Ensure positivity constraints
    if alpha0 <= 0 || alpha1 < 0 || beta1 < 0 || (alpha1 + beta1) >= 1
        negLogLik = Inf;
        return;
    end
    
    % Number of observations
    T = length(y);
    
    % Initialise conditional variance
    h = zeros(T,1);
    epsilon = y ; % Residuals
    h(1) = alpha0/(1-alpha1); % Initial variance (unconditional)
    
    % Compute h_t recursively
    for t = 2:T
        h(t) = alpha0 + alpha1 * epsilon(t-1)^2 + beta1 * h(t-1);
    end
    
    % Log-likelihood calculation
    logLik = -0.5 * sum(log(h) + (epsilon.^2 ./ h));
    negLogLik = -logLik; % Negative log-likelihood for minimisation
end