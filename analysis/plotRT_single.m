function plotRT_single(save_plots)
%function [dataAC, dataCC, dataAI, dataCI] =...
%          computeRTstatistics(ExpInfo, key_yes, key_no, make_plots, save_plots)
% Computes RT group statistics (mean & std) per condition for each probe type and
% congruency.
%
% Written for BriefAC (AinC)
% Vrabie 2023
make_plots = 1;
save_plots = 1;
path_expinfo = 'results/tests/SUB-00_left.mat';

%% Load results from file : ExpInfo
% get list of files
clear ExpInfo;
load(path_expinfo, 'ExpInfo');

info = getDesignParams();

% perform analysis
% 1) Extract trials for each probe by decoding trials' ASF code
[trialsAC, trialsCC, trialsAI, trialsCI] = getTrialResponses(ExpInfo);

% 2) Extract statistics: hits, false alarms and their rates
% by PROBE TYPE & CONGRUENCY
key_yes = ExpInfo.Cfg.Probe.keyYes;
key_no = ExpInfo.Cfg.Probe.keyNo;

dataAC = getRTstats(trialsAC);
dataCC = getRTstats(trialsCC);
dataAI = getRTstats(trialsAI);
dataCI = getRTstats(trialsCI);

%% ########################################################################
% Plots [COMPATIBLE]
%% ########################################################################
if make_plots
  fh = figure;

  % General parameters
  mark_ctx = "o";
  mark_act = "o";
  color_compatible = "#00BF95";
  color_incompatible = "#BF002A";

  lgd_location = 'northeast';

  xfactor = 1000/60;
  ylimits = [700 1400];
  x = info.PresTimeLevels*xfactor; % in ms
  xlimits = [x(1) - 20, x(end) + 20];

  % PLOT : CONTEXT (Compatible vs Incompatible) =============================
  subplot(1,2,1);
  % Define indices for for condition category
  i1 = [13, 18];         % CONTEXT Probe & Compatible
  i2 = [19, 24];        % CONTEXT Probe & Incompatible
  
  y1 = [dataAC{:, 2}];
  y2 = [dataAI{:, 2}];
  
  err1 = [dataAC{:, 3}];
  err2 = [dataAI{:, 3}];

  e1 = errorbar(x-1.5, y1, err1);
  %e1 = plot(x-1.5, data1, '-o', 'Color', color_compatible);
  hold on
  e2 = errorbar(x+1.5, y2, err2);
  %e2 = plot(x+1.5, data2, '-o', 'Color', color_incompatible);
  yline(0, '--');
  hold off

   e1.Marker = mark_act;
   e2.Marker = mark_ctx;

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
  
  stitle = sprintf('Action (N=%d)', 1);%height(data1));
  title(stitle);
  xlabel('Presentation Time [ms]')
  ylabel('RT [ms]')


  % PLOT : CONTEXT (Compatible vs Incompatible) =============================
  subplot(1,2,2);
  % Define indices for for condition category
  i1 = [13, 18];         % CONTEXT Probe & Compatible
  i2 = [19, 24];        % CONTEXT Probe & Incompatible
  
  y1 = [dataCC{:, 2}];
  y2 = [dataCI{:, 2}];
  
  err1 = [dataCC{:, 3}];
  err2 = [dataCI{:, 3}];

  e1 = errorbar(x-1.5, y1, err1);
  %e1 = plot(x-1.5, data1, '-o', 'Color', color_compatible);
  hold on
  e2 = errorbar(x+1.5, y2, err2);
  %e2 = plot(x+1.5, data2, '-o', 'Color', color_incompatible);
  yline(0, '--');
  hold off

  e1.Marker = mark_act;
  e2.Marker = mark_ctx;

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
  
  stitle = sprintf('Scene (N=%d)', 1); %height(data1));
  title(stitle);
  xlabel('Presentation Time [ms]')
  ylabel('RT [ms]')

  % SAVE PLOTS ============================================================
  if save_plots
    % define resolution figure to be saved in dpi
    res = 420;
    % recalculate figure size to be saved
    set(fh,'PaperPositionMode','manual')
    fh.PaperUnits = 'inches';
    fh.PaperPosition = [0 0 5000 1700]/res;
    print('-dpng','-r300','plots/RT_single')
    %exportgraphics(fh, 'plots/ppilotDprime_context.eps')
  end
end % if make_plots
end