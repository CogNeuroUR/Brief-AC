function groupAcc = plotAccuracyGroup_recoded(save_plots)
%function [rt_act_con, rt_ctx_con, rt_act_inc, rt_ctx_inc] =...
%          computeRTstatistics(ExpInfo, key_yes, key_no, make_plots, save_plots)
% Computes Accuracy group statistics (mean & std) per condition for each probe type and
% congruency.
%
% Written for BriefAC (AinC)
% Vrabie 2022
make_plots = 1;
%save_plots = 0;

%%
info = getFactorialStructure();


%% Collect results from files : ExpInfo-s
% get list of files
path_results = 'results/final/';
l_files = dir(path_results);

groupAcc = [];
l_subjects = {};

% iterate over files
fprintf('Sweeping through files ...\n');
for i=1:length(l_files)
  path2file = [path_results, l_files(i).name];
  
  % check if of mat-extension
  [~, fName, fExt] = fileparts(l_files(i).name);
  
  switch fExt
    case '.mat'
      % ignore demo-results
      if ~contains(l_files(i).name, 'demo')
        fprintf('\tLoading : %s\n', l_files(i).name);
        clear ExpInfo;
        load(path2file, 'ExpInfo');

        % perform analysis
        % 1) Extract trials for each probe by decoding trials' ASF code
        [trialsAC, trialsCC, trialsAI, trialsCI] = getTrialResponses(ExpInfo);

        % 2) Extract statistics: hits, false alarms and their rates
        % by PROBE TYPE & CONGRUENCY
        key_yes = ExpInfo.Cfg.Probe.keyYes;
        key_no = ExpInfo.Cfg.Probe.keyNo;
        l_subjects = [l_subjects, fName];

        % =================================================================
        % RECODE CORRECT RESPONSES for "Context":
        % =================================================================
        % IF probed with context, consider correct context the source
        % context of the TARGET ACTION.
        % 1) COMPATIBLE
        for i=1:height(trialsCC)
          % extract source context of the target action
          [idx_ctx, ~] = find(info.ActionLevels == trialsCC.Target_Action(i));
          src_ctx = info.ContextLevels(idx_ctx);

          % check if source context is equal to probed context
          if trialsCC.Probe(i) == src_ctx
            trialsCC.TrueKey(i) = key_yes;
          else
            trialsCC.TrueKey(i) = key_no;
          end
        end
        % 2) INCOMPATIBLE
        for i=1:height(trialsCI)
          % extract source context of the target action
          [idx_ctx, ~] = find(info.ActionLevels == trialsCI.Target_Action(i));
          src_ctx = info.ContextLevels(idx_ctx);

          % check if source context is equal to probed context
          if trialsCI.Probe(i) == src_ctx
            trialsCI.TrueKey(i) = key_yes;
          else
            trialsCI.TrueKey(i) = key_no;
          end
        end
        % =================================================================


        % Extract RT = f(presentation time) by probe type
        statsAC = getResponseStats(trialsAC, key_yes, key_no);
        statsAI = getResponseStats(trialsAI, key_yes, key_no);
        statsCC = getResponseStats(trialsCC, key_yes, key_no);
        statsCI = getResponseStats(trialsCI, key_yes, key_no);
        
        % 3) Compute accuracy
        acc_AC = accuracy(statsAC);
        acc_AI = accuracy(statsAI);
        acc_CC = accuracy(statsCC);
        acc_CI = accuracy(statsCI);


        % 3) Dump RTs ONLY in the matrix as rows (ONE PER SUBJECT)
        groupAcc = [groupAcc; acc_AC, acc_AI, acc_CC, acc_CI];

      end
    otherwise
      continue
  end % switch

end

%% Define CONDITION NAMES for plotting (+ TABLE (auxiliary!))
%groupAcc = array2table(groupAcc); %array2table(zeros(0,24));
probes = ["AC", "AI", "CC", "CI"];
times = [2:6 8];
vars = {};

for iP=1:length(probes)
  for iT=1:length(times)
    vars = [vars; sprintf('%s_%d', probes(iP), times(iT))];
  end
end

%% ########################################################################
% Plots [COMPATIBLE]
%% ########################################################################
if make_plots
  fh = figure;
  
  % General parameters
  mark_ctx = "s";
  mark_act = "o";
  color_act = "#EDB120";
  color_ctx = "#7E2F8E";
  color_compatible = "#77AC30";
  color_incompatible = "#D95319";

  lgd_location = 'northeast';
  xfactor = 1000/60;
  ylimits = [20 105];
  xlimits = [1.6 9.4]*xfactor;
  x = [2:6 8]*xfactor; % in ms
  xlabels = {'33.3', '50.0', '66.6', '83.3', '100.0', '133.3', 'Overall'};

  % PLOT 1 : COMPATIBLE (Actions vs Context) ===============================
  subplot(2,2,1);
  % Define indices for for condition category
  i1 = [1, 6];         % ACTION Probe & COMPATIBLE
  i2 = [13, 18];       % CONTEXT Probe & COMPATIBLE
  
  data1 = [groupAcc(:,i1(1):i1(2))];
  data2 = [groupAcc(:,i2(1):i2(2))];
  
%   y1 = mean(data1);
%   y2 = mean(data2);
%   
%   err1 = std(data1) / sqrt(length(data1));
%   err2 = std(data2) / sqrt(length(data2));
  
  [y1, err1] = meanCIgroup(data1);
  [y2, err2] = meanCIgroup(data2);
  % Add Overall
  [b1, ber1] = simple_ci(y1);
  [b2, ber2] = simple_ci(y2);
  xe = 150;
  
  e1 = errorbar(x-1.5, y1, err1);
  hold on
  e2 = errorbar(x+1.5, y2, err2);
  e3 = errorbar(xe-1.5, b1, ber1);
  e4 = errorbar(xe+1.5, b2, ber2);
  % data from individual subjects
  l1 = plot(x, data1, 'Color',color_act);
  l2 = plot(x, data2, 'Color',color_ctx);
  hold off
  
  e1.Marker = mark_act;
  e2.Marker = mark_ctx;
  e3.Marker = mark_act;
  e4.Marker = mark_ctx;
  
  e1.Color = color_compatible;
  e2.Color = color_compatible;
  e3.Color = color_compatible;
  e4.Color = color_compatible;

  % Transparency for individual lines
  for i=1:length(l1)
    l1(i).Color(4) = 0.4;
    l2(i).Color(4) = 0.4;
  end

  e1.MarkerFaceColor = color_compatible;
  e2.MarkerFaceColor = color_compatible;
  e3.MarkerFaceColor = color_compatible;
  e4.MarkerFaceColor = color_compatible;

  set(e1, 'LineWidth', 0.8)
  set(e2, 'LineWidth', 0.8)
  set(l1, 'LineStyle', '--')
  set(l2, 'LineStyle', '--')
  
  xticks([x, xe])
  xticklabels(xlabels) 
  xlim(xlimits)
  ylim(ylimits)
  
  lgd = legend('Actions','Context');
  lgd.Location = 'northwest';
  lgd.Color = 'none';

  stitle = sprintf('COMPATIBLE (N=%d)', height(groupAcc));
  title(stitle);
  %xlabel('Presentation Time [ms]')
  ylabel('Accuracy [%]')

  fprintf('\nOverall Results: COMPATIBLE (Actions vs Context)\n')
  fprintf('\t1) Mean: %.1f, 95%%CI: [%.1f, %.1f].\n', b1, b1-ber1, b1+ber1)
  fprintf('\t2) Mean: %.1f, 95%%CI: [%.1f, %.1f].\n', b2, b2-ber2, b2+ber2)

  % PLOT 2 : INCOMPATIBLE (Actions vs Context) =============================
  subplot(2,2,2);
  % Define indices for for condition category
  i1 = [7, 12];         % ACTION Probe & INCOMPATIBLE
  i2 = [19, 24];        % CONTEXT Probe & INCOMPATIBLE
  
  data1 = [groupAcc(:,i1(1):i1(2))];
  data2 = [groupAcc(:,i2(1):i2(2))];
  
%   y1 = mean(data1);
%   y2 = mean(data2);
%   
%   err1 = std(data1) / sqrt(length(data1));
%   err2 = std(data2) / sqrt(length(data2));
  
  [y1, err1] = meanCIgroup(data1);
  [y2, err2] = meanCIgroup(data2);
  
  % Add Overall
  [b1, ber1] = simple_ci(y1);
  [b2, ber2] = simple_ci(y2);
  xe = 145;

  e1 = errorbar(x-1.5, y1, err1);
  hold on
  e2 = errorbar(x+1.5, y2, err2);
  e3 = errorbar(xe-1.5, b1, ber1);
  e4 = errorbar(xe+1.5, b2, ber2);
  % data from individual subjects
  l1 = plot(x, data1, 'Color',color_act);
  l2 = plot(x, data2, 'Color',color_ctx);
  hold off
  
  set(e1, 'LineWidth', 0.8)
  set(e2, 'LineWidth', 0.8)
  set(l1, 'LineStyle', '--')
  set(l2, 'LineStyle', '--')

  e1.Marker = mark_act;
  e2.Marker = mark_ctx;
  e3.Marker = mark_act;
  e4.Marker = mark_ctx;
  
  e1.Color = color_incompatible;
  e2.Color = color_incompatible;
  e3.Color = color_incompatible;
  e4.Color = color_incompatible;

  % Transparency for individual lines
  for i=1:length(l1)
    l1(i).Color(4) = 0.4;
    l2(i).Color(4) = 0.4;
  end

  e1.MarkerFaceColor = color_incompatible;
  e2.MarkerFaceColor = color_incompatible;
  e3.MarkerFaceColor = color_incompatible;
  e4.MarkerFaceColor = color_incompatible;

  xticks([x, xe])
  %xticklabels(round(x, 2)) 
  xticklabels(xlabels) 
  xlim(xlimits)
  ylim(ylimits)

  lgd = legend('Actions','Context');
  lgd.Location = 'northwest';
  lgd.Color = 'none';
  
  stitle = sprintf('Accuracy : INCOMPATIBLE (N=%d)', height(groupAcc));
  title(stitle);
  %xlabel('Presentation Time [ms]')
  %ylabel('Accuracy [%]')

  fprintf('\nOverall Results: INCOMPATIBLE (Actions vs Context)\n')
  fprintf('\t1) Mean: %.1f, 95%%CI: [%.1f, %.1f].\n', b1, b1-ber1, b1+ber1)
  fprintf('\t2) Mean: %.1f, 95%%CI: [%.1f, %.1f].\n', b2, b2-ber2, b2+ber2)

  % PLOT 3 : ACTIONS (Compatible vs Incompatible) ===========================
  subplot(2,2,3);
  % Define indices for for condition category
  i1 = [1, 6];         % ACTION Probe & Compatible
  i2 = [7, 12];        % ACTION Probe & Incompatible
  
  data1 = [groupAcc(:,i1(1):i1(2))];
  data2 = [groupAcc(:,i2(1):i2(2))];
  
%   y1 = mean(data1);
%   y2 = mean(data2);
%   
%   err1 = std(data1) / sqrt(length(data1));
%   err2 = std(data2) / sqrt(length(data2));
  [y1, err1] = meanCIgroup(data1);
  [y2, err2] = meanCIgroup(data2);
  
  % Add Overall
  [b1, ber1] = simple_ci(y1);
  [b2, ber2] = simple_ci(y2);
  xe = 150;
  
  e1 = errorbar(x-1.5, y1, err1);
  hold on
  e2 = errorbar(x+1.5, y2, err2);
  e3 = errorbar(xe-1.5, b1, ber1);
  e4 = errorbar(xe+1.5, b2, ber2);
  % data from individual subjects
  l1 = plot(x, data1, 'Color',color_compatible);
  l2 = plot(x, data2, 'Color',color_incompatible);
  hold off
  hold off
  
  e1.Marker = "x";
  e2.Marker = "o";

  set(e1, 'LineWidth', 0.8)
  set(e2, 'LineWidth', 0.8)
  set(l1, 'LineStyle', '--')
  set(l2, 'LineStyle', '--')

  e1.Marker = mark_act;
  e2.Marker = mark_ctx;
  e3.Marker = mark_act;
  e4.Marker = mark_ctx;
  
  e1.Color = color_compatible;
  e2.Color = color_incompatible;
  e3.Color = color_compatible;
  e4.Color = color_incompatible;

  % Transparency for individual lines
  for i=1:length(l1)
    l1(i).Color(4) = 0.4;
    l2(i).Color(4) = 0.4;
  end

  e1.MarkerFaceColor = color_compatible;
  e2.MarkerFaceColor = color_incompatible;
  e3.MarkerFaceColor = color_compatible;
  e4.MarkerFaceColor = color_incompatible;

  set(e1, 'LineWidth', 0.8)
  set(e2, 'LineWidth', 0.8)

  xticks([x, xe])
  xticklabels(xlabels) 
  xlim(xlimits)
  ylim(ylimits)

  lgd = legend('Compatible','Incompatible');
  lgd.Location = 'northwest';
  lgd.Color = 'none';
  
  stitle = sprintf('ACTIONS (N=%d)', height(groupAcc));
  title(stitle);
  xlabel('Presentation Time [ms]')
  ylabel('Accuracy [%]')

  fprintf('\nOverall Results: ACTIONS (Compatible vs Incompatible)\n')
  fprintf('\t1) Mean: %.1f, 95%%CI: [%.1f, %.1f].\n', b1, b1-ber1, b1+ber1)
  fprintf('\t2) Mean: %.1f, 95%%CI: [%.1f, %.1f].\n', b2, b2-ber2, b2+ber2)

  % PLOT 4 : CONTEXT (Compatible vs Incompatible) ===========================
  subplot(2,2,4);
  % Define indices for for condition category
  i1 = [13, 18];         % CONTEXT Probe & Compatible
  i2 = [19, 24];        % CONTEXT Probe & Incompatible
  
  data1 = [groupAcc(:,i1(1):i1(2))];
  data2 = [groupAcc(:,i2(1):i2(2))];
  
%   y1 = mean(data1);
%   y2 = mean(data2);
%   
%   err1 = std(data1) / sqrt(length(data1));
%   err2 = std(data2) / sqrt(length(data2));
  [y1, err1] = meanCIgroup(data1);
  [y2, err2] = meanCIgroup(data2);
  
  % Add Overall
  [b1, ber1] = simple_ci(y1);
  [b2, ber2] = simple_ci(y2);
  xe = 150;
  
e1 = errorbar(x-1.5, y1, err1);
  hold on
  e2 = errorbar(x+1.5, y2, err2);
  e3 = errorbar(xe-1.5, b1, ber1);
  e4 = errorbar(xe+1.5, b2, ber2);
  % data from individual subjects
  l1 = plot(x, data1, 'Color',color_compatible);
  l2 = plot(x, data2, 'Color',color_incompatible);
  hold off
  
  e1.Marker = "x";
  e2.Marker = "o";

  set(e1, 'LineWidth', 0.8)
  set(e2, 'LineWidth', 0.8)
  set(l1, 'LineStyle', '--')
  set(l2, 'LineStyle', '--')

  e1.Marker = mark_act;
  e2.Marker = mark_ctx;
  e3.Marker = mark_act;
  e4.Marker = mark_ctx;
  95%%CI
  e1.Color = color_compatible;
  e2.Color = color_incompatible;
  e3.Color = color_compatible;
  e4.Color = color_incompatible;

  % Transparency for individual lines
  for i=1:length(l1)
    l1(i).Color(4) = 0.4;
    l2(i).Color(4) = 0.4;
  end

  e1.MarkerFaceColor = color_compatible;
  e2.MarkerFaceColor = color_incompatible;
  e3.MarkerFaceColor = color_compatible;
  e4.MarkerFaceColor = color_incompatible;

  set(e1, 'LineWidth', 0.8)
  set(e2, 'LineWidth', 0.8)

  xticks([x, xe])
  xticklabels(xlabels) 
  xlim(xlimits)
  ylim(ylimits)

  lgd = legend('Compatible','Incompatible');
  lgd.Location = 'northwest';
  lgd.Color = 'none';

  stitle = sprintf('CONTEXT (N=%d)', height(groupAcc));
  title(stitle);
  xlabel('Presentation Time [ms]')
  %ylabel('Accuracy [%]')

  fprintf('\nOverall Results: CONTEXT (Compatible vs Incompatible)\n')
  fprintf('\t1) Mean: %.1f, 95%%CI: [%.1f, %.1f].\n', b1, b1-ber1, b1+ber1)
  fprintf('\t2) Mean: %.1f, 95%%CI: [%.1f, %.1f].\n', b2, b2-ber2, b2+ber2)

  % SAVE PLOTS ============================================================
  if save_plots
     % define resolution figure to be saved in dpi
   res = 420;
   % recalculate figure size to be saved
   set(fh,'PaperPositionMode','manual')
   fh.PaperUnits = 'inches';
   fh.PaperPosition = [0 0 4800 2500]/res;
   print('-dpng','-r300',['plots/group_accuracy_statistics_ci_recoded'])
  end
end % if make_plots
end

%% ------------------------------------------------------------------------
% Functions
function acc = accuracy(t_stats)
  % 1) Extract nr of HITS and CORRECT REJECTIONS
  % 2) Compute accuracy as the ration of (HITS+CORR_REJECT) / N_samples
  %fprintf('Computing accuracy ...\n')

  acc = [];
  for i=1:height(t_stats)
    % Compute accuracy as ratio
    ratio = (t_stats.Hits(i) + t_stats.CorrectRejections(i)) / t_stats.N_samples(i);
    acc = [acc, ratio * 100];
  end
end