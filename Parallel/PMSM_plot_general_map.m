% clear all
fwr=5;  % field weakening ratio
idyn=2; % max current / continuous current
Demag=1/1.5; % it takes 1/Demag times the nominal current to demagnetize the machine

w=[0:0.05:fwr];
Tref=[0:0.05:idyn];

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
        if T(i,j)>0.99*Tmax(i,j),
            Ploss(i,j)=inf;
        end
        Eta(i,j)=max(0,(Pout(i,j))/(eps+Pout(i,j)+Ploss(i,j)));
    end
end
Eta(:,length(Tref))=0;

EtaEM=[Eta(length(w):-1:1,length(Tref):-1:1) Eta(length(w):-1:1,2:length(Tref));
    Eta(2:length(w),length(Tref):-1:1) Eta(2:length(w),2:length(Tref))];


figure(1)
subplot(3,2,1)
surf(Psi)
title('Psi')
subplot(3,2,2)
surf(Curr)
title('Curr')
subplot(3,2,3)
surf(Tmax)
title('Tmax')
subplot(3,2,4)
surf(Ploss)
title('Ploss')
subplot(3,2,5)
surf([-w(length(w):-1:1) w(2:length(w))],[-Tref(length(Tref):-1:1) Tref(2:length(Tref))],EtaEM')
title('Eta')
subplot(3,2,6)
surf(Piron)
title('Piron')

figure(2)
clf
%mesh(jCOMP)
contour([-w(length(w):-1:1) w(2:length(w))],[-Tref(length(Tref):-1:1) Tref(2:length(Tref))],EtaEM',[0.2:0.05:1])
hold on
plot(w,Tmax(:,length(Tref)))