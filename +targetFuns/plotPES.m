function plotPES(spectrum, params, delta, gamma)
%   spectrum is the output of extractSpec
%   spectrum is a 3D matrix, whose 3rd dimension is determined by lmax.
%   The size of the first dimension is determined by nradial.
%   The second dimension consists of:
%       Re[E],Im[E],Re[Wgt],Im[Wgt],Re[<I|W>],Im[<I|W>],Re[<W|I>],Im[<W|I>]

% colors = [0.6484    0.8047    0.8867
%           0.1211    0.4688    0.7031
%           0.6953    0.8711    0.5391
%           0.1992    0.6250    0.1719
%           0.9805    0.6016    0.5977
%           0.8867    0.1016    0.1094
%           0.9883    0.7461    0.4336
%           0.9961    0.4961         0
%           0.7891    0.6953    0.8359
%           0.4141    0.2383    0.6016
%           0.9961    0.9961    0.5977
%           0.6914    0.3477    0.1562];

  colors = distinguishable_colors(30);


  for i = 0:params.lmax
    energyDensity = [ones(sum(spectrum(:,1,i + 1)<0,1),1); diff(spectrum(spectrum(:,1,i + 1)>=0,1,i + 1))];
    energyDensity = [energyDensity; energyDensity(end)];
    
    plot(spectrum(:,1,i + 1), spectrum(:,3,i + 1) ./ energyDensity, ...
      '-', 'LineWidth', 1.5, 'Color', colors(i+1,:));
    hold on;
  end

  set(gcf, 'Position', [300 300 600 400]);
%   set(gca, 'YScale', 'Log');
  grid on;
  xlim([0.0, 1]);
%   ylim([0,20]);
%   ylim([1e-6,1e2]);


  titlebar = targetFuns.createtitle(params);
  title(titlebar);
  xlabel('Energy [a.u.]');
  
  legend(num2cell(num2str((0:params.lmax)'),2), 'location', 'eastoutside');
  
end
