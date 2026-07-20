clear all; clc;

%% Question 3 DGP trend cycle
T = 50;
a0 = 0;
a1 = 0.5;
a2 = 0.1;
b1 = 4;
b2 = 0;
omega = 2*pi/4;
sig2 = 2;

mt = a0 + a1.*(1:T)' + a2.*(1:T)'.^2;
ct = b1.*cos(omega.*(1:T)') + b2.*sin(omega.*(1:T)');
yt = mt+ ct + sqrt(sig2)*randn(T,1);