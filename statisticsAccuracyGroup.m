function groupAcc = statisticsAccuracyGroup(save_plots)
%function [rt_act_con, rt_ctx_con, rt_act_inc, rt_ctx_inc] =...
%          computeRTstatistics(ExpInfo, key_yes, key_no, make_plots, save_plots)
% Computes Accuracy group statistics (mean & std) per condition for each probe type and
% congruency.
%
% Written for BriefAC (AinC)
% Vrabie 2022
make_plots = 1;

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
        if isequal(ExpInfo.Cfg.probe.keyYes, {'left'})
          key_yes = 37;
          key_no = 39;
        else
          key_yes = 39;
          key_no = 37;
        end
        l_subjects = [l_subjects, fName];

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
% Plots [CONGRUENT]
%% ########################################################################
if make_plots
  fh = figure;
  
  % General parameters
  xfactor = 1000/60;
  ylimits = [20 105];
  xlimits = [1.6 8.4]*xfactor;
  x = [2:6 8]*xfactor; % in ms

  % PLOT 1 : CONGRUENT (Actions vs Context) ===============================
  subplot(2,2,1);
  % Define indices for for condition category
  i1 = [1, 6];         % ACTION Probe & CONGRUENT
  i2 = [13, 18];       % CONTEXT Probe & CONGRUENT
  
  data1 = [groupAcc(:,i1(1):i1(2))];
  data2 = [groupAcc(:,i2(1):i2(2))];
  
  y1 = mean(data1);
  y2 = mean(data2);
  
  err1 = std(data1) / sqrt(length(data1));
  err2 = std(data2) / sqrt(length(data2));
  
  e1 = errorbar(x, y1, err1);
  hold on
  e2 = errorbar(x, y2, err2);
  hold on
  % data from individual subjects
  l1 = plot(x, data1);
  hold on
  l2 = plot(x, data2);
  
  e1.Marker = "x";
  e2.Marker = "o";

  set(e1, 'LineWidth', 0.8)
  set(e2, 'LineWidth', 0.8)
  set(l1, 'Color', [0, 0.4470, 0.7410, 0.3])
  set(l2, 'Color', [0.8500, 0.3250, 0.0980, 0.3])
  set(l1, 'LineStyle', '--')
  set(l2, 'LineStyle', '--')

  xticks(x)
  xticklabels(round(x, 2)) 
  xlim(xlimits)
  ylim(ylimits)
  
  lgd = legend('Actions','Context');
  lgd.Location = 'northwest';
  lgd.Color = 'none';

  stitle = sprintf('Accuracy : CONGRUENT (N=%d)', height(groupAcc));
  title(stitle);
  xlabel('Presentation Time [ms]')
  ylabel('Accuracy [%]')

  % PLOT 2 : INCONGRUENT (Actions vs Context) =============================
  subplot(2,2,2);
  % Define indices for for condition category
  i1 = [7, 12];         % ACTION Probe & INCONGRUENT
  i2 = [19, 24];        % CONTEXT Probe & INCONGRUENT
  
  data1 = [groupAcc(:,i1(1):i1(2))];
  data2 = [groupAcc(:,i2(1):i2(2))];
  
  y1 = mean(data1);
  y2 = mean(data2);
  
  err1 = std(data1) / sqrt(length(data1));
  err2 = std(data2) / sqrt(length(data2));
  
  e1 = errorbar(x, y1, err1);
  hold on
  e2 = errorbar(x, y2, err2);
  hold on
  % data from individual subjects
  l1 = plot(x, data1);
  hold on
  l2 = plot(x, data2);
  
  e1.Marker = "x";
  e2.Marker = "o";

  set(e1, 'LineWidth', 0.8)
  set(e2, 'LineWidth', 0.8)
  set(l1, 'Color', [0, 0.4470, 0.7410, 0.3])
  set(l2, 'Color', [0.8500, 0.3250, 0.0980, 0.3])
  set(l1, 'LineStyle', '--')
  set(l2, 'LineStyle', '--')
  
  xticks(x)
  xticklabels(round(x, 2)) 
  xlim(xlimits)
  ylim(ylimits)

  lgd = legend('Actions','Context');
  lgd.Location = 'northwest';
  lgd.Color = 'none';
  
  stitle = sprintf('Accuracy : INCONGRUENT (N=%d)', height(groupAcc));
  title(stitle);
  xlabel('Presentation Time [ms]')
  ylabel('Accuracy [%]')

  % PLOT 3 : ACTIONS (Congruent vs Incongruent) ===========================
  subplot(2,2,3);
  % Define indices for for condition category
  i1 = [1, 6];         % ACTION Probe & Congruent
  i2 = [7, 12];        % ACTION Probe & Incongruent
  
  data1 = [groupAcc(:,i1(1):i1(2))];
  data2 = [groupAcc(:,i2(1):i2(2))];
  
  y1 = mean(data1);
  y2 = mean(data2);
  
  err1 = std(data1) / sqrt(length(data1));
  err2 = std(data2) / sqrt(length(data2));
  
  e1 = errorbar(x, y1, err1);
  hold on
  e2 = errorbar(x, y2, err2);
  hold on
  % data from individual subjects
  l1 = plot(x, data1);
  hold on
  l2 = plot(x, data2);
  
  e1.Marker = "x";
  e2.Marker = "o";

  set(e1, 'LineWidth', 0.8)
  set(e2, 'LineWidth', 0.8)
  set(l1, 'Color', [0, 0.4470, 0.7410, 0.3])
  set(l2, 'Color', [0.8500, 0.3250, 0.0980, 0.3])
  set(l1, 'LineStyle', '--')
  set(l2, 'LineStyle', '--')

  xticks(x)
  xticklabels(round(x, 2)) 
  xlim(xlimits)
  ylim(ylimits)

  lgd = legend('Congruent','Incongruent');
  lgd.Location = 'northwest';
  lgd.Color = 'none';
  
  stitle = sprintf('Accuracy : ACTIONS (N=%d)', height(groupAcc));
  title(stitle);
  xlabel('Presentation Time [ms]')
  ylabel('Accuracy [%]')

  % PLOT 4 : CONTEXT (Congruent vs Incongruent) ===========================
  subplot(2,2,4);
  % Define indices for for condition category
  i1 = [13, 18];         % CONTEXT Probe & Congruent
  i2 = [19, 24];        % CONTEXT Probe & Incongruent
  
  data1 = [groupAcc(:,i1(1):i1(2))];
  data2 = [groupAcc(:,i2(1):i2(2))];
  
  y1 = mean(data1);
  y2 = mean(data2);
  
  err1 = std(data1) / sqrt(length(data1));
  err2 = std(data2) / sqrt(length(data2));
  
  e1 = errorbar(x, y1, err1);
  hold on
  e2 = errorbar(x, y2, err2);
  hold on
  % data from individual subjects
  l1 = plot(x, data1);
  hold on
  l2 = plot(x, data2);
  
  e1.Marker = "x";
  e2.Marker = "o";

  set(e1, 'LineWidth', 0.8)
  set(e2, 'LineWidth', 0.8)
  set(l1, 'Color', [0, 0.4470, 0.7410, 0.3])
  set(l2, 'Color', [0.8500, 0.3250, 0.0980, 0.3])
  set(l1, 'LineStyle', '--')
  set(l2, 'LineStyle', '--')

  xticks(x)
  xticklabels(round(x, 2)) 
  xlim(xlimits)
  ylim(ylimits)

  lgd = legend('Congruent','Incongruent');
  lgd.Location = 'northwest';
  lgd.Color = 'none';

  stitle = sprintf('Accuracy : CONTEXT (N=%d)', height(groupAcc));
  title(stitle);
  xlabel('Presentation Time [ms]')
  ylabel('Accuracy [%]')

  % SAVE PLOTS ============================================================
  if save_plots
     % define resolution figure to be saved in dpi
   res = 420;
   % recalculate figure size to be saved
   set(fh,'PaperPositionMode','manual')
   fh.PaperUnits = 'inches';
   fh.PaperPosition = [0 0 4800 2500]/res;
   print('-dpng','-r300',['plots/group_accuracy_statistics'])
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