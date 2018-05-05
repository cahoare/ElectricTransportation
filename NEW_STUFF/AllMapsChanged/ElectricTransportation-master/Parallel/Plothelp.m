% ML M-file that plots Main Scope
% Set Save as "Structure with time" and name "Scopedata"
% 170529

clf

NmbrOfDiag = length(ScopeData.signals)

if NmbrOfDiag>1,
for i=1:NmbrOfDiag,
    subplot(NmbrOfDiag,1,i)
    hold on
    plot(ScopeData.time,ScopeData.signals(i).values)
    title(ScopeData.signals(i).title)
    %axis([0 max(ScopeData.time) -400 400])
end
else
for i=1:NmbrOfDiag,
    figure(1)
    clf
    hold on
    plot(ScopeData.time,ScopeData.signals(i).values)
    title(ScopeData.signals(i).title)
    %axis([0 max(ScopeData.time) -400 400])
end 
end



