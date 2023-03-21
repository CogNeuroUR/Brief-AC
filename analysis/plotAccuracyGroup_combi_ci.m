function groupAcc = plotAccuracyGroup_combi_ci(save_plots)
%function [rt_act_con, rt_ctx_con, rt_act_inc, rt_ctx_inc] =...
%          computeRTstatistics(ExpInfo, key_yes, key_no, make_plots, save_plots)
% Computes Accuracy group statistics (mean & std) per condition for each probe type and
% congruency.
%
% Written for BriefAC (AinC)
% Vrabie 2022
make_plots = 1;
%save_plots = 1;

%% Collect results from files : ExpInfo-s
% get list of files
path_results = 'results/final/';

[groupAcc, l_subjects] = extract_groupAcc(path_results);

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
  xfactor = 1000/60;
  %ylimits = [20 105];
  ylimits = [-15 59];
  xlimits = [1.6 8.4]*xfactor;
  x = [2:6 8]*xfactor; % in ms

  % PLOT 1 (Actions vs Context : Compatible) ===============================
  subplot(2,2,1);
  % Define indices for for condition category
  i1 = [1, 6];         % ACTION Probe & COMPATIBLE
  i2 = [13, 18];       % CONTEXT Probe & COMPATIBLE
  
  data1 = [groupAcc(:,i1(1):i1(2))]-50;
  data2 = [groupAcc(:,i2(1):i2(2))]-50;
  
  [y1, err1] = meanCIgroup(data1);
  [y2, err2] = meanCIgroup(data2);

  y = [y1; y2]';
  err = [err1; err2]';

  b = bar(x, y);
  hold on
  % From https://stackoverflow.com/a/59257318
  for k = 1:size(y,2)
    % get x positions per group
    xpos = b(k).XData + b(k).XOffset;
    % draw errorbar
    errorbar(xpos, y(:,k), err(:,k), 'LineStyle', 'none', ... 
        'Color', 'k', 'LineWidth', 1);
  end

  xticks(x)
  xticklabels(round(x, 1)) 
  xlim(xlimits)
  ylim(ylimits)
  
  lgd = legend('Actions','Context');
  lgd.Location = 'northeast';
  lgd.Color = 'none';

  stitle = sprintf('COMPATIBLE (N=%d)', height(groupAcc));
  title(stitle);
  ylabel('Accuracy [%] - Chance')

  % PLOT 2 : Actions vs Context : Incompatible =============================
  subplot(2,2,2);
  % Define indices for for condition category
  i1 = [7, 12];         % ACTION Probe & INCOMPATIBLE
  i2 = [19, 24];        % CONTEXT Probe & INCOMPATIBLE
  
  data1 = [groupAcc(:,i1(1):i1(2))]-50;
  data2 = [groupAcc(:,i2(1):i2(2))]-50;
  
  [y1, err1] = meanCIgroup(data1);
  [y2, err2] = meanCIgroup(data2);
  
  y = [y1; y2]';
  err = [err1; err2]';

  b = bar(x, y);
  hold on
  % From https://stackoverflow.com/a/59257318
  for k = 1:size(y,2)
    % get x positions per group
    xpos = b(k).XData + b(k).XOffset;
    % draw errorbar
    errorbar(xpos, y(:,k), err(:,k), 'LineStyle', 'none', ... 
        'Color', 'k', 'LineWidth', 1);
  end

  xticks(x)
  xticklabels(round(x, 1)) 
  xlim(xlimits)
  ylim(ylimits)

  lgd = legend('Actions','Context');
  lgd.Location = 'northeast';
  lgd.Color = 'none';

  stitle = sprintf('INCOMPATIBLE (N=%d)', height(groupAcc));
  title(stitle);

  % PLOT 3 : Difference (Context - Action) ================================
  subplot(2,2,[3,4]);  

  % General parameters
  ylimits = [-40 35];
  x = [1:6 8];
  xlabels = {'33.3', '50.0', '66.6', '83.3', '100.0', '133.3', 'Overall'};

  % Define indices for for condition category
  i1 = [1, 6];          % ACTION Probe & COMPATIBLE
  i2 = [13, 18];        % CONTEXT Probe & COMPATIBLE
  i3 = [7, 12];         % ACTION Probe & INCOMPATIBLE
  i4 = [19, 24];        % CONTEXT Probe & INCOMPATIBLE
  
  data1 = [groupAcc(:,i1(1):i1(2))];
  data2 = [groupAcc(:,i2(1):i2(2))];
  data3 = [groupAcc(:,i3(1):i3(2))];
  data4 = [groupAcc(:,i4(1):i4(2))];

  diff_compatible = data2 - data1;
  diff_incompatible = data4 - data3;
  
  [y1, err1] = meanCIgroup(diff_compatible);
  [y2, err2] = meanCIgroup(diff_incompatible);

  % Append "overall" mean to y1 and y2
  [y1(end+1), err1(end+1)] = simple_ci(y1);
  [y2(end+1), err2(end+1)] = simple_ci(y2);

  y = [y1; y2]';
  err = [err1; err2]';

  b = bar(x, y);
  hold on
  % From https://stackoverflow.com/a/59257318
  for k = 1:size(y,2)
    % get x positions per group
    xpos = b(k).XData + b(k).XOffset;
    % draw errorbar
    errorbar(xpos, y(:,k), err(:,k), 'LineStyle', 'none', ... 
        'Color', 'k', 'LineWidth', 1);
  end

  xticks(x)
  xticklabels(xlabels)
  %xlim(xlimits)
  ylim(ylimits)
  
  lgd = legend('Compatible','Incompatible');
  lgd.Location = 'northeast';
  lgd.Color = 'none';

  stitle = sprintf('Context - Action (N=%d)', height(groupAcc));
  title(stitle);
  xlabel('Presentation Time [ms]')
  ylabel('Accuracy difference (C-A) [%]')

  % SAVE PLOTS ============================================================
  if save_plots
     % define resolution figure to be saved in dpi
   res = 420;
   % recalculate figure size to be saved
   set(fh,'PaperPositionMode','manual')
   fh.PaperUnits = 'inches';
   fh.PaperPosition = [0 0 4800 2500]/res;
   print('-dpng','-r300',['plots/group_accuracy_statistics_combi_ciudat'])
  end
end % if make_plots

%% ########################################################################
% Confidence intervals
%% ########################################################################
%% Extract data & average across PTs
% for context & action
% for compatible & incompatible
i1 = [1, 6];         % ACTION Probe & COMPATIBLE
i2 = [13, 18];       % CONTEXT Probe & COMPATIBLE
data_act_c = [groupAcc(:,i1(1):i1(2))];
data_ctx_c = [groupAcc(:,i2(1):i2(2))];

i1 = [7, 12];         % ACTION Probe & INCOMPATIBLE
i2 = [19, 24];        % CONTEXT Probe & INCOMPATIBLE
data_act_i = [groupAcc(:,i1(1):i1(2))];
data_ctx_i = [groupAcc(:,i2(1):i2(2))];

% Averaging across PTs -> (N_subjs, 1)
avg_act_c = mean(data_act_c, 2);
avg_ctx_c = mean(data_ctx_c, 2);
avg_act_i = mean(data_act_i, 2);
avg_ctx_i = mean(data_ctx_i, 2);

%% Compute CI
stats = [];
data = [avg_act_c'; avg_ctx_c'; avg_act_i';  avg_ctx_i'];

for i=1:4
  x = data(i, :);
  SEM = std(x)/sqrt(length(x));               % Standard Error
  ts = tinv([0.025  0.975],length(x)-1);      % T-Score
  CI = mean(x) + ts*SEM;                      % Confidence Intervals
  %stats = [stats; mean(x), abs(CI(1) - mean(x))];
  stats = [stats; mean(x), CI];
end

%% Print a table
fprintf('\nProbe Type | M(Acc) | CI_95(Acc)\n')
fprintf('-----------------------------------\n')
probes_ = ["AC", "CC", "AI", "CI"];
for i=1:length(stats)
  fprintf('%s \t   | %.1f | [%.1f, %.1f]\n', probes_(i), stats(i, 1),...
    stats(i, 2), stats(i, 3))
end

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

%% ------------------------------------------------------------------------
function [groupAcc, l_subjects] = extract_groupAcc(path_results)
  groupAcc = [];
  l_subjects = {};

  l_files = dir(path_results);
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
end