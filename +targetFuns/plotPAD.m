function plotPAD(wf)
%PLOTPAD Plot the photoelectron angular distribution
%   wf is the output of extractWF
%     1st dimension: r
%     2nd dimension: R, Re[left wfn], Im[left wfn], Re[right wfn], Im[right wfn]
%     3rd dimension: l

  lmax = size(wf, 3) - 1;
  
  dtheta = 0.01;
  theta = (0:dtheta:pi)';
  
  PAD = zeros(size(theta));
  
  for l1 = 0:lmax
    for l2 = 0:lmax
      PAD = PAD + 2 * pi * dtheta * ... % sin(theta) .* ...
        sphericalY(l1,0,theta,0) .* sphericalY(l2,0,theta,0) * ...
        sum(complex(wf(:,2,l1+1), wf(:,3,l1+1)) .* ...
            complex(wf(:,4,l2+1), wf(:,5,l2+1)));
    end
  end
  
  plot(theta, real(PAD));
  
  grid on;
  
  xlim([0, pi]);
  
  ax = gca;
  ax.XTick = [0 pi/4 pi/2 3*pi/4 pi];
  ax.XTickLabel = {'0','\pi/4','\pi/2','3\pi/4','\pi'};
  
  xlabel('\theta');
  title('Photoelectron Angular Distribution');
  
end

