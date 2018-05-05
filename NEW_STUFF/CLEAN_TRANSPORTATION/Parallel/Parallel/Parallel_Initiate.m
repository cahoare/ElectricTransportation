 % **********************************************************
% * This file sets the parameters for the Simulink program
% * "Parallel" and must be run prior to running simulations.
% * 170329, 170521, 171111
% * 
% **********************************************************

clear all

% Load driving Cycles

load nedc;
load us06;
load IdealMotion;

ICEconventional=100000;

% Specification when simulating a hybrid vehicle
ICEpower=65973; % Normally ICEpower+EMpower should be 100kW
EMpower=50000;

TorqueEMmax=400;

% Vehicle type ++++++++++++++++++++++++++++

Fuel=1;         % Gasoline (Fuel=1), Diesel (Fuel=2), Ethanol (Fuel=3)
Hybrid=1;       % 0 for conventional, 1 for parallell hybrid
Depletion=0;    % 0 for Charge Sustaining mode and 1 for depletion mode
StopAndGo=0;    % 1 if stop & go is on
Speedy=0;       % 1 for "sporty" driving

% ICE parameters  ++++++++++++++++++

if Fuel==1|Fuel==3, % Gasoline or Ethanol
    load EtaICE_OTTO;
    EtaICE = EtaICE_OTTO;
elseif Fuel==2, % Diesel
    load EtaICE_DIESEL;
    EtaICE = EtaICE_DIESEL;
else
    'Erroneous fuel choice'
end

[value,row]=max(max(EtaICE'));

Pice_max = ICEpower*Hybrid+ICEconventional*(1-Hybrid); 
if Fuel==1,
    wice_max = 6000*2*pi/60;
elseif Fuel==2,
    wice_max = 4500*2*pi/60;
else
        'Erroneous fuel choice'
end
wice_min = 800*2*pi/60; % 700 rpm idle speed
Tice_max = Pice_max/(wice_max*row/(length(EtaICE)-1));

[PtoT,Tice,Wice,Tlim_ice,FuelConsICE]=CreateICEmap(Pice_max,wice_max,Tice_max,EtaICE);

% Ratio for the final gear between the traction motor and the wheels   *************'

gr2 = 5;


% Mechanical parameters  ++++++++++++++++++

Mv = 1325 + 250;    % Vehicle curb weight + 250 kg passenger and cargo
rw = 0.30;	        % wheel radius (m)
Cd = 0.26; 	        % air_resistance. (Sports Car 0.3-0.4, Ecomony Car 0.4-0.5, Pickup Truck 0.5, Tractor-Trailer,with fairings 0.6-0.7, Tractor-Trailer 0.7-0.9) 
Cr = 0.008;	        % roll resistance (0.006...0.008 for low roll resist tires. 0.01...0.015 ordinary tires)
Av = 1.725*1.490;   % Front area, Width*Hight (2.57 m2)
rho_air = 1.225;     % Air density [kg/m3]
grav = 9.81;
vmax=160/3.6;       % 160 km/h max speed

Pvehicle_max = (Cr*Mv*grav+1/2*rho_air*Cd*Av*vmax^2)*vmax;

% Gearbox      ++++++++++++++++++++ utvx = (speed of ICE)/(speed of wheels) incl. final gear

utvx_max=wice_max/((vmax/5)/rw); % "First gear". Arbitrary, it is assumed that top speed of gear 1 is at 1/5 of max speed 
utvx_min=wice_max/(vmax/rw)/1.3;  % "Fifth gear". Under the assumption that top speed of the engine and the vechicle "coincides"

Number_of_gears = 5;

Utvx_vect = zeros(1,Number_of_gears+1);
Utvx_vect(1,1) = utvx_min;
Utvx_vect(1,length(Utvx_vect(1,:))) = inf;
for i=2:Number_of_gears,
    Utvx_vect(1,i) =  Utvx_vect(1,i-1)*(utvx_max/utvx_min)^(1/(Number_of_gears-1));
end

% Electric machine parameters  ++++++++++++++++++
Pem_max = EMpower*Hybrid+2000*(1-Hybrid);       % Peak continuous power
Tem_max = TorqueEMmax*Hybrid+10*(1-Hybrid);  % Peak continuous torque
wem_max=wice_max; % EM mounted on cranc shaft

[EtaEM,Tem,Wem] = CreateEMmap(Pem_max,wem_max,Tem_max);

% Power electronics efficiency (preset)

EtaPE = 0.98;

% Fuel energy density [MJ/liter]
if Fuel==1, % Gasoline
    Density = 32e6;
elseif Fuel==2, % Diesel
    Density = 36e6;
elseif Fuel==3, % Ethanol
    Density = (85*19.6e6 + 15*32e6)/100;
else
    'Erroneous fuel choice'
end

% Battery parameters ++++++++++++++++++

Wbatt = 100*3600*13;   % 100 Wh/kg, 13 kg
[EtaBATT,Pbatt]=CreateBATTmap(Pem_max,Wbatt);
SOC_batt_ref = 70;   %   [%]
SOC_batt_ref_value = 70;
OnOffMin = 30 ;
OnOffMax = SOC_batt_ref - eps ; % ML: In order to start the simulation correctly

% SuperCap parameters ++++++++++++++++++

% Wsc=2e5;
% Psc_max_discharge = Pem_max;
% [EtaSC,Psupercap,Wsupercap]=CreateSuperCapMap(Psc_max_discharge,Wsc)
% SOC_sc_ref_value = 90;

% Controller parameters **********************************

Tau_charge = 1;   
ksoc = max(Wbatt)/400/Tau_charge;

% Auxiliary load power ***********************

Paux = 600;    % Without AC



   