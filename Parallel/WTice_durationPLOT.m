WTdura = 0.*EtaICE;

for i=1:length(tWTice(:,1))-1,
    speedindex = min(find((tWTice(i,2)-Wice*30/pi)<0));
    torqueindex = min(find((tWTice(i,3)-Tice)<0));
    WTdura(speedindex,torqueindex)=WTdura(speedindex,torqueindex)+tWTice(i,1);
end
figure(14)
clf
mesh(Wice*30/pi,Tice,WTdura'./max(max(WTdura)))
axis([0 6000 0 200 0 1])

    