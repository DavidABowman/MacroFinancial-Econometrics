clear all; clc;

data = readmatrix('UKdata.xlsx');
ldata = diff(log(data))*100; % log-difference growths

GDP = ldata(:,2); % extract GDP
pi = ldata(:,3); % extract CPI

T = length(GDP);% no. of time periods

figure
subplot(2,1,1)
plot(1:T,GDP)
xlabel('Time Periods');
ylabel('GDP Growth Rate (%)');
title('GDP Growth Over Time');
grid on;

% figure
subplot(2,1,2)
plot(1:T,pi)
xlabel('Time Periods');
ylabel('CPI Growth Rate (%)');
title('CPI Growth Over Time');
grid on;

%% Linear regression
% define few things
k = 2 ; % no. of parameters in the model
y = pi(2:end); % dependent variable
n = length(y); % no. of observations
X = [ones(n,1) GDP(1:end-1) ]; % regressor matrix
% OLS estimator or beta
beta = (X'*X)\(X'*y)
% beta = inv(X'*X)*(X'*y); % Another way
% OLS estimator for sigma^2
sig2 = (y-X*beta)'*(y-X*beta)/(n-k)

%% fitted values
yhat = X*beta;

figure
plot(1:n,yhat,1:n,y)
legend('Fitted Values','Actual')
xlabel('Time Periods');

% MSE
MSE = mean((y-X*beta).^2)
MAE = mean(abs(y-X*beta))

% AIC and BIC
AIC = MSE*T + 2*k;
BIC = MSE*T + k*log(T)



%% Question 4