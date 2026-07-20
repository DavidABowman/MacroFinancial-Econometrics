clear all; clc;
%% Load data
data = readmatrix('ECOMNSA.csv'); %1999Q4 - 2023Q3
sales = log(data(:,2));

 %% in-sample fit   
 dates = 1999.75:.25:2023.5;
 quarters = [4,repmat(1:4,1,23),1,2,3]';
 D1 = quarters==1; % Seasonal dummy for Q1
 D4 = quarters==4; % Seasonal dummy for Q4
 T = length(sales); % no. of time periods
 y = sales; % y-vector

 figure
 plot(dates,sales,'LineWidth',1.5)
 title("Log-Transformed Sales Data 1999Q3-2023Q2")
 legend("Log(Sales)", "location", "northwest")
 
% Model S1                
X1 = [ones(T,1) (1:T)' D1];
betaS1 = (X1'*X1)\(X1'*y);
sig2S1 = ((y-X1*betaS1)'*(y-X1*betaS1))/(T-3);
MSES1 = mean((y-X1*betaS1).^2);
MAES1 = mean(abs(y-X1*betaS1));

% Model S2                
X2 = [ones(T,1) (1:T)' D1 D4];
betaS2 = (X2'*X2)\(X2'*y);
sig2S2 = ((y-X2*betaS2)'*(y-X2*betaS2))/(T-4);
MSES2 = mean((y-X2*betaS2).^2);
MAES2 = mean(abs(y-X2*betaS2));

% Model S2                
X3 = [ones(T,1) (1:T)'.^2 D4];
betaS3 = (X3'*X3)\(X3'*y);
sig2S3 = ((y-X3*betaS3)'*(y-X3*betaS3))/(T-3);
MSES3 = mean((y-X3*betaS3).^2);
MAES3 = mean(abs(y-X3*betaS3));

figure
plot(dates,sales,dates,X1*betaS1,dates,X2*betaS2,dates,X3*betaS3,'LineWidth',1.5)
legend('Actual','S1 - Q1','S2 - Q1&Q4','S3 - Q4', 'Location', 'northwest') 


%% Calculate the AIC and BIC in-sample fit
AIC = [MSES1 MSES2 MSES3]*T + 2*[3 4 3]
BIC = [MSES1 MSES2 MSES3]*T + [3 4 3]*log(T)


%% Out-of-sample forecasting excerise
T0 = 65; % Initial training sample period
tend = 81 % Final training sample period
h = 2; % h-step-ahead forecast

syhat = zeros(tend-h-T0+1,3);
ytph = y(T0+h:tend); % observed y_{t+h}
for t = T0:tend-h
yt = y(1:t);
s = (1:t)';
nt = length(s); % sample size
D1t = D1(1:t); D4t = D4(1:t);
%% S1
Xt = [ones(nt,1) s D1t];
beta1 = (Xt'*Xt)\(Xt'*yt);
yhat1 = [1 t+h D4(t+h)]*beta1;
%% S2
Xt = [ones(nt,1) s D1t D4t];
beta2 = (Xt'*Xt)\(Xt'*yt);
yhat2 = [1 t+h D1(t+h) D4(t+h)]*beta2;

%% S3
Xt = [ones(nt,1) s.^3 D4t];
beta3 = (Xt'*Xt)\(Xt'*yt);
yhat3 = [1 (t+h).^2 D4(t+h)]*beta3;
%% store the forecasts
syhat(t-T0+1,:) = [yhat1 yhat2 yhat3];
end


MSFE1 = mean((ytph-syhat(:,1)).^2);
MSFE2 = mean((ytph-syhat(:,2)).^2);
MSFE3 = mean((ytph-syhat(:,3)).^2);

MSFE = [MSFE1 MSFE2 MSFE3]


MAFE1 = mean(abs(ytph-syhat(:,1)));
MAFE2 = mean(abs(ytph-syhat(:,2)));
MAFE3 = mean(abs(ytph-syhat(:,3)));

MAFE = [MAFE1 MAFE2 MAFE3]

%%
fdates = 2016.25:.25:2019.75; % Have to push forward time date by n quarters if h-step increases by n
figure
plot(fdates,ytph, fdates, syhat(:,1), fdates, syhat(:,2), fdates, syhat(:,3), 'LineWidth',1.5)
title("2-Step Ahead Out-Of-Sample Forecast Against Actual")
legend('Actual', 'Q1 Dummy', 'Q1&Q4 Dummy', 'Q4 Dummy & time-cubed', 'Location', 'northwest') 
