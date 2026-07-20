clear all; clc;

% Generate artifical data
T = 1000;
rhotrue = 0.9;
ctrue = .02;
y = zeros(T,1);
sig2 = 0.2;

% initial condition
y(1) = (1-rhotrue)^2/sig2; % Set initial condition for the first element of y

for t = 2:T
    y(t) = ctrue + rhotrue*y(t-1) + sqrt(sig2)*randn;
end

figure
plot(1:T,y)
yline(0,'k--')
xlabel('Time')
ylabel('Y-values')
title('Data Generating Process for AR(1)')

%% OLS estimation of AR(1)
yOLS = y(2:end); % vector of y_2, y_3, ..., y_T
Tols = length(yOLS); % no. of periods
X = [ones(Tols, 1) y(1:end-1)];

% OLS estimator beta
beta = inv(X' * X) *(X' * yOLS) % Calculate OLS estimator for beta

sig2ols =  sum( (yOLS - X*beta).^2 )/(Tols-2)