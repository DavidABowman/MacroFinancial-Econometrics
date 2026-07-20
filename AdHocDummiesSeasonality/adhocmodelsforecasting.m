%% Exponential Smoothing methods Forecasting
clear all; clc;
%% Load data
data = readmatrix('ECOMNSA.csv');
sales = log(data(:,2));
 %% in-sample fit   
 dates = 1999.75:.25:2023.5;
 
 y = sales;
 T = length(y);

T0 = 40; % Training sample period
h = 4; % h-step-ahead forecast
store_forecast =  zeros(T-h-T0+1,3);
fdates = dates(T0+h:end);

%% Simple exponential smoothing method
syhat = zeros(T-h-T0+1,1);
ytph = y(T0+h:end); % observed y_{t+h}
alpha = .5;% set values for smoothing parameters
Lt = y(1); 
for t = 2:T-h
newLt = alpha*y(t) + (1-alpha)*(Lt);
yhat = newLt ;
Lt = newLt; % update Lt
if t>= T0 % store the forecasts for t >= T0
syhat(t-T0+1,:) = yhat;
end
end
MSFE1 = mean((ytph-syhat).^2);
store_forecast(:,1) = syhat;

%% Holt-Winters smoothing method
syhat = zeros(T-h-T0+1,1);
ytph = y(T0+h:end); % observed y_{t+h}
alpha = .5; beta = .5; % set values for smoothing parameters
Lt = y(1); bt = y(2) - y(1);
for t = 2:T-h
newLt = alpha*y(t) + (1-alpha)*(Lt+bt);
newbt = beta*(newLt-Lt) + (1-beta)*bt;
yhat = newLt + h*newbt;
Lt = newLt; bt = newbt; % update Lt and bt
if t>= T0 % store the forecasts for t >= T0
syhat(t-T0+1,:) = yhat;
end
end
MSFE2 = mean((ytph-syhat).^2);
store_forecast(:,2) = syhat;

%% Holt-Winters smoothing method with seasonality
s = 4; % Quarterly data
syhat = zeros(T-h-T0+1,1);
ytph = y(T0+h:end); % observed y_{t+h}
alpha = .5; beta = .5; gamma = .5; % set values for smoothing parameters
St = zeros(T-h,1);
Lt = mean(y(1:s)); bt = 0; St(1:4) = y(1:s)/Lt; % initialize
for t = s+1:T-h
newLt = alpha*(y(t) - St(t-s)) + (1-alpha)*(Lt+bt);
newbt = beta*(newLt-Lt) + (1-beta)*bt;
St(t) = gamma*(y(t)-newLt) + (1-gamma)*St(t-s);
yhat = newLt + h*newbt + St(t+h-s);
Lt = newLt; bt = newbt; % update Lt and bt
if t>= T0 % store the forecasts for t >= T0
syhat(t-T0+1,:) = yhat;
end
end
MSFE3 = mean((ytph-syhat).^2);
store_forecast(:,3) = syhat;

MSFE = [MSFE1 MSFE2 MSFE3]

figure
plot(fdates,ytph,'k',fdates,store_forecast(:,1),fdates,store_forecast(:,2),fdates,store_forecast(:,3),'LineWidth',1.5)
legend('Actual Sales','Exp. Smoothing','Holt-Winters','Holt-Winters with Seasonality')