%% Linear regression example code
clear all; clc;
% Load data
[data, var] = xlsread('london.xlsx','Sheet1');
% define few things
k = 2 ; % no. of parameters in the model
y = data(:,1); % dependent variable
n = length(y); % no. of observations
X = [ones(n,1) log(data(:,7)) ]; % regressor matrix
% OLS estimator or beta
beta = (X'*X)\(X'*y)
% beta = inv(X'*X)*(X'*y); % Another way
% OLS estimator for sigma^2
sig2 = (y-X*beta)'*(y-X*beta)/(n-k)

%% Linear regression using matlab in-built function (cheat way)
beta1 = regress(y,X) % another cheat way of getting OLS estimator for beta
X1 = log(data(:,7));
model1 = fitlm(X1,y)
anova(model1,'summary') % ANOVA table



