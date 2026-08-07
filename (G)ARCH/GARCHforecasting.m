clear all; clc;
%% Load data
 load('USdata.mat')
 y = USdata(:,3); % Load Core PCE Inflation
 T = length(y);    
 dates = USdata(:,1);
 T0 = find(dates==1999.75); % training sample period
 h = 1; % h-step-ahead forecast
 ytph = y(T0+h:end); % observed y_{t+h}
yhatAR = zeros(T-h-T0+1,1); %% AR(1) forecasts
yhatGARCH1 = zeros(T-h-T0+1,1); %% AR(1)-GARCH(1,1) forecasts
yhatGARCH2 = zeros(T-h-T0+1,1); %% AR(1)-GARCH(2,2) forecasts
yhatRW = zeros(T-h-T0+1,1); %% random walk forecasts
fdates = dates(T0+h:end);
 for t = T0:T-h
 yt = y(1:t); 
%% AR(q)
ARMdl = arima(1,0,0);
EstARMdl = estimate(ARMdl,yt,Display="off");

%% AR(1)-GARCH(1,1)
ARGARCH = arima('Constant', NaN, 'AR', NaN, 'Variance', garch(1, 1));
% Estimate the Model
[ARGARCHModel, estParamCov, logL] = estimate(ARGARCH, y,Display="off");

%% AR(1)-GARCH(2,2)
ARGARCH1 = arima('Constant', NaN, 'AR', NaN, 'Variance', garch(2, 2));
% Estimate the Model
[ARGARCHModel1, estParamCov, logL] = estimate(ARGARCH1, y,Display="off");

%% store the forecasts one-step ahead forecast
yhatAR(t-T0+1,:) = EstARMdl.Constant + EstARMdl .AR{1}*yt(end); % AR(1)
yhatGARCH1(t-T0+1,:) = ARGARCHModel.Constant + ARGARCHModel.AR{1}*yt(end);  % AR(1)-GARCH(1,1)
yhatGARCH2(t-T0+1,:) = ARGARCHModel1.Constant + ARGARCHModel1.AR{1}*yt(end);  % AR(1)-GARCH(1,1)
yhatRW(t-T0+1,:) = yt(end); % Random walk

 end

MSFE_AR = mean((ytph-yhatAR).^2)
MSFE_GARCH1 = mean((ytph-yhatGARCH1).^2)
MSFE_GARCH2 = mean((ytph-yhatGARCH2).^2)
MSFE_RW = mean((ytph-yhatRW).^2)

figure
plot(fdates,ytph,'k',fdates,yhatAR,fdates,yhatGARCH1,fdates,yhatGARCH2,fdates,yhatRW,'LineWidth',1.5)
legend('Outturn','AR(1)','AR(1)-GARCH(1,1)','AR(1)-GARCH(2,2)','Randow Walk')