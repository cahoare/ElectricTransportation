figure(1)
clf
contour(Wice,Tice,EtaICE,[0.05:0.05:0.3 0.31 0.32 0.33 0.34],'k-');
hold on
for p=[2500:2500:45000],
    clear t
    w=[10:10:max(Wice)];
    for i=1:length(w);
        if p/w(i)>max(Tice),
            t(i)=nan;
        else
            t(i)=p/w(i);
        end
    end
    plot(w,t,'b--')
end