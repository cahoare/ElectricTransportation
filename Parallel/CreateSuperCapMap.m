function [Eta,Ptrm,Wc]=CreateSuperCapMap(Psc_max_discharge,Wsc_min)

% assume capacitance - resistance model with fix resistance and emf
% assume motoric reference, i.e. positive power charges the battery
% Ploss = Ri^2
% (e+r*i)*i=Ptrm=e*i+R*i2 -> i^2 + e/R*i - Ptrm/R = 0 -> i = -e/2/R + sqrt(e^2/4R^2+Ptrm/R)
% Wc=Integral(e*i)dt=1/2*C*e2 -> e=sqrt(2*Wc/C)

% Data from BMOD0115PV - BoostCap Broshure from www.maxwell.com

e_unit=42;
ic_max=600;
R_unit=0.01;
C_unit=145;
Wc_max_unit=128e3;
mass_unit=15;
vol_unit=22;

% Assume n series connected capacitors
n1=ceil(Psc_max_discharge/((e_unit-ic_max*R_unit)*ic_max)); % Number of units necessary to supply the requested power)
n2=ceil(Wsc_min/Wc_max_unit);  % number of units needed to supply requested energy
n=max(n1,n2); 
C=C_unit/n;
ec_max=e_unit*n;

Wc_max=n*Wc_max_unit;
R=n*R_unit;
mass=mass_unit*n;
vol=vol_unit*n;
Psc_max_charge=(ec_max+R*ic_max)*ic_max;
Psc_max_discharge=-(ec_max-R*ic_max)*ic_max;

Ptrm = [Psc_max_discharge:(Psc_max_charge-Psc_max_discharge)/21:Psc_max_charge]'; % Terminal power for the supercap stack
Wc=[0:Wc_max/21:Wc_max]; % Energy vector for the supercap energy storage

for i=1:length(Ptrm), % For all terminal power levels
    for j=1:length(Wc), % For all energy levels
        e(i,j)=sqrt(Wc(j)*2/C); % back emf at this energy state
        curr(i,j)=(-e(i,j)/2/R + sqrt(e(i,j)^2/4/R^2+Ptrm(i)/R)); % current needed to charge/discharge with the requested terminal power
        if curr(i,j)>ic_max, % If current to big, set efficiency extreme
            curr(i,j)=nan;
            if Ptrm(i)>0,
                Eta(i,j)=0.1;
            else
                Eta(i,j)=1.9;
            end
        elseif abs(imag(curr(i,j)))>0, % if current not possible, set efficiency extreme
            curr(i,j)=nan;
            if Ptrm(i)>0.1,
                Eta(i,j)=0.1;
            else
                Eta(i,j)=1.9;
            end
        elseif Ptrm(i)==0|Wc(j)==0, % cheating, but gives nicer surface
            Eta(i,j)=1;
        else
            volt(i,j)=e(i,j)+R*curr(i,j); % not needed
            Ploss(i,j)=R*curr(i,j)^2; % resistive losses
            Eta(i,j) = (Ptrm(i)-Ploss(i,j))/(Ptrm(i)+eps); % power to/from the emf vs. terminal power
        end
    end
end

figure(3)
clf
subplot(1,2,1)
mesh(Wc./Wc_max,Ptrm./Psc_max_discharge,Eta)
title('Battery charge efficiency')
ylabel('Super Cap Power [W]')
xlabel('Super Cap Energy')
grid on

subplot(1,2,2)
text(0.1,0.9,[' Based on ' num2str(n) ' Maxwell BMOD0115PV units'])
text(0.1,0.8,[num2str(Wc_max/1000) '  kWs max stored energy'])
text(0.1,0.7,[num2str(ec_max) '  Volts max voltage'])
text(0.1,0.6,[num2str(Psc_max_charge/1000) '  kW max charge power'])
text(0.1,0.5,[num2str(Psc_max_discharge/1000) '  kW max discharge power'])
text(0.1,0.4,[num2str(mass) ' kg weight'])
text(0.1,0.3,[num2str(vol) ' liter volume'])

