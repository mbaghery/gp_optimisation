theta=linspace(0,2*pi,200)';
xplot=[cos(theta), sin(theta)];
yplot=gpinstance.predict(xplot);

figure
plot3(xplot(:,1), xplot(:,2), yplot);
grid on
hold on
plot3(finalX(:,1), finalX(:,2), finalY, '+');
hold off
