%% Simulation
clear all;clc;
% Simulate from standard normal distribution
h  = randn(10000,1);
histogram(h)
hmean = mean(h)
hvar = var(h)
% Simulate from a normal distribution
mu = 4;
sig2 = .01;
h = mu + sqrt(sig2)*randn(10000,1);
hist(h)
mean(h)
var(h)

%% Generate artificial data from AR(1) model
T = 1000000; % no. of time periods
phi = 0.9; % AR(1) coefficient
c = .001; % constant coefficient
sig2 = .05; % sigma2 coefficent
y = zeros(T,1); % store artifical data

% set initial condition
y(1) = .01;
for t = 2:T
   y(t) =  c + phi*y(t-1) + sqrt(sig2)*randn;
end

% OLS estimate
ytilde = y(2:end);
X = [ones(T-1,1) y(1:T-1)];
beta = (X'*X)\(X'*ytilde)
sig2hat = (ytilde-X*beta)'*(ytilde-X*beta)/(T-1-2)
