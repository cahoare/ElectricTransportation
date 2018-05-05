% **********************************************************
% * This file sets the parameters for the Simulink program
% * "Series" and must be run prior to running simulations.
% * 170521, 171111
% **********************************************************

clear all

%load driving cycles
load nedc;
load us06;
load IdealMotion;


% Selection of Charge Sustaining mode or Depletion mode is
% set by a switch in the Simulink model


% Fuel parameters +++++++++++++++++++++

Fuel=4;         % Gasoline (Fuel=1), Diesel (Fuel=2), Ethanol (Fuel=3)

if Fuel==1|Fuel==3, % Gasoline or Ethanol
    load EtaICE_OTTO;
    EtaICE = EtaICE_OTTO; % Defines the torque speed efficiency map depending on cycle
elseif Fuel==2, % Diesel
    load EtaICE_DIESEL;
    EtaICE = EtaICE_DIESEL;
elseif Fuel==4, % Complex hybrid / atkinson cycle
    load EtaICE_THS
        EtaICE = EtaICE_THS;
else
    'Erroneous fuel choice'
end

[value,row]=max(max(EtaICE')); % inner finds the maximum in each row, outer finds the overall maximum and row reference 

% ICE parameters  ++++++++++++++++++

if Fuel==1,
    wice_max = 6000*2*pi/60; % different max speed per cycle
elseif Fuel==2,
    wice_max = 4500*2*pi/60;
elseif Fuel==4,
    wice_max = 4500*2*pi/60;
else
        'Erroneous fuel choice'
end


wice_min = 1000*2*pi/60; % 800 rpm idle speed ----- this could change based on cycle???? Changed to 1000
%Tice_max = Pice_max/(wice_max*row/(length(EtaICE)-1)); % Sets maximum torque on the basis of the maximum speed and the power (i.e. maximum power comes at the maximum efficiency point). Speed is scaled according to the cycle table
Tice_max = 105;
Pice_max = wice_max*Tice_max; %5E3; %%%%%%% set input into model

[PtoT,Tice,Wice,Tlim_ice,FuelConsICE]=CreateICEmap(Pice_max,wice_min, wice_max,Tice_max,EtaICE);

% Final gear between the traction motor and the wheels   +++++++++++++

gr2 = 5; % Gear ratio


% Mechanical parameters  ++++++++++++++++++

Mv = 1300 ;    % Vehicle curb weight + 250 kg passenger and cargo
rw = 0.301;	        % wheel radius (m)
Cd = 0.254; 	        % air_resistance
Cr = 0.008;	        % roll resistance
Av = 2.289;%1.725*1.490;   % Front area, Width*Height (2.57 m2)
rho_air = 1.225;     % Air density [kg/m3]
grav = 9.81;
vmax=160/3.6;       % 160 km/h max speed
kb = 2.6;           % PGT ratio


Pvehicle_max = (Cr*Mv*grav+1/2*rho_air*Cd*Av*vmax^2)*vmax;

% Generator parameters  ++++++++++++++++++
Pem1_max = 30000;%32.5*10000/60*2*pi()%20E3;       % Peak continuous power
Tem1_max = 31;% 1.2*Tice_max;  % Peak continuous torque
%wem1_max=wice_max; % EM mounted on cranc shaft

load EtaEM_THS;

Tem1 = [0:2.5:32.5];
Wem1 = [0:500:10000];

Jgenset=0.15; % Or 0.1 (default) or MG1 or MG2 or engine?

% Traction motor parameters  ++++++++++++++++++
Pem2_max = 50000;%400*1500/60*2*pi();       % Peak continuous power
Tem2_max = 400;    % Peak continuous torque
%wem2_max = vmax/rw*gr2; 

Tem2 = [0,5:(400-5)/16:400];
Wem2 = [0:500:6000];



% Power Electronics efficiency (preset)
    
EtaPE = .98; % not included in efficiency map

% Fuel energy density [MJ / litre]
if Fuel==1, % Gasoline
    Density = 32e6;
elseif Fuel==2, % Diesel
    Density = 36e6;
elseif Fuel==3, % Ethanol
    Density = (85*19.6e6 + 15*32e6)/100;
elseif Fuel==4, % Gasoline
    Density = 32e6;
else
    'Erroneous fuel choice'
end


% Battery parameters ++++++++++++++++++

Wbatt = 201.6*6.5*3600;   % 100 Wh/kg, 13 kg

%%%% Generate battery efficiency map. Is greater than one for discharge as
%%%% you will remove more charge from the battery when you discharge at
%%%% higher rates. Inverse goes for charging (so <1)

% Pinput 21kW and Poutput 25kW

P_battmax = 25000;
P_battmin = 21000;

%[EtaBATT,Pbatt]=CreateBATTmap(P_battmin, P_battmax,Wbatt);

battR = [0.7,0.63, 0.475, 0.4, 0.375, 0.38,0.37, 0.375,0.38, 0.375, 0.375]; % SOC of battery
battV = [202.5,210,213,216,218,221,222,223,224,227,237]; %OC battery voltage based on state of charge
SOC_tab = [0,10,20,30,40,50,60,70,80,90,100];
%[EtaBATT,Pbatt]=CreateBATTmap(Pem2_max,Wbatt);
SOC_batt_ref_value = 70;   %  [%]
fully_charged = 100;
OnOffMin = 30 ;
OnOffMax = SOC_batt_ref_value-eps ;

% Controller parameters **********************************

Tau_charge = 10;   
ksoc = Wbatt/400/Tau_charge;
ks = Jgenset/4/0.05;  % Assuming a 50 ms time constant in speed measurement

Paux=600;
