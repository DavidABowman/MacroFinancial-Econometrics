%% IN_SAMPLE FIT
clear all; clc;
%% Load data
data = readmatrix('AssignmentData.xlsx',"Sheet","Sheet3")
;
y = data(:,2); % Load PCE Inflation
T = length(y);
dates = 1970.00:.25:2019.75;

 % arima(p,0,q) - p-th order AR lags and q-th order MA lags

 %% ARMA(2,2) model
 Mdl = arima(2,0,2);
 EstMdl = estimate(Mdl,y);
 Resid = infer(EstMdl,y);
 yhat3 =  y - Resid; % fitted values
 BIC3 = mean((Resid.^2))*T + 3*log(T)

 % In-sample plot
 figure
 plot(dates,y,'r',dates,yhat3, 'b', 'LineWidth',1.5)
 title("Q2 In-Sample ARMA(2,2) Forecast Values")
 legend('Core PCE','ARMA(2,2)')

