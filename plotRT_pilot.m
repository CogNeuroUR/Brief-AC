function plotRT_pilot(save_plots)
%function [dataAC, dataCC, dataAI, dataCI] =...
%          computeRTstatistics(ExpInfo, key_yes, key_no, make_plots, save_plots)
% Computes RT group statistics (mean & std) per condition for each probe type and
% congruency.
%
% Written for BriefAC (AinC)
% Vrabie 2022
make_plots = 1;
%save_plots = 1;

%% Load results from file : ExpInfo
path_results = 'results/post-pilot/';
[dataAC, dataAI, dataCC, dataCI] = extractData_meanRT(path_results);

%% ########################################################################
% Plots [COMPATIBLE]
%% ########################################################################
if make_plots
  fh = figure;

  % General parameters
  mark_act = "o";
  mark_ctx = "s";
  color_compatible = "#00BF95";
  color_incompatible = "#BF002A";

  lgd_location = 'northeast';

  xfactor = 1000/60;
  ylimits = [600 1200];
  xlimits = [1.3 8.8]*xfactor;
  x = [2:6 8]*xfactor; % in ms
  %xlabels = {'33.3', '50.0', '66.6', '83.3', '100.0', '133.3', 'Overall'};

  % PLOT : ACTIONS (Compatible vs Incompatible) =============================
  subplot(1,2,1);
  % Define indices for for condition category
  data1 = dataAC;
  data2 = dataAI;

  %[y1, err1] = meanCIgroup(data1); % 95% CI
  %[y2, err2] = meanCIgroup(data2); % 95% CI
  [y1, err1] = meanSEgroup(data1); % Standard error
  [y2, err2] = meanSEgroup(data2); % Standard error
  
  %disp(data1)
  %disp(err1)

  e1 = errorbar(x-1.5, y1, err1);
  %e1 = plot(x-1.5, data1, '-o', 'Color', color_compatible);
  hold on
  e2 = errorbar(x+1.5, y2, err2);
  %e2 = plot(x+1.5, data2, '-o', 'Color', color_incompatible);
  l1 = plot(x, data1', 'Color', color_compatible);
  l2 = plot(x, data2', 'Color', color_incompatible);
  hold off

  e1.Marker = mark_act;
  e2.Marker = mark_act;

  % Transparency for individual lines
  for i=1:length(l1)
    l1(i).Color(4) = 0.4;
    l2(i).Color(4) = 0.4;
  end

  set(l1, 'LineStyle', '--')
  set(l2, 'LineStyle', '--')
  
  e1.Color = color_compatible;
  e2.Color = color_incompatible;
  e1.MarkerFaceColor = color_compatible;
  e2.MarkerFaceColor = color_incompatible;

  set(e1, 'LineWidth', 0.8)
  set(e2, 'LineWidth', 0.8)

  set(gca, 'Box', 'off') % removes upper and right axis

  xticks(x)
  xticklabels(round(x, 1)) 
  xlim(xlimits)
  ylim(ylimits)
  
  lgd = legend('Compatible','Incompatible');
  lgd.Location = lgd_location;
  lgd.Color = 'none';
  
  stitle = sprintf('Action (N=%d)', height(data1));
  title(stitle);
  xlabel('Presentation Time [ms]')
  ylabel('Reaction Time [ms]')


  % PLOT : SCENE (Compatible vs Incompatible) =============================
  subplot(1,2,2);
  
  data1 = dataCC;
  data2 = dataCI;

  %[y1, err1] = meanCIgroup(data1); % 95% CI
  %[y2, err2] = meanCIgroup(data2); % 95% CI
  [y1, err1] = meanSEgroup(data1); % Standard error
  [y2, err2] = meanSEgroup(data2); % Standard error

  e1 = errorbar(x-1.5, y1, err1);
  %e1 = plot(x-1.5, data1, '-o', 'Color', color_compatible);
  hold on
  e2 = errorbar(x+1.5, y2, err2);
  %e2 = plot(x+1.5, data2, '-o', 'Color', color_incompatible);
   l1 = plot(x, data1', 'Color', color_compatible);
  l2 = plot(x, data2', 'Color', color_incompatible);
  hold off

  e1.Marker = mark_act;
  e2.Marker = mark_act;

  % Transparency for individual lines
  for i=1:length(l1)
    l1(i).Color(4) = 0.4;
    l2(i).Color(4) = 0.4;
  end

  set(l1, 'LineStyle', '--')
  set(l2, 'LineStyle', '--')
  
  e1.Color = color_compatible;
  e2.Color = color_incompatible;
  e1.MarkerFaceColor = color_compatible;
  e2.MarkerFaceColor = color_incompatible;

  set(e1, 'LineWidth', 0.8)
  set(e2, 'LineWidth', 0.8)

  set(gca, 'Box', 'off') % removes upper and right axis

  xticks(x)
  xticklabels(round(x, 1)) 
  xlim(xlimits)
  ylim(ylimits)
  
  lgd = legend('Compatible','Incompatible');
  lgd.Location = lgd_location;
  lgd.Color = 'none';
  
  stitle = sprintf('Scene (N=%d)', height(data1));
  title(stitle);
  xlabel('Presentation Time [ms]')
  %ylabel('RT [ms]')

  % SAVE PLOTS ============================================================
  if save_plots
    % define resolution figure to be saved in dpi
    res = 420;
    % recalculate figure size to be saved
    set(fh,'PaperPositionMode','manual')
    fh.PaperUnits = 'inches';
    fh.PaperPosition = [0 0 4500 1500]/res;
    print('-dpng','-r300','plots/groupdRT_post-pilot')
    %exportgraphics(fh, 'plots/ppilotDprime_context.eps')
  end
end % if make_plots
end
