function timeAndPlots(varargin)
%TIMEANDPLOTS Display the elapsed time and draw the plots
%   It shows the elapsed time as well as the relevent plots.

  % initialise the plots
  if (varargin{0}==0)%         figure
% 
%         % wavefunction
%         subplot(3,1,1);
%         box on
%         xlim([-320, 320]);
%         ylim([-0.1,0.15]);
%         xlabel('r');
%         l11=line(nan,nan);
%         l12=line(nan,nan);
%         l11.LineWidth=2;
%         l12.LineWidth=2;
%         set(gca,'FontSize', 30);
%         l11.XData=this.x;
%         l12.XData=this.x;
%         l12.YData=full(diag(this.pot));
%         l11.Color=[0, 0.4470, 0.7410];
%         l12.Color=[0.8500, 0.3250, 0.0980];
% 
%         % laser pulse
%         subplot(3,1,2);
%         box on
%         xlim([0,this.propParams.duration]);
% %         ylim([-laserParams.amplitude, laserParams.amplitude] * 1.2);
%         xlabel('time');
%         ylabel('laser amplitude');
%         l21=line(nan,nan);
%         l22=line(nan,nan);
%         l21.LineWidth=2;
%         l22.LineWidth=2;
%         set(gca,'FontSize', 30);
%         l21.XData=linspace(0,this.propParams.duration, 600); %...
% %           20 * laserParams.omega * laserParams.FWHM); % 20 points per wavelength
%         l21.YData=laserFun(l21.XData);
% %         l22.YData=[-laserParams.amplitude, laserParams.amplitude]*1.2;
% l22.YData=[-1,1];
%         l22.LineStyle='-.';
%         l22.Color=[212, 161, 144]/256;
% 
%         % charge
%         subplot(3,1,3);
%         box on
%         xlim([0,this.propParams.duration]);
%         ylim([0,1]);
%         xlabel('time');
%         ylabel('remaining charge');
%         l3=line(0,1);
%         l3.LineWidth=2;
%         set(gca,'FontSize', 30);
  end
  
  
%             l11.YData=abs(this.psi - ...
%               conj(this.psi' * this.boundStates * this.dx) * ...
%               this.boundStates).^2;
%             l11.YData=abs(this.psi).^2;
% 
%             l22.XData=[t, t];
% 
%             finalCharge=this.getCharge;
% 
%             l3.XData=[l3.XData, t];
%             l3.YData=[l3.YData, finalCharge];
% 
%             drawnow
  
end
