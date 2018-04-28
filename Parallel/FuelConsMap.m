for i=1:length(Tice);
    for j=1:length(Wice);
        FuelCons(i,j)=Wice(i)*Tice(j)/EtaICE(i,j);
    end
end
FuelCons(1,:)=Wice(:)'./EtaICE(2,:)*Tice(2);

figure(3)
mesh(Wice,Tice,FuelCons)
