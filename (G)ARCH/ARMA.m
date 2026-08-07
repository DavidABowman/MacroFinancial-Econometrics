%% IN_SAMPLE FIT
clear all; clc;
%% Load data
% url = 'https://fred.stlouisfed.org/';
% c = fred(url);
% data = fetch(c,'DPCCRV1Q225SBEA');
data = readmatrix('USdata.xlsx',"Sheet","Sheet2");
y = data(:,3); % Load Core PCE Inflation
 T = length(y);
 dates = 1959.25:.25:2023.5;

 % arima(p,0,q) - p-th order AR lags and q-th order MA lags
 %% AR(1) model
 Mdl = arima(1,0,0);
 EstMdl = estimate(Mdl,y);
 Resid = infer(EstMdl,y); % calculate the residuals
 yhat1 =  y - Resid; % fitted values
 BIC1 = mean((Resid.^2))*T + 2*log(T)

  %% MA(1) model
 Mdl = arima(0,0,1);
 EstMdl = estimate(Mdl,y);
 Resid = infer(EstMdl,y);
 yhat2 = y - Resid ; % fitted values
 BIC2 = mean((Resid.^2))*T + 2*log(T)

 %% ARMA(1,1) model
 Mdl = arima(1,0,1);
 EstMdl = estimate(Mdl,y);
 Resid = infer(EstMdl,y);
 yhat3 =  y - Resid; % fitted values
 BIC3 = mean((Resid.^2))*T + 3*log(T)

 % In-sample plot
 figure
 plot(dates,y,'k',dates,yhat1,dates,yhat2,dates,yhat3,'LineWidth',1.5)
 legend('Core PCE','AR(1)','MA(1)','ARMA(1,1)')

