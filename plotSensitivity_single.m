function plotSensitivity_single(save_plots)
%function [rt_act_con, rt_ctx_con, rt_act_inc, rt_ctx_inc] =...
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

statsAC = getResponseStats(trialsAC, key_yes, key_no);
statsAI = getResponseStats(trialsAI, key_yes, key_no);
statsCC = getResponseStats(trialsCC, key_yes, key_no);
statsCI = getResponseStats(trialsCI, key_yes, key_no);

% 3) Compute d-prime  
dprimeAC = dprime(statsAC);
dprimeAI = dprime(statsAI);
dprimeCC = dprime(statsCC);
dprimeCI = dprime(statsCI);

%% ########################################################################
% Plots [COMPATIBLE]
%% ########################################################################
if make_plots
  fh = figure;

  % General parameters
  mark_ctx = "s";
  mark_act = "o";
  color_compatible = "#00BF95";
  color_incompatible = "#BF002A";

  lgd_location = 'northwest';

  xfactor = 1000/60;
  ylimits = [-.2, 4];
  x = info.PresTimeLevels*xfactor; % in ms
  xlimits = [x(1) - 20, x(end) + 20];
  %xlabels = {'33.3', '50.0', '66.6', '83.3', '100.0', '133.3', 'Overall'};

  % PLOT : CONTEXT (Compatible vs Incompatible) =============================
  subplot(1,2,1);
  % Define indices for for condition category
  i1 = [13, 18];         % CONTEXT Probe & Compatible
  i2 = [19, 24];        % CONTEXT Probe & Incompatible
  
  data1 = dprimeAC';
  data2 = dprimeAI';
  
  %[y1, err1] = meanCIgroup(data1); % 95% CI
  %[y2, err2] = meanCIgroup(data2); % 95% CI
%   [y1, err1] = meanSEgroup(data1); % Standard error
%   [y2, err2] = meanSEgroup(data2); % Standard error
  
  %e1 = errorbar(x-1.5, y1, err1);
  e1 = plot(x, data1, '-o', 'Color', color_compatible);
  hold on
  %e2 = errorbar(x+1.5, y2, err2);
  e2 = plot(x, data2, '-o', 'Color', color_incompatible);
  yline(0, '--');
  hold off

%   e1.Marker = mark_act;
%   e2.Marker = mark_ctx;

%   e1.Color = color_compatible;
%   e2.Color = color_incompatible;
%   e1.MarkerFaceColor = color_compatible;
%   e2.MarkerFaceColor = color_incompatible;

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
  ylabel('Sensitivity (d'')')


  % PLOT : CONTEXT (Compatible vs Incompatible) =============================
  subplot(1,2,2);
  % Define indices for for condition category
  i1 = [13, 18];         % CONTEXT Probe & Compatible
  i2 = [19, 24];        % CONTEXT Probe & Incompatible
  
  data1 = dprimeCC';
  data2 = dprimeCI';
  
  %[y1, err1] = meanCIgroup(data1); % 95% CI
  %[y2, err2] = meanCIgroup(data2); % 95% CI
%   [y1, err1] = meanSEgroup(data1); % Standard error
%   [y2, err2] = meanSEgroup(data2); % Standard error
  
  %e1 = errorbar(x-1.5, y1, err1);
  e1 = plot(x, data1, '-o', 'Color', color_compatible);
  hold on
  %e2 = errorbar(x+1.5, y2, err2);
  e2 = plot(x, data2, '-o', 'Color', color_incompatible);
  yline(0, '--');
  hold off

%   e1.Marker = mark_act;
%   e2.Marker = mark_ctx;

%   e1.Color = color_compatible;
%   e2.Color = color_incompatible;
%   e1.MarkerFaceColor = color_compatible;
%   e2.MarkerFaceColor = color_incompatible;

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
  ylabel('Sensitivity (d'')')

  % SAVE PLOTS ============================================================
  if save_plots
    % define resolution figure to be saved in dpi
    res = 420;
    % recalculate figure size to be saved
    set(fh,'PaperPositionMode','manual')
    fh.PaperUnits = 'inches';
    fh.PaperPosition = [0 0 5000 1700]/res;
    print('-dpng','-r300','plots/sensitivity_single')
    %exportgraphics(fh, 'plots/ppilotDprime_context.eps')
  end
end % if make_plots
end