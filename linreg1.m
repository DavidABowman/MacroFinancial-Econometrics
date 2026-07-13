%% Linear regression example code
clear all; clc;
% Load data
[data, var] = xlsread('london.xlsx','Sheet1');
% define few things
k = 2 ; % no. of parameters in the model
n = size(data,1); % no. of observations
X = [ones(n,1) log(data(:,7)) ]; % regressor matrix

% set storage for beta and sigma2
store_beta = zeros(k,6);
store_sig2  = zeros(1,6);

for i = 1:6
y = data(:,i); % dependent variable
% OLS estimator or beta
beta = (X'*X)\(X'*y);
store_beta(:,i) = beta;
% beta = inv(X'*X)*(X'*y); % Another way
% OLS estimator for sigma^2
store_sig2(:,i) = (y-X*beta)'*(y-X*beta)/(n-k);
end

store_beta 
store_sig2

%% Linear regression using matlab in-built function (cheat way)
store_beta_1 = zeros(k,6);
store_sig2_1  = zeros(1,6);
X1 = log(data(:,7));
parfor i = 1:6
y = data(:,i);
model1 = fitlm(X1,y);
store_beta_1(:,i) = table2array(model1.Coefficients(:,1));
store_sig2_1(:,i)= model1.MSE;
end

store_beta_1
store_sig2_1 

