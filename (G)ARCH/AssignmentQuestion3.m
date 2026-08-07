%% OUT OF SAMPLE FORECASTING
clear all; clc;
%% Load data
data = readmatrix("AssignmentData.xlsx", "Sheet","Sheet3");

dates = data(:,1);

y = data(:,2); % Load Quarterly CPI Inflation Rate
T = length(y);
Q = 3 % Question

T0 = find(dates==2014.75); % Training Sample Period
Tend = find(dates==2018.75);
 
p = 2; % AR lags
q = 2; % MA lags
h = 1 % h-step-ahead forecast

ytph = y(T0+h:Tend); % observed y_{t+h} y_t Plus Horizon (Outturn - Output(?))
yhatARMA = zeros(Tend-h-T0+1,1); %% ARMA(1,1) forecasts

fdates = dates(T0+h:Tend);
%%
for t = T0:Tend-h
 yt = y(1:t); % Information Set Estimating the Model Up Until y_T

%% ARMA(p,q) % Question 3 - data at row 233(?) to row 244
ARMAMdl = arima(p,0,q);
EstARMAMdl = estimate(ARMAMdl,yt,Display="off");
ARMAerror = infer(EstARMAMdl,yt);

% AR(2)
% y_T+1 = c + phi_1*y_T   + phi_2*y_T-1 % One-Step Ahead
% y_T+2 = c + phi_1*y_T+1 + phi_2*y_T   % Two-Step Ahead
% y_T+3 = c + phi_1*y_T+2 + phi_2*y_T+1 % Three-Step Ahead
% y_T+4 = c + phi_1*y_T+3 + phi_2*y_T+2 % Four-Step Ahead

% ARMA(1,1)
% y_T+1 = c + phi_1*y_T   + (0)e_T+1 +    psi_1*e_T   % One-Step Ahead
% y_T+2 = c + phi_1*y_T+1 + (0)e_T+2 + (0)psi_1*e_T+1 % Two-Step Ahead
% y_T+3 = c + phi_1*y_T+2 + (0)e_T+3 + (0)psi_1*e_T+2 % Three-Step Ahead
% y_T+4 = c + phi_1*y_T+3 + (0)e_T+4 + (0)psi_1*e_T+3 % Four-Step Ahead

% ARMA(2,2) 
% y_T   = c + phi_1*y_T-1 + phi_2*y_T-2 +               psi_1*e_T   +    psi_2*e_T-1 % Are we sure this is right?
% y_T = c + phi_1*y_T-1 + phi_2*y_T-2 + e_T + psi_1*e_T-1 + psi_2*e_T-2 
% y_T+1 = c + phi_1*y_T   + phi_2*y_T-1 + (0)e_T+1 +    psi_1*e_T   +    psi_2*e_T-1 % One-Step Ahead
% y_T+2 = c + phi_1*y_T+1 + phi_2*y_T   + (0)e_T+2 + (0)psi_1*e_T+1 +    psi_2*e_T   % Two-Step Ahead
% y_T+3 = c + phi_1*y_T+2 + phi_2*y_T+1 + (0)e_T+3 + (0)psi_1*e_T+2 + (0)psi_2*e_T+1 % Three-Step Ahead
% y_T+4 = c + phi_1*y_T+3 + phi_2*y_T+2 + (0)e_T+4 + (0)psi_1*e_T+3 + (0)psi_2*e_T+2 % Four-Step Ahead
% --> However, future errors cannot be observed. 


%% store the forecasts
%if h == 1
%    % y_T+1 = c + phi_1*y_T + phi_2*y_T-1
%    yhatAR(t-T0+1,:) = EstARMdl.Constant + EstARMdl .AR{1}*yt(end) + EstARMdl .AR{2}*yt(end-1); % AR(2)
%elseif  h == 2
%    % y_T+2 = c + phi_1*y_T+1 + phy_2*y_T
%    yhat1 = EstARMdl.Constant + EstARMdl .AR{1}*yt(end) + EstARMdl .AR{2}*yt(end-1) ; % one-step % AR(2)
%    yhatAR(t-T0+1,:) = EstARMdl.Constant + EstARMdl .AR{1}*yhat1 + EstARMdl .AR{2}*yt(end); %two-step % AR(2)
    %yhatAR(t-T0+2,:) = EstARMdl.Constant + EstARMdl .AR{1}*yt(end) + EstARMdl .AR{2}*yt(end-1) + EstARMdl .AR{2}*yt(end-2); % AR(2)
%elseif  h == 3
    % y_t+3 = c + phi_1*y_T+2 + phi_2*y_T+1 %%Make sure to adjust properly
    % if AR(p) changes from 2 to 3 or 4. We then need to augment
    % appropriately 
%    yhat1 = EstARMdl.Constant + EstARMdl .AR{1}*yt(end) + EstARMdl .AR{2}*yt(end-1); % One-step % AR(2)
%    yhat2 = EstARMdl.Constant + EstARMdl .AR{1}*yhat1 + EstARMdl .AR{2}*yt(end); % Two-step AR(2)
%    yhatAR(t-T0+1.,:) = EstARMdl.Constant + EstARMdl .AR{1}*yhat2 + EstARMdl .AR{2}*yhat1; % Three-step AR(2)
%end

%if h == 1
%    yhatAR(t-T0+1,:) = EstARMdl.Constant + EstARMdl . AR()
% 1 step-ahead
%yhatMA(t-T0+1,:) = EstMAMdl.Constant + EstMAMdl.MA{1}*MAerror(end);  % MA(1)
%if h == 1
%    yhatMA(t-T0+1,:) = EstMAMdl.Constant + EstMAMdl.MA{1}*MAerror(end) + EstMAMdl.MA{2}*MAerror(end-1);
    % We use the past shock to predict the next value
%elseif h == 2 %  MA(1)
%    yhatMA(t-T0+1,:) = EstMAMdl.Constant; % MA(1)
    % For a 2 step-ahead forecast, we ignore previous shocks and revert to
    % the mean 
%end

% ARMA(1,1)
%if p == 1
%    if h == 1
%    yhatARMA(t-T0+1,:) = EstARMAMdl.Constant + EstARMAMdl.AR{1}*yt(end) + EstARMAMdl.MA{1}*ARMAerror(end); % ARMA(1,1)
%    elseif h == 2
%        yhatARMA(t-T0+1,:) = EstARMAMdl.Constant + EstARMAMdl.AR{1}*yt(end) + EstARMAMdl.MA{1}*ARMAerror(end); % ARMA(1,1)
%    elseif h == 3
%    elseif h == 4
%    end
%end



% Assumed variables from your environment:
% EstARMAMdl -> Your estimated ARMA(2,2) model object
% yt         -> Vector of historical data up to time T
% ARMAerror  -> Vector of estimated historical residuals up to time T
if (p == q) && (q == 2)

    if h == 1
    % y_T+1 depends on 2 past values and 2 past shocks
                                     %c                          % y_T                     % y_T-1                      % e_T                              % e_T-1
        yhatARMA(t-T0+1,:) = EstARMAMdl.Constant + EstARMAMdl.AR{1}*yt(end) + EstARMAMdl.AR{2}*yt(end-1) + EstARMAMdl.MA{1}*ARMAerror(end) + EstARMAMdl.MA{2}*ARMAerror(end-1);    

    elseif h == 2
    % Step 1: Calculate the 1-step-ahead forecast needed as an input
        yhat1 = EstARMAMdl.Constant ...
            + EstARMAMdl.AR{1}*yt(end) ...
            + EstARMAMdl.AR{2}*yt(end-1) ...
            + EstARMAMdl.MA{1}*ARMAerror(end) ...
             + EstARMAMdl.MA{2}*ARMAerror(end-1);
    
    % Step 2: Compute y_T+2. 
    % Note: e_T+1 drops out (becomes 0). e_T is still used.
        yhatARMA(t-T0+1,:) = EstARMAMdl.Constant ...
                       + EstARMAMdl.AR{1}*yhat1 ...     % Replaces y_T+1
                       + EstARMAMdl.AR{2}*yt(end) ...   % y_T
                       + EstARMAMdl.MA{2}*ARMAerror(end); % Replaces e_T (shifted 1 step)

    elseif h == 3
    % Step 1 & 2: Generate internal 1-step and 2-step inputs
        yhat1 = EstARMAMdl.Constant + EstARMAMdl.AR{1}*yt(end) + EstARMAMdl.AR{2}*yt(end-1) + EstARMAMdl.MA{1}*ARMAerror(end) + EstARMAMdl.MA{2}*ARMAerror(end-1);
        yhat2 = EstARMAMdl.Constant + EstARMAMdl.AR{1}*yhat1 + EstARMAMdl.AR{2}*yt(end) + EstARMAMdl.MA{2}*ARMAerror(end);
    
    % Step 3: Compute y_T+3. 
    % Note: All MA shocks (e_T+2, e_T+1) are now 0. The MA component completely drops out.
        yhatARMA(t-T0+1,:) = EstARMAMdl.Constant ...
                       + EstARMAMdl.AR{1}*yhat2 ...     % Replaces y_T+2
                       + EstARMAMdl.AR{2}*yhat1;        % Replaces y_T+1

    elseif h == 4
    % Generate all preceding internal forecasts up to h=3
        yhat1 = EstARMAMdl.Constant + EstARMAMdl.AR{1}*yt(end) + EstARMAMdl.AR{2}*yt(end-1) + EstARMAMdl.MA{1}*ARMAerror(end) + EstARMAMdl.MA{2}*ARMAerror(end-1);
        yhat2 = EstARMAMdl.Constant + EstARMAMdl.AR{1}*yhat1 + EstARMAMdl.AR{2}*yt(end) + EstARMAMdl.MA{2}*ARMAerror(end);
        yhat3 = EstARMAMdl.Constant + EstARMAMdl.AR{1}*yhat2 + EstARMAMdl.AR{2}*yhat1;
    
    % Compute y_T+4 using only previous forecasts
        yhatARMA(t-T0+1,:) = EstARMAMdl.Constant ...
                           + EstARMAMdl.AR{1}*yhat3 ...     % Replaces y_T+3
                         + EstARMAMdl.AR{2}*yhat2;        % Replaces y_T+2
    end
elseif p == 2 && q == 0
    if h == 1
        yhatARMA(t-T0+1,:) = EstARMAMdl.Constant + EstARMAMdl.AR{1}*yt(end) + EstARMAMdl.AR{2}*yt(end-1); 
    elseif h == 2
        yhat1 = EstARMAMdl.Constant + EstARMAMdl.AR{1}*yt(end) + EstARMAMdl.AR{2}*yt(end-1); 
        yhatARMA(t-T0+1,:) = EstARMAMdl.Constant + EstARMAMdl.AR{1}*yhat1;    
    elseif h == 3
        yhat1 = EstARMAMdl.Constant + EstARMAMdl.AR{1}*yt(end) + EstARMAMdl.AR{2}*yt(end-1); 
        yhat2 = EstARMAMdl.Constant + EstARMAMdl.AR{1}*yhat1 + EstARMAMdl.AR{2}*yt(end); 
        yhatARMA(t-T0+1,:) = EstARMAMdl.Constant + EstARMAMdl.AR{1}*yhat2 + EstARMAMdl.AR{2}*yhat1;
    elseif h == 4
        yhat1 = EstARMAMdl.Constant + EstARMAMdl.AR{1}*yt(end) + EstARMAMdl.AR{2}*yt(end-1); 
        yhat2 = EstARMAMdl.Constant + EstARMAMdl.AR{1}*yhat1 + EstARMAMdl.AR{2}*yt(end);
        yhat3 = EstARMAMdl.Constant + EstARMAMdl.AR{1}*yhat2 + EstARMAMdl.AR{2}*yhat1;
        yhatARMA(t-T0+1,:) = EstARMAMdl.Constant + EstARMAMdl.AR{1}*yhat3 + EstARMAMdl.AR{2}*yhat2;
    end



end
%yhatRW(t-T0+1,:) = yt(end); % Random walk


%MSFE_AR_record(t-T0+1,:) = mean((ytph(t-T0+1,:)-yhatAR(t-T0+1,:)).^2)
%MSFE_MA_record(t-T0+1,:) = mean((ytph(t-T0+1,:)-yhatMA(t-T0+1,:)).^2)
MSFE_ARMA_record(t-T0+1,:) = mean((ytph(t-T0+1,:)-yhatARMA(t-T0+1,:)).^2);
MAFE_ARMA_record(t-T0+1,:) = mean(abs(ytph(t-T0+1,:)-yhatARMA(t-T0+1,:)));

%MSFE_RW_record(t-T0+1,:) = mean((ytph(t-T0+1,:)-yhatRW(t-T0+1,:)).^2)

end
MSFE_ARMA = mean((ytph-yhatARMA).^2)
MAFE_ARMA = mean(abs(ytph-yhatARMA))
%%

figure
plot(fdates,ytph,'b',fdates,yhatARMA, 'LineWidth',1.5)
title("Q" + Q + " ARMA(" + p + "," + q + ") Out-of-Sample Forecast Values - " + h + " steps ahead")
legend('Core CPI',"ARMA(" + p + "," + q + ")","Location","southeast")

figure
plot(fdates,MSFE_ARMA_record, fdates, MAFE_ARMA_record, "r", 'LineWidth',1.5)
title("MSFE and MAFE Values - " + h + " steps ahead")
legend("MSFE-ARMA(" + p + "," + q + ") - " + h + " steps ahead", "MAFE-ARMA(" + p + "," + q + ") - " + h + " steps ahead", "Location","northeast")

%figure
%plot(fdates,ytph,'b',fdates,yhatAR,fdates,yhatMA,fdates,yhatARMA,fdates,yhatRW, "r", 'LineWidth',1.5)
%legend('Core CPI','AR(1)','MA(1)','ARMA(1,1)','Random Walk',"Location","southeast")

%figure
%plot(fdates,MSFE_AR_record,fdates,MSFE_MA_record,fdates,MSFE_ARMA_record,fdates,MSFE_RW_record, "r", 'LineWidth',1.5)
%legend('MSFE-AR(1)','MSFE-MA(1)','MSFE-ARMA(1,1)','MSFE-RW',"Location","northeast")
