clear all; clc;
%% Load data
data = readmatrix('OLSQuarterlyInflationRate.csv'); %1999Q4 - 2023Q3
y = data(:,2);

p = 2; % Define lag order as a variable for flexibility
Mdl = arima(p, 0, 0); 

%%
EstMdl = estimate(Mdl, y); % Estimate on full dataset 'y'
[Resid, ~] = infer(EstMdl, y); % Infer unobserved residuals
yhat_in = y - Resid; % Fitted values = Actual - Residuals [1]

figure
plot(y, 'b'); hold on;
plot(yhat_in, 'r--');
legend('Actual Inflation', 'In-Sample Fitted');
title('AR(2) In-Sample Fit');

%%
T = length(y);
T0 = 65; % End of training sample (2015Q4) [Turn 11]
H = 2;   % Maximum forecast horizon

% Initialize storage for forecasts
store_h1 = zeros(T - T0, 1);
store_h2 = zeros(T - T0 - 1, 1);

for t = T0 : T-1
    yt = y(1:t); % Training window grows (Recursive) [5]
    
    % Re-estimate model with current data
    Mdl_loop = arima(p, 0, 0);
    EstMdl_loop = estimate(Mdl_loop, yt, 'Display', 'off');
    
    % Generate forecasts
    % 'Y0' provides the necessary lagged values (initial conditions) [6]
    f = forecast(EstMdl_loop, H, 'Y0', yt);
    
    % Store 1-step and 2-step forecasts
    store_h1(t - T0 + 1) = f(1);
    if t + 2 <= T
        store_h2(t - T0 + 1) = f(2);
    end
end

%%
% Actual values for the evaluation period
actual_h1 = y(T0+1 : T);
actual_h2 = y(T0+2 : T);

% MSFE = Mean Squared Forecast Error [7]
MSFE_h1 = mean((actual_h1 - store_h1).^2);
MSFE_h2 = mean((actual_h2 - store_h2(1:end-1)).^2);

% MAFE = Mean Absolute Forecast Error [7]
MAFE_h1 = mean(abs(actual_h1 - store_h1));
MAFE_h2 = mean(abs(actual_h2 - store_h2(1:end-1)));

fprintf('AR(%d) 1-Step MSFE: %f, MAFE: %f\n', p, MSFE_h1, MAFE_h1);
fprintf('AR(%d) 2-Step MSFE: %f, MAFE: %f\n', p, MSFE_h2, MAFE_h2);