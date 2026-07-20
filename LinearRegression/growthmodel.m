%% Solow-Swan(Neoclassical) Growth Model
clear all;clc;
% define parameters
A = 1; % total factor productivity
alpha = 0.35; % capital share
delta = 0.05; % depreciation rate
n = 0.02 ; % population growth rate
s = 0:.1:1; % grid of savings

%% Steady state values
kstar = ((s*A)/(n+delta)).^(1/(1-alpha));
ystar = A*kstar.^alpha;
cstar = (1-s).*ystar;

%% plot figure of golden rule
figure
grid on
set(gca,'fontsize',12)
plot(s,cstar,'-s','LineWidth',2)
title('cstar as a function of saving rate')
xlabel('Saving rate - s')
ylabel('cstar','Rotation',0)
x = [0.4 0.4];
y = [0.4 0.9];
annotation('textarrow',x,y,'String','s_G_R, c_G_R')
grid on
