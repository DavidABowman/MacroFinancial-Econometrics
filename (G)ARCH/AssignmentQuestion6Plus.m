%% OUT OF SAMPLE FORECASTING
clear all; clc;
%% Load data
data = readmatrix("AssignmentData.xlsx", "Sheet","Sheet3");

dates = data(:,1);

y = data(:,2); % Load Quarterly CPI Inflation Rate
T = length(y);
Q = 6; % Question

T0 = find(dates==2014.75); % Training Sample Period
Tend = find(dates==2018.75);
 
p = 2; % AR lags
q = 2; % MA lags
h = 1; % H-step-ahead forecast

ytph = y(T0+h:Tend); % Observed y_{t+h}
yhatAR = zeros(Tend-h-T0+1,1); %% AR(1) Forecast
yhatMA = zeros(Tend-h-T0+1,1); %% MA(1) Forecast
yhatARMA = zeros(Tend-h-T0+1,1); %% ARMA(p,q) Forecast
yhatRW = zeros(Tend-h-T0+1,1); %% Random Walk Forecast

MSFE_AR_record = zeros(Tend-h-T0+1,1);
MSFE_MA_record = zeros(Tend-h-T0+1,1);
MSFE_ARMA_record = zeros(Tend-h-T0+1,1);
MSFE_RW_record = zeros(Tend-h-T0+1,1);

MAFE_AR_record = zeros(Tend-h-T0+1,1);
MAFE_MA_record = zeros(Tend-h-T0+1,1);
MAFE_ARMA_record = zeros(Tend-h-T0+1,1);
MAFE_RW_record = zeros(Tend-h-T0+1,1);


fdates = dates(T0+h:Tend);

for t = T0:Tend-h
     yt = y(1:t); 
     
     %% AR(1)
     ARMdl = arima(1,0,0); % Manually set AR(1) model here, though normally ARIMA models follow (p,I,q), ARMA (p,0,q)
     EstARMdl = estimate(ARMdl,yt,Display="off");
     
     %% MA(1)
     MAMdl = arima(0,0,1); % Manually set MA(1) model here
     EstMAMdl = estimate(MAMdl,yt,Display="off");
     MAerror = infer(EstMAMdl,yt);
     
     
     %% ARMA(2,2) 
     ARMAMdl = arima(p,0,q);
     EstARMAMdl = estimate(ARMAMdl,yt,Display="off");
     ARMAerror = infer(EstARMAMdl,yt);
     
     % y_T+1 = c + phi_1*y_T + pi2*y_T-1 % One-Step Ahead
     % y_T+2 = c + phi_1*y_T+1 + pi2*y_T % Two-Step Ahead
     % y_T+3 = c + phi_1*y_T+2 + pi2*y_T+1 % Three-Step Ahead
     % y_T+4 = c + phi_1*y_T+3 + pi2*y_T+2 % Four-Step Ahead

    %% store the forecasts
   
     yhatAR(t-T0+1,:) = EstARMdl.Constant + EstARMdl .AR{1}*yt(end); 
     yhatMA(t-T0+1,:) = EstMAMdl.Constant + EstMAMdl.MA{1}*MAerror(end);  % MA(1)
     yhatARMA(t-T0+1,:) = EstARMAMdl.Constant + EstARMAMdl.AR{1}*yt(end) + EstARMAMdl.AR{2}*yt(end-1) + EstARMAMdl.MA{1}*ARMAerror(end) + EstARMAMdl.MA{2}*ARMAerror(end-1);    
     yhatRW(t-T0+1,:) = yt(end); % Random Walk Forecast - "Benchmark" Model to beat 


     MSFE_AR_record(t-T0+1,:) = mean((ytph(t-T0+1,:)-yhatAR(t-T0+1,:)).^2);
     MAFE_AR_record(t-T0+1,:) = mean(abs(ytph(t-T0+1,:)-yhatAR(t-T0+1,:)));
     MSFE_MA_record(t-T0+1,:) = mean((ytph(t-T0+1,:)-yhatMA(t-T0+1,:)).^2);
     MAFE_MA_record(t-T0+1,:) = mean(abs(ytph(t-T0+1,:)-yhatMA(t-T0+1,:)));    
     MSFE_ARMA_record(t-T0+1,:) = mean((ytph(t-T0+1,:)-yhatARMA(t-T0+1,:)).^2);
     MAFE_ARMA_record(t-T0+1,:) = mean(abs(ytph(t-T0+1,:)-yhatARMA(t-T0+1,:)));
     MSFE_RW_record(t-T0+1,:) = mean((ytph(t-T0+1,:)-yhatRW(t-T0+1,:)).^2);
     MAFE_RW_record(t-T0+1,:) = mean(abs(ytph(t-T0+1,:)-yhatRW(t-T0+1,:)));


end

MSFE_AR = mean((ytph-yhatAR).^2)
MAFE_AR = mean(abs(ytph-yhatAR))
MSFE_MA = mean((ytph-yhatMA).^2)
MAFE_MA = mean(abs(ytph-yhatMA))
MSFE_ARMA = mean((ytph-yhatARMA).^2)
MAFE_ARMA = mean(abs(ytph-yhatARMA))
MSFE_RW = mean((ytph-yhatRW).^2)
MAFE_RW = mean(abs(ytph-yhatRW))

%%
MSFE = [MSFE_AR MSFE_MA MSFE_ARMA MSFE_RW]
MAFE = [MAFE_AR MAFE_MA MAFE_ARMA MAFE_RW]


%%

figure
plot(fdates,ytph,'b',fdates,yhatAR,fdates,yhatMA,fdates,yhatARMA, "r", fdates, yhatRW, 'LineWidth',1.5)
title("Out-of-Sample Forecast Values")
legend('Core CPI', 'AR(1)', 'MA(1)', sprintf("ARMA(%d, %d)", p, q), 'Random Walk', 'Location', 'southeast')

figure
plot(fdates,MSFE_AR_record,fdates,MSFE_MA_record,fdates,MSFE_ARMA_record,"r", fdates,MSFE_RW_record, 'LineWidth',1.5)
title("1 Step Ahead MSFE Values")
legend('MSFE-AR(1)','MSFE-MA(1)',sprintf("MSFE-ARMA(%d, %d)", p, q), "Random Walk","Location","northeast")

figure
plot(fdates,MAFE_AR_record,fdates,MAFE_MA_record,fdates,MAFE_ARMA_record, "r", fdates,MAFE_RW_record, 'LineWidth',1.5)
title("1 Step Ahead MAFE Values")
legend('MAFE-AR(1)','MAFE-MA(1)',sprintf("MAFE-ARMA(%d, %d)", p, q), "Random Walk","Location","northeast")
