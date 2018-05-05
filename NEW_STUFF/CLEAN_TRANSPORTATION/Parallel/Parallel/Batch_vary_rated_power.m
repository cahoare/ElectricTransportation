% ML 170521
% The assigning of ICEpower and EMpower is done in  
% Batch_vary_rated_power_initialise.m
% Do not forget to set appropriate parameters (Speedy ...) in 
% the Simulink-file prior to running this batch-file.


clear fc 

% Create vectors for the desired simulation parameters
ICEpower_simulated= 50000:20000:90000
EMpower_simulated = 100000-ICEpower_simulated;

fc =[];
for i=1:length(ICEpower_simulated)
    
    ICEpower = ICEpower_simulated(i);
    EMpower = EMpower_simulated(i);
    Batch_vary_rated_power_initialise;
    close all
    sim('Parallel')
    fc = [fc fuelcons(length(fuelcons))]
end

figure(10)
hold on
plot(ICEpower_simulated,fc)
grid on
xlabel('ICE size')
ylabel('FuelConsumption')


    