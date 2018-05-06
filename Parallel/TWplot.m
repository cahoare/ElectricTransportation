figure(10)
clf
subplot(1,2,1)

plot(tWTice(:,2),tWTice(:,2))
plot(tWTice(:,2),tWTice(:,3))
axis([0 wice_max*30/pi*1.1 0 Tice_max*1.1])
axis('square')
xlabel('Speed (rpm]')
ylabel('Torque [Nm]')
title('ICE')

subplot(1,2,2)

plot(tWTem(:,2),tWTem(:,2))
plot(tWTem(:,2),tWTem(:,3))
axis([0 wice_max*30/pi*1.1 -Tice_max*1.1 Tice_max*1.1])
axis('square')
xlabel('Speed (rpm]')
ylabel('Torque [Nm]')
title('Electric Drive')
