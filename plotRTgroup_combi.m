function groupRT = plotRTgroup_combi(save_plots)
%function [rt_act_con, rt_ctx_con, rt_act_inc, rt_ctx_inc] =...
%          computeRTstatistics(ExpInfo, key_yes, key_no, make_plots, save_plots)
% Computes RT group statistics (mean & std) per condition for each probe type and
% congruency.
%
% Written for BriefAC (AinC)
% Vrabie 2022
make_plots = 1;
save_plots = 0;

%% Collect results from files : ExpInfo-s
% get list of files
path_results = 'results/final/';
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
% Plots
%% ########################################################################
if make_plots
  fh = figure;
  %margins = [0.12, 0.12]; %[vertical,horizontal]
  
  % General parameters
  xfactor = 1000/60;
  %ylimits = [650 1100]; % without individual lines
  ylimits = [700 950];
  xlimits = [1.6 8.4]*xfactor;
  x = [2:6 8]*xfactor; % in ms

  % PLOT 1 (Actions vs Context : Congruent) ==================
  %subplot_tight(2,2,1, margins);
  subplot(2,2,1);
  % Define indices for for condition category
  i1 = [1, 6];         % ACTION Probe & CONGRUENT
  i2 = [13, 18];       % CONTEXT Probe & CONGRUENT
  
  data1 = [groupRT(:,i1(1):i1(2))];
  data2 = [groupRT(:,i2(1):i2(2))];
  
  y1 = mean(data1);
  y2 = mean(data2);
  
  err1 = std(data1) / sqrt(length(data1));
  err2 = std(data2) / sqrt(length(data2));
  
  e1 = errorbar(x-0.5, y1, err1);
  hold on
  e2 = errorbar(x+.5, y2, err2);
  hold on
  %m1 = plot(x-1,data1,'rx');
  %m2 = plot(x+1,data2,'bo');
  e1.Marker = "x";
  e2.Marker = "o";

  set(e1, 'LineWidth', 0.8)
  set(e2, 'LineWidth', 0.8)

  set(e1, 'Color', '#00A801')
  set(e2, 'Color', '#00A801')
  %set(e1, 'Color', 'k')
  %set(e2, 'Color', 'k')


  xticks(x)
  xticklabels(round(x, 1)) 
  xlim(xlimits)
  ylim(ylimits)
  
  lgd = legend('Actions','Context');
  lgd.Location = 'northeast';
  lgd.Color = 'none';

  stitle = sprintf('RT : CONGRUENT (N=%d)', height(groupRT));
  title(stitle);
  %xlabel('Presentation Time [ms]')
  ylabel('Mean Reaction Time [ms]')

  % PLOT 2 : Actions vs Context : Incongruent =============================
  %subplot_tight(2,2,2, margins);
  subplot(2,2,2);
  % Define indices for for condition category
  i1 = [7, 12];         % ACTION Probe & INCONGRUENT
  i2 = [19, 24];        % CONTEXT Probe & INCONGRUENT
  
  data1 = [groupRT(:,i1(1):i1(2))];
  data2 = [groupRT(:,i2(1):i2(2))];
  
  y1 = mean(data1);
  y2 = mean(data2);
  
  err1 = std(data1) / sqrt(length(data1));
  err2 = std(data2) / sqrt(length(data2));
  
  e1 = errorbar(x-.5, y1, err1);
  hold on
  e2 = errorbar(x+.5, y2, err2);
  
  e1.Marker = "x";
  e2.Marker = "o";

  set(e1, 'LineWidth', 0.8)
  set(e2, 'LineWidth', 0.8)

  set(e1, 'Color', '#FA0001')
  set(e2, 'Color', '#FA0001')

  xticks(x)
  xticklabels(round(x, 1)) 
  xlim(xlimits)
  ylim(ylimits)

  lgd = legend('Actions','Context');
  lgd.Location = 'northeast';
  lgd.Color = 'none';

  stitle = sprintf('RT : INCONGRUENT (N=%d)', height(groupRT));
  title(stitle);

  %xlabel('Presentation Time [ms]')
  %ylabel('RT [ms]')

  % PLOT 3 : difference from the mean =====================================
  %subplot_tight(2,2,[3,4], margins);
  subplot(2,2,[3,4]);
  ylimits = [-60 150];
  xlimits = [1.6 8.4]*xfactor;
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
  diff_congruent = data1 - data2;
  diff_incongruent = data3 - data4;

  y1 = mean(diff_congruent);
  y2 = mean(diff_incongruent);
  
  err1 = std(diff_congruent) / sqrt(length(diff_congruent));
  err2 = std(diff_incongruent) / sqrt(length(diff_incongruent));
  
  e1 = errorbar(x-.25, y1, err1);
  hold on
  e2 = errorbar(x+.25, y2, err2);
  hold on
  zero = yline(0, ':'); % no difference

  e1.Marker = "s";
  e2.Marker = "s";

  set(e1, 'LineWidth', 0.8)
  set(e2, 'LineWidth', 0.8)
  set(zero', 'LineWidth', 1.5)

  set(e1, 'Color', '#00A801')
  set(e2, 'Color', '#FA0001')
  set(zero, 'Color', '#999999')

  xticks(x)
  xticklabels(round(x, 1)) 
  xlim(xlimits)
  ylim(ylimits)
  
  lgd = legend('Congruent', 'Incongruent');
  lgd.Location = 'northeast';
  lgd.Color = 'none';

  stitle = sprintf('Action - Context (N=%d)', height(groupRT));
  title(stitle);
  xlabel('Presentation Time [ms]')
  ylabel('Mean Reaction Time : Difference [ms]')

  % SAVE PLOTS ============================================================
  if save_plots
     % define resolution figure to be saved in dpi
   res = 420;
   % recalculate figure size to be saved
   set(fh,'PaperPositionMode','manual')
   fh.PaperUnits = 'inches';
   fh.PaperPosition = [0 0 5000 2500]/res;
   print('-dpng','-r300',['plots/group_RT_statistics_combi_3'])
  end
end % if make_plots

%% ########################################################################
% Confidence intervals
%% ########################################################################
%% Extract data & average across PTs
% for context & action
% for congruent & incongruent
i1 = [1, 6];         % ACTION Probe & CONGRUENT
i2 = [13, 18];       % CONTEXT Probe & CONGRUENT
data_act_c = [groupRT(:,i1(1):i1(2))];
data_ctx_c = [groupRT(:,i2(1):i2(2))];

i1 = [7, 12];         % ACTION Probe & INCONGRUENT
i2 = [19, 24];        % CONTEXT Probe & INCONGRUENT
data_act_i = [groupRT(:,i1(1):i1(2))];
data_ctx_i = [groupRT(:,i2(1):i2(2))];

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
fprintf('\nProbe Type | M(RT) |   CI_95(RT)\n')
fprintf('-----------------------------------\n')
probes_ = ["AC", "CC", "AI", "CI"];
for i=1:length(stats)
  fprintf('%s \t   | %.1f | [%.1f, %.1f]\n', probes_(i), stats(i, 1),...
    stats(i, 2), stats(i, 3))
end

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