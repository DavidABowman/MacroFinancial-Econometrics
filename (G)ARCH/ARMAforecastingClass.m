%% OUT OF SAMPLE FORECASTING
% I believe this class is all you need for both Question 3 and Question 4
% in the Practical / Mid-term assessment 
clear all; clc;
%% Load data
 %url = 'https://fred.stlouisfed.org/';
 %c = fred(url);
 %data = fetch(c,'DPCCRV1Q225SBEA');
 data = readmatrix('USdata.xlsx',"Sheet","Sheet2");
  
dates = data(:,1);

 y = data(:,3); % Load Core PCE Inflation
 T = length(y);
 T0 = find(dates==2005); % training sample period
 Tend = find(dates==2022.75)
 p = 2; % AR lags
 q = 1 ; % MA lags
 %dates = 1959.25:.25:2024.75;
 %T0 = 233
 %Tend = 255

 h = 1; % h-step-ahead forecast
 ytph = y(T0+h:Tend); % observed y_{t+h}
yhatAR = zeros(Tend-h-T0+1,1); %% AR(1) forecasts
yhatMA = zeros(Tend-h-T0+1,1); %% MA(1) forecasts
yhatARMA = zeros(Tend-h-T0+1,1); %% ARMA(1,1) forecasts
yhatRW = zeros(Tend-h-T0+1,1); %% random walk forecasts

MSFE_AR_record = zeros(Tend-h-T0+1,1);
MSFE_MA_record = zeros(Tend-h-T0+1,1);
MSFE_ARMA_record = zeros(Tend-h-T0+1,1);
MSFE_RW_record = zeros(Tend-h-T0+1,1);

fdates = dates(T0+h:Tend);
 for t = T0:Tend-h
 yt = y(1:t); 
%% AR(p)
ARMdl = arima(p,0,0);
EstARMdl = estimate(ARMdl,yt,Display="off");

%% MA(q)
MAMdl = arima(0,0,q);
EstMAMdl = estimate(MAMdl,yt,Display="off");
MAerror = infer(EstMAMdl,yt);

%% ARMA(p,q) % Question 3 - data at row 233(?) to row 244
ARMAMdl = arima(p,0,q);
EstARMAMdl = estimate(ARMAMdl,yt,Display="off");
ARMAerror = infer(EstARMAMdl,yt);

% y_T+1 = c + phi_1*y_T + pi2*y_T-1 % One-Step Ahead
% y_T+2 = c + phi_1*y_T+1 + pi2*y_T % Two-Step Ahead
% y_T+3 = c + phi_1*y_T+2 + pi2*y_T+1 % Three-Step Ahead
% y_T+4 = c + phi_1*y_T+3 + pi2*y_T+2 % Four-Step Ahead


%% store the forecasts
if h == 1
    yhatAR(t-T0+1,:) = EstARMdl.Constant + EstARMdl .AR{1}*yt(end) + EstARMdl .AR{2}*yt(end-1); % AR(2)??
elseif  h == 2
        yhatAR(t-T0+2,:) = EstARMdl.Constant + EstARMdl .AR{1}*yt(end) + EstARMdl .AR{2}*yt(end-1) + EstARMdl .AR{2}*yt(end-2); % AR(2)
end
yhatMA(t-T0+1,:) = EstMAMdl.Constant + EstMAMdl.MA{1}*MAerror(end);  % MA(1)
yhatARMA(t-T0+1,:) = EstARMAMdl.Constant + EstARMAMdl.AR{1}*yt(end) + EstARMAMdl.MA{1}*ARMAerror(end); % ARMA(1,1)
yhatRW(t-T0+1,:) = yt(end); % Random walk


MSFE_AR_record(t-T0+1,:) = mean((ytph(t-T0+1,:)-yhatAR(t-T0+1,:)).^2)
MSFE_MA_record(t-T0+1,:) = mean((ytph(t-T0+1,:)-yhatMA(t-T0+1,:)).^2)
MSFE_ARMA_record(t-T0+1,:) = mean((ytph(t-T0+1,:)-yhatARMA(t-T0+1,:)).^2)
MSFE_RW_record(t-T0+1,:) = mean((ytph(t-T0+1,:)-yhatRW(t-T0+1,:)).^2)

 end

MSFE_AR = mean((ytph-yhatAR).^2)
MSFE_MA = mean((ytph-yhatMA).^2)
MSFE_ARMA = mean((ytph-yhatARMA).^2)
MSFE_RW = mean((ytph-yhatRW).^2)

%%

figure
plot(fdates,ytph,'b',fdates,yhatAR, 'LineWidth',1.5)
title("Out-of-Sample Forecast Values")
legend('Core CPI','AR(1)',"Location","southeast")

figure
plot(fdates,ytph,'b',fdates,yhatAR,fdates,yhatMA,fdates,yhatARMA,fdates,yhatRW, "r", 'LineWidth',1.5)
legend('Core CPI','AR(1)','MA(1)','ARMA(1,1)','Random Walk',"Location","southeast")

figure
plot(fdates,MSFE_AR_record,fdates,MSFE_MA_record,fdates,MSFE_ARMA_record,fdates,MSFE_RW_record, "r", 'LineWidth',1.5)
legend('MSFE-AR(1)','MSFE-MA(1)','MSFE-ARMA(1,1)','MSFE-RW',"Location","northeast")
