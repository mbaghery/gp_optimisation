[xx,yy,zz]=sphere(80);
xplot=[xx(:),yy(:),zz(:)];
yplot=reshape(gpinstance.predict(xplot), size(xx));

figure
surf(xx,yy,zz,yplot, 'EdgeColor', 'none');
colormap hot
grid on
axis square
hold on
plot3(finalX(:,1), finalX(:,2), finalX(:,3), ...
  'b+', 'MarkerSize', 10);
hold off
