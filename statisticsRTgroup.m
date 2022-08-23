function groupRT = statisticsRTgroup(save_plots)
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

[groupRT, l_subjects] = extract_groupRT(path_results);

%% Define CONDITION NAMES for plotting (+ TABLE (auxiliary!))
%groupRT = array2table(groupRT); %array2table(zeros(0,24));
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
  mark_ctx = "s";
  mark_act = "o";
  color_act = "#EDB120";
  color_ctx = "#7E2F8E";
  color_congruent = "#77AC30";
  color_incongruent = "#D95319";

  lgd_location = 'northeast';
  %mark_colors = ["#0072BD", "#D95319"];

  xfactor = 1000/60;
  ylimits = [700 1050]; % without individual lines
  %ylimits = [490 1250];
  xlimits = [1.6 9.4]*xfactor;
  %x = [2:6 8]*xfactor; % in ms
  x = [2:7]*xfactor; % in ms
  %x = [1:6];
  xlabels = {'33.3', '50.0', '66.6', '83.3', '100.0', '133.3', 'Overall'};

  % PLOT 1 : CONGRUENT (Actions vs Context) ===============================
  subplot(2,2,1);
  % Define indices for for condition category
  i1 = [1, 6];         % ACTION Probe & CONGRUENT
  i2 = [13, 18];       % CONTEXT Probe & CONGRUENT
  
  data1 = [groupRT(:,i1(1):i1(2))];
  data2 = [groupRT(:,i2(1):i2(2))];
  
  [y1, err1] = statisticsSampleConditional(data1);
  [y2, err2] = statisticsSampleConditional(data2);
  % Add Overall
  [b1, ber1] = simple_ci(y1);
  [b2, ber2] = simple_ci(y2);
  xe = 150;
  
  e1 = errorbar(x-1.5, y1, err1);
  hold on
  e2 = errorbar(x+1.5, y2, err2);
  hold on
  e3 = errorbar(xe-1.5, b1, ber1);
  hold on
  e4 = errorbar(xe+1.5, b2, ber2);
  
  e1.Marker = mark_act;
  e2.Marker = mark_ctx;
  e3.Marker = mark_act;
  e4.Marker = mark_ctx;
  
  e1.Color = color_congruent;
  e2.Color = color_congruent;
  e3.Color = color_congruent;
  e4.Color = color_congruent;
  e1.MarkerFaceColor = color_congruent;
  e2.MarkerFaceColor = color_congruent;
  e3.MarkerFaceColor = color_congruent;
  e4.MarkerFaceColor = color_congruent;

  set(e1, 'LineWidth', 0.8)
  set(e2, 'LineWidth', 0.8)

  
  xticks([x, xe])
  xticklabels(xlabels) 
  xlim(xlimits)
  ylim(ylimits)
  
  lgd = legend('Actions','Context');
  lgd.Location = lgd_location;
  lgd.Color = 'none';

  stitle = sprintf('CONGRUENT (N=%d)', height(groupRT));
  title(stitle);
  %xlabel('Presentation Time [ms]')
  ylabel('RT [ms]')

  % PLOT 2 : INCONGRUENT (Actions vs Context) =============================
  subplot(2,2,2);
  % Define indices for for condition category
  i1 = [7, 12];         % ACTION Probe & INCONGRUENT
  i2 = [19, 24];        % CONTEXT Probe & INCONGRUENT
  
  data1 = [groupRT(:,i1(1):i1(2))];
  data2 = [groupRT(:,i2(1):i2(2))];
  
  [y1, err1] = statisticsSampleConditional(data1);
  [y2, err2] = statisticsSampleConditional(data2);
  
  e1 = errorbar(x-1.5, y1, err1);
  hold on
  e2 = errorbar(x+1.5, y2, err2);
  hold on
  % Add Overall
  [b1, ber1] = simple_ci(y1);
  [b2, ber2] = simple_ci(y2);
  
  xe = 145;
  e3 = errorbar(xe-1.5, b1, ber1);
  hold on
  e4 = errorbar(xe+1.5, b2, ber2);
%   % data from individual subjects
%   l1 = plot(x, data1);
%   hold on
%   l2 = plot(x, data2);
  
  e1.Marker = mark_act;
  e2.Marker = mark_ctx;
  e3.Marker = mark_act;
  e4.Marker = mark_ctx;
  
  e1.Color = color_incongruent;
  e2.Color = color_incongruent;
  e3.Color = color_incongruent;
  e4.Color = color_incongruent;

  e1.MarkerFaceColor = color_incongruent;
  e2.MarkerFaceColor = color_incongruent;
  e3.MarkerFaceColor = color_incongruent;
  e4.MarkerFaceColor = color_incongruent;

  set(e1, 'LineWidth', 0.8)
  set(e2, 'LineWidth', 0.8)
  
%   set(l1, 'Color', [0, 0.4470, 0.7410, 0.3])
%   set(l2, 'Color', [0.8500, 0.3250, 0.0980, 0.3])
%   set(l1, 'LineStyle', '--')
%   set(l2, 'LineStyle', '--')

  xticks([x, xe])
  %xticklabels(round(x, 2)) 
  xticklabels(xlabels) 
  xlim(xlimits)
  ylim(ylimits)

  lgd = legend('Actions','Context');
  lgd.Location = lgd_location;
  lgd.Color = 'none';

  stitle = sprintf('INCONGRUENT (N=%d)', height(groupRT));
  title(stitle);
  %xlabel('Presentation Time [ms]')
  %ylabel('RT [ms]')

  % PLOT 3 : ACTIONS (Congruent vs Incongruent) ===========================
  subplot(2,2,3);
  % Define indices for for condition category
  i1 = [1, 6];         % ACTION Probe & Congruent
  i2 = [7, 12];        % ACTION Probe & Incongruent
  
  data1 = [groupRT(:,i1(1):i1(2))];
  data2 = [groupRT(:,i2(1):i2(2))];
  
  [y1, err1] = statisticsSampleConditional(data1);
  [y2, err2] = statisticsSampleConditional(data2);
  
  % Add Overall
  [b1, ber1] = simple_ci(y1);
  [b2, ber2] = simple_ci(y2);
  xe = 150;
  
  e1 = errorbar(x-1.5, y1, err1);
  hold on
  e2 = errorbar(x+1.5, y2, err2);
  hold on
  e3 = errorbar(xe-1.5, b1, ber1);
  hold on
  e4 = errorbar(xe+1.5, b2, ber2);
  
  e1.Marker = mark_act;
  e2.Marker = mark_ctx;
  e3.Marker = mark_act;
  e4.Marker = mark_ctx;
  
  e1.Color = color_congruent;
  e2.Color = color_incongruent;
  e3.Color = color_congruent;
  e4.Color = color_incongruent;
  e1.MarkerFaceColor = color_congruent;
  e2.MarkerFaceColor = color_incongruent;
  e3.MarkerFaceColor = color_congruent;
  e4.MarkerFaceColor = color_incongruent;

  set(e1, 'LineWidth', 0.8)
  set(e2, 'LineWidth', 0.8)

  
  xticks([x, xe])
  xticklabels(xlabels) 
  xlim(xlimits)
  ylim(ylimits)
  
  lgd = legend('Congruent','Incongruent');
  lgd.Location = lgd_location;
  lgd.Color = 'none';
  
  stitle = sprintf('ACTIONS (N=%d)', height(groupRT));
  title(stitle);
  xlabel('Presentation Time [ms]')
  ylabel('RT [ms]')

  % PLOT 4 : CONTEXT (Congruent vs Incongruent) ===========================
  subplot(2,2,4);
  % Define indices for for condition category
  i1 = [13, 18];         % CONTEXT Probe & Congruent
  i2 = [19, 24];        % CONTEXT Probe & Incongruent
  
  data1 = [groupRT(:,i1(1):i1(2))];
  data2 = [groupRT(:,i2(1):i2(2))];
  
  [y1, err1] = statisticsSampleConditional(data1);
  [y2, err2] = statisticsSampleConditional(data2);
  
  % Add Overall
  [b1, ber1] = simple_ci(y1);
  [b2, ber2] = simple_ci(y2);
  xe = 150;
  
  e1 = errorbar(x-1.5, y1, err1);
  hold on
  e2 = errorbar(x+1.5, y2, err2);
  e3 = errorbar(xe-1.5, b1, ber1);
  e4 = errorbar(xe+1.5, b2, ber2);
  hold off
  
  e1.Marker = mark_act;
  e2.Marker = mark_ctx;
  e3.Marker = mark_act;
  e4.Marker = mark_ctx;
  
  e1.Color = color_congruent;
  e2.Color = color_incongruent;
  e3.Color = color_congruent;
  e4.Color = color_incongruent;
  e1.MarkerFaceColor = color_congruent;
  e2.MarkerFaceColor = color_incongruent;
  e3.MarkerFaceColor = color_congruent;
  e4.MarkerFaceColor = color_incongruent;

  set(e1, 'LineWidth', 0.8)
  set(e2, 'LineWidth', 0.8)

  
  xticks([x, xe])
  xticklabels(xlabels) 
  xlim(xlimits)
  ylim(ylimits)
  
  lgd = legend('Congruent','Incongruent');
  lgd.Location = lgd_location;
  lgd.Color = 'none';
  
  stitle = sprintf('CONTEXT (N=%d)', height(groupRT));
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
   fh.PaperPosition = [0 0 5000 2500]/res;
   print('-dpng','-r300',['plots/group_RT_statistics'])
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