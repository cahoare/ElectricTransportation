% Load driving cycles 
% Mats Alaküla.
% ML 2016

clear all
load nedc % new european driving cycle
load us06; % highway driving
load IdealMotion; % ideal way to use the lowest amount of fuel 

% ICE parameters  ++++++++++++++++++
T_max = inf;    % inf for no limitation
T_min = 0;      % -inf for hypothetical "production of fuel"


Fuel=1;         % Gasoline (Fuel=1), Diesel (Fuel=2), Ethanol (Fuel=3)

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

% Mechanical parameters  ++++++++++++++++++
Mv = (1325 + 250);    % Vehicle curb weight + 250 kg passenger and cargo
rw = 0.30;	        % wheel radius (m)
Cd = 0.26; 	        % air_resistance, Prius 2004
Cr = 0.008;	        % roll resistance
Av = 1.725*1.490;   % Front area, Width*Hight (2.57 m2)
rho_air = 1.225;    % Air density [kg/m3]
grav = 9.81;
vmax=160/3.6;       % 160 km/h max speed


% Road force resistance is the rolling resistance force and the air
% resistance force

% the acceleration is the difference between the wheel force and road force
% divided by the inertia / mass

