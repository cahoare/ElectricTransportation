function [Eta,Ptrm]=CreateBATTmap(Pbatt_max,Wbatt)

Ptrm = [-Pbatt_max:2*Pbatt_max/21:Pbatt_max]'; % Terminal power

% ML 2016
% assume emf - resistance model with fix resistance and emf
% assume motor operation as reference, i.e. positive power charges the battery
% Ploss = Ri^2
% (e+r*i)*i =e*i+R*i^2=Ptrm -> i^2 + e/R*i - Ptrm/R = 0 -> i = -e/2/R + sqrt(e^2/4R^2+Ptrm/R)
% Assume 15% losses at nominal power; e*i_max=0.85*Ptrm_max, R*(i_max)^2=0.15*Ptrm_max;
% i_max=0.85*Ptrm_max/e;  R = 0.15*Ptrm_max/(i_max)^2;

if Wbatt<1500*3600
   typ = 1;     % Probably starter battery (12 V)
   e = 12;
elseif (Wbatt>1500*3600) & (Wbatt<(5000*3600))
    typ = 2;    % Probably Power Assist battery (100 V)
    e = 100;
elseif Wbatt>5000*3600
    typ = 3;    % Probably EV drive range battery (300 V)
    e = 300;
end

i_max = 0.85*Pbatt_max/e;
R = 0.15*Pbatt_max/(i_max)^2;

for i=1:length(Ptrm),
    curr(i)=(-e/2/R + sqrt(e^2/4/R^2+Ptrm(i)/R));
    volt(i)=e+R*curr(i);
    Ploss(i)=R*curr(i)^2;
    Eta(i)= (Ptrm(i)-Ploss(i))/(Ptrm(i)+eps);
end

figure(3)
clf
plot(Ptrm,Eta)
axis([-Pbatt_max Pbatt_max 0 2])
title('Battery conversion efficiency')
xlabel('Battery power [W]')
ylabel('Conversion efficiency')
grid on
