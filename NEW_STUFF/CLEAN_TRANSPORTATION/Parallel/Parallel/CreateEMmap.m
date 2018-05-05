% * ML 2017. Minor change in map creation due to discretizatio, see below
% *  
function [EtaEM,Tem,Wem] = CreateEMmap(Pem_max,wem_max,Tem_max)

clear i j Psi Isx Isy IsyMAX Curr Tmax T Pout Pcopper Piron Pwindage Ploss Eta
fwr=wem_max/(Pem_max/(Tem_max));  % field weakening ratio
idyn=1; % max current / continuous current
Demag=1/0.7; % it takes 1/Demag times the nominal current to demagnetize the machine

w=[0:fwr/20:fwr];
Tref=[0:idyn/20:idyn];

for i=1:length(w),
    for j=1:length(Tref),
        Psi(i,j)=min(1,1/(eps+w(i)));
        Isx(i,j)=min(idyn,max((w(i)-1),0)/(max(w)-1)/Demag);
        Isy(i,j)=min(Tref(j)/Psi(i,j),sqrt(idyn^2-Isx(i,j)^2));
        IsyMAX(i,j)=min(max(Tref)/Psi(i,j),sqrt(idyn^2-Isx(i,j)^2));
        Curr(i,j)=sqrt(Isx(i,j)^2+Isy(i,j)^2);
        Tmax(i,j)=Psi(i,j)*IsyMAX(i,j);
 
        T(i,j)=min(Tref(j),Tmax(i,j));
        Pout(i,j)=w(i)*T(i,j);
        Pcopper(i,j)=(Curr(i,j)/idyn)^2*0.05;
        Piron(i,j)=w(i)*Psi(i,j)^2*0.00 + (w(i)*Psi(i,j))^2*0.01;
        Pwindage(i,j)=(w(i)/max(w))^3*0.05;
        Ploss(i,j)=0.015+Pcopper(i,j)+Piron(i,j)+Pwindage(i,j);
        if (i>3)&(T(i,j)<T(i-3,j)),
            Ploss(i,j)=10*Pout(i,j);
        end
        Eta(i,j)=max(0.01,(Pout(i,j))/(eps+Pout(i,j)+Ploss(i,j)));
    end
end

for a=1:3,      % ML 170521:Due to discretization, the extension has to be 
                % done for 3 levels which does influence the numerical
                % results and makes the wT plot look slightly wrong in the
                % block, but the simulation works better than with only 2
                % levels
% for a=1:2,
EtaTEMP=Eta;    % MA: Extend the Eta map a bit out into the field weakening region to avoid
                % that the simulation progran gets in there icrementally

for i=2:length(Eta(:,1)),
    for j=2:length(Eta(1,:)),
        if (EtaTEMP(i,j)<(EtaTEMP(i-1,j)/2))|(EtaTEMP(i,j)<(EtaTEMP(i,j-1)/2))
            Eta(i,j) = max([EtaTEMP(i-1,j) EtaTEMP(i,j-1)]);
        end
    end
end
end

EtaEM = Eta;

Tem = Tem_max.*Tref/max(Tref);
Wem = wem_max.*w/max(w);

%Wem = wem_max.*[-w(length(w):-1:1) w(2:length(w))]./max(w);
%Tem = Tem_max.*[-Tref(length(Tref):-1:1) Tref(2:length(Tref))]./max(Tref);

%EtaEM=[Eta(length(w):-1:1,length(Tref):-1:1) Eta(length(w):-1:1,2:length(Tref));
%     Eta(2:length(w),length(Tref):-1:1) Eta(2:length(w),2:length(Tref))];


% figure(1)
% subplot(3,2,1)
% surf(Psi)
% title('Psi')
% subplot(3,2,2)
% surf(Curr)
% title('Curr')
% subplot(3,2,3)
% surf(Tmax)
% title('Tmax')
% subplot(3,2,4)
% surf(Ploss)
% title('Ploss')
% subplot(3,2,5)
% surf([-w(length(w):-1:1) w(2:length(w))],[-Tref(length(Tref):-1:1) Tref(2:length(Tref))],EtaEM')
% title('Eta')
% subplot(3,2,6)
% surf(Piron)
% title('Piron')

figure(2)
clf
%mesh(jCOMP)
% contour([-w(length(w):-1:1) w(2:length(w))],[-Tref(length(Tref):-1:1) Tref(2:length(Tref))],EtaEM',[0.2:0.05:1])
surfc(Wem,Tem,EtaEM')
axis([0 max(Wem) 0 max(Tem) 0 1])
xlabel('Speed [rad/s]')
ylabel('Torque [Nm]')
title('Electrical machine efficiency')