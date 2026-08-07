clear all; clc;
%% Load data
 url = 'https://fred.stlouisfed.org/';
 c = fred(url);
 data = fetch(c,'DPCCRV1Q225SBEA');
 y = data.Data(:,2); % Load Core PCE Inflation
 T = length(y);
 dates = 1959.25:.25:2023.5;

%% MLE MA(1) model

%% Using a Grid search set sigma^2 = 1;
ngrid = 300;
psi_grid = linspace(.2,1,ngrid);
ll = zeros(ngrid,1); % store loglikehood
for v = 1:ngrid
ll(v) = -loglike_MA1([1 psi_grid(v)],y);
end

maxll = max(ll)
MLEpsi =  psi_grid(find(ll==max(ll)))

figure
plot(psi_grid,ll)
xline(MLEpsi)

%% Using numerical optimsation
% sigma^2 = 1 and find psi
f = @(psi) loglike_MA1([1 psi],y);
[thetaMLE1 Qmax1] = fminbnd(f,0,1)

% sigma^2 and psi are unknowns
g = @(x) loglike_MA1(x,y);
%% starting values: sigma^2 = .5 and psi = .7
[thetaMLE2 Qmax2] = fminsearch(g,[.5 .7])

%% ARMA(1,1)
yt = y(2:end);
T = length(yt);
X = [ones(T,1) y(1:end-1)];
betaols = (X'*X)\(X'*yt);
g = @(x) loglike_ARMA(x,y);
%% starting values: sigma^2 = .5, psi = .7, c and phi are OLS estimates.
[thetaMLE3 Qmax3] = fminsearch(g,[.5 .7 betaols'])

Mdl = arima(1,0,1);
EstMdl = estimate(Mdl,y)