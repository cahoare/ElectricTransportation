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

Fuel=1;         % Gasoline (Fuel=1), Diesel (Fuel=2), Ethanol (Fuel=3)

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

% ICE parameters  ++++++++++++++++++
Pice_max = 20E3;
if Fuel==1,
    wice_max = 6000*2*pi/60;
elseif Fuel==2,
    wice_max = 4500*2*pi/60;
else
        'Erroneous fuel choice'
end
wice_min = 800*2*pi/60; % 800 rpm idle speed
Tice_max = Pice_max/(wice_max*row/(length(EtaICE)-1));

[PtoT,Tice,Wice,Tlim_ice,FuelConsICE]=CreateICEmap(Pice_max,wice_max,Tice_max,EtaICE);

% Final gear between the traction motor and the wheels   +++++++++++++

gr2 = 5; % Gear ratio


% Mechanical parameters  ++++++++++++++++++

Mv = 1325 + 250;    % Vehicle curb weight + 250 kg passenger and cargo
rw = 0.30;	        % wheel radius (m)
Cd = 0.26; 	        % air_resistance
Cr = 0.008;	        % roll resistance
Av = 1.725*1.490;   % Front area, Width*Height (2.57 m2)
rho_air = 1.225;     % Air density [kg/m3]
grav = 9.81;
vmax=160/3.6;       % 160 km/h max speed

Pvehicle_max = (Cr*Mv*grav+1/2*rho_air*Cd*Av*vmax^2)*vmax;

% Generator parameters  ++++++++++++++++++
Pem1_max = 20E3;       % Peak continuous power
Tem1_max = 1.2*Tice_max;  % Peak continuous torque
wem1_max=wice_max; % EM mounted on cranc shaft

[EtaEM1,Tem1,Wem1] = CreateEMmap(Pem1_max,wem1_max,Tem1_max);

Jgenset=0.1;

% Traction motor parameters  ++++++++++++++++++
Pem2_max = 50000+65973; % Complex MG2 + Complex ICE (otto) % Peak continuous power
Tem2_max = 400+105; % Complex MG2 + Complex ICE   % Peak continuous torque
wem2_max = vmax/rw*gr2; 

[EtaEM2,Tem2,Wem2] = CreateEMmap(Pem2_max,wem2_max,Tem2_max);

% Power Electronics efficiency (preset)
    
EtaPE = 0.98;

% Fuel energy density [MJ / litre]
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
             
[EtaBATT,Pbatt]=CreateBATTmap(Pem2_max,Wbatt);
SOC_batt_ref_value = 70;   %  [%]
OnOffMin = 30 ;
OnOffMax = SOC_batt_ref_value-eps ;

% Controller parameters **********************************

Tau_charge = 1;   
ksoc = Wbatt/400/Tau_charge;
kgenset = Jgenset/4/0.05;  % Assuming a 50 ms time constant in speed measurement

Paux=600;