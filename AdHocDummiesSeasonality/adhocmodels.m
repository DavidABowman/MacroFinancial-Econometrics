%% Exponential Smoothing methods
clear all; clc;
%% Load data
data = readmatrix('ECOMNSA.csv');
sales = log(data(:,2));
 %% in-sample fit   
 dates = 1999.75:.25:2023.5;
 y = sales;
 T = length(y);
 store_L = zeros(T,3);

 % Simple exponential smoothing method
 alpha = 0.5; % Smoothing parameter
 L = zeros(T,1);   
 L(1) = y(1); % initialisation

 for t = 2:T
 L(t) = alpha*y(t) + (1-alpha)*L(t-1);   
 end
store_L(:,1) = L; 

 % Holt-winters smoothing method
alpha = .5; beta = .5; % set values for smoothing parameters
Lt = y(1); bt = y(2) - y(1);
store_L(1,2) = Lt;
for t = 2:T
newLt = alpha*y(t) + (1-alpha)*(Lt+bt);
newbt = beta*(newLt-Lt) + (1-beta)*bt;
store_L(t,2) = newLt;
end

 % Holt-winters smoothing method with seasonality
 s = 4; % Quarterly data
alpha = .5; beta = .5; gamma = .5; % set values for smoothing parameters
St = zeros(T,1);
Lt = mean(y(1:s)); bt = 0; St(1:4) = y(1:s)/Lt; % initialize
store_L(s,3) = Lt;
for t = s+1:T
newLt = alpha*(y(t) - St(t-s)) + (1-alpha)*(Lt+bt);
newbt = beta*(newLt-Lt) + (1-beta)*bt;
St(t) = gamma*(y(t)-newLt) + (1-gamma)*St(t-s);
Lt = newLt; bt = newbt; % update Lt and bt
store_L(t,3) = newLt;
end

figure
plot(dates(s:end),y(s:end),'k',dates(s:end),store_L(s:end,1),dates(s:end),store_L(s:end,2),dates(s:end),store_L(s:end,3),'LineWidth',1.5)
legend('Actual Sales','Exp. Smoothing','Holt-Winters','Holt-Winters with Seasonality')

