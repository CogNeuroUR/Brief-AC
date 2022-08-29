function groupRT = statisticsRTgroup_AvC_(save_plots)
%function [rt_act_con, rt_ctx_con, rt_act_inc, rt_ctx_inc] =...
%          computeRTstatistics(ExpInfo, key_yes, key_no, make_plots, save_plots)
% Computes RT group statistics (mean & std) per condition for each probe type and
% congruency.
%
% Written for BriefAC (AinC)
% Vrabie 2022
make_plots = 1;
%save_plots = 0;

%% Collect results from files : ExpInfo-s
% get list of files
path_results = 'results/final/';

[groupRT, ~] = extract_groupRT(path_results);

%% ########################################################################
% Plots [CONGRUENT]
%% ########################################################################
if make_plots
  fh = figure;

  % General parameters
  mark_ctx = "s";
  mark_act = "o";
  color_act = "#EDB120";
  color_ctx = "#7E2F8E";

  lgd_location = 'northeast';
  %mark_colors = ["#0072BD", "#D95319"];

  xfactor = 1000/60;
  ylimits = [670 1050]; % without individual lines
  %ylimits = [490 1250];
  xlimits = [1.6 9.4]*xfactor;
  %x = [2:6 8]*xfactor; % in ms
  ylimits = [-100 100];
  %xlimits = [1.6 8.4]*xfactor;
  x = [1:6 8];
  xlabels = {'33.3', '50.0', '66.6', '83.3', '100.0', '133.3', 'Overall'};

  % Define indices for for condition category
  i1 = [1, 6];          % ACTION Probe & CONGRUENT
  i2 = [13, 18];        % CONTEXT Probe & CONGRUENT
  i3 = [7, 12];         % ACTION Probe & INCONGRUENT
  i4 = [19, 24];        % CONTEXT Probe & INCONGRUENT
  
  data1 = [groupRT(:,i1(1):i1(2))];
  data2 = [groupRT(:,i2(1):i2(2))];
  data3 = [groupRT(:,i3(1):i3(2))];
  data4 = [groupRT(:,i4(1):i4(2))];
  
  % compute differences in RT : Action - Context
  diff_congruent = data1 - data3;
  diff_incongruent = data2 - data4;

  [y1, err1] = statisticsSampleConditional(diff_congruent);
  [y2, err2] = statisticsSampleConditional(diff_incongruent);
  
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
        'Color', 'k', 'LineWidth', 0.65);
  end

  b(1).FaceColor = color_act;
  b(2).FaceColor = color_ctx;

  xticks(x)
  xticklabels(xlabels) 
  ylim(ylimits)
  
  lgd = legend('Action', 'Context');
  lgd.Location = lgd_location;
  lgd.Color = 'none';

  stitle = sprintf('Compatible - Incompatible (N=%d)', height(groupRT));
  title(stitle);
  xlabel('Presentation Time [ms]')
  ylabel('RT difference : C - I [ms]')

  % SAVE PLOTS ============================================================
  if save_plots
     % define resolution figure to be saved in dpi
   res = 420;
   % recalculate figure size to be saved
   set(fh,'PaperPositionMode','manual')
   fh.PaperUnits = 'inches';
   fh.PaperPosition = [0 0 2500 1500]/res;
   print('-dpng','-r300',['plots/groupRT_CvI'])
  end
end % if make_plots
end

%% ------------------------------------------------------------------------
function stats = getRTstats(t_trials)
  % t_trials : table
  % iterate over unique values in PresTime and compute mean & std for each
  %fprintf('Collecting RTs...\n')

  stats = {};
  uniqTimes = unique(t_trials.PresTime);
  
  %fprintf('\nTarget duration: mean & std RT\n')
  for i=1:length(uniqTimes)
    values = t_trials.RT(t_trials.PresTime==uniqTimes(i));
    if isequal(class(values), 'cell'); values = cell2mat(values); end
    avg = nanmean(values);
    %stdev = nanstd(values); % SD
    stderr = nanstd(values) / sqrt(length(values)); % SE : standard error
    % Verbose
    %fprintf('PresTime: %d; Mean RT: %.2fms; SE RT: %.2fms\n',...
    %        uniqTimes(i), avg, stderr);
    
    stats(end+1, :) = {uniqTimes(i), avg, stderr};
  end
end

%% ------------------------------------------------------------------------
function [groupRT, l_subjects] = extract_groupRT(path_results)
  l_files = dir(path_results);
  
  groupRT = [];
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
          statsAC = getRTstats(trialsAC);
          statsCC = getRTstats(trialsCC);
          statsAI = getRTstats(trialsAI);
          statsCI = getRTstats(trialsCI);
          
          % 3) Dump RTs ONLY in the matrix as rows (ONE PER SUBJECT)
          groupRT = [groupRT;...
                     [statsAC{:,2}], [statsAI{:,2}],...
                     [statsCC{:,2}], [statsCI{:,2}]];
        end
      otherwise
        continue
    end % switch
  
  end
end