function groupRT = statisticsRTgroup(save_plots)
%function [rt_act_con, rt_ctx_con, rt_act_inc, rt_ctx_inc] =...
%          computeRTstatistics(ExpInfo, key_yes, key_no, make_plots, save_plots)
% Computes RT statistics (mean & std) per condition for each probe type and
% congruency.
%
% Written for BriefAC (AinC)
% Vrabie 2022
make_plots = 1;

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
% Plots [CONGRUENT]
%% ########################################################################
if make_plots
  fh = figure;
  
  % General parameters
  xfactor = 1000/60;
  ylimits = [650 1100];
  xlimits = [1.6 8.4]*xfactor;
  x = [2:6 8]*xfactor; % in ms

  % PLOT 1 : CONGRUENT (Actions vs Context) ===============================
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
  
  e1 = errorbar(x, y1, err1);
  hold on
  e2 = errorbar(x, y2, err2);
  
  e1.Marker = "x";
  e2.Marker = "o";

  xticks(x)
  xticklabels(round(x, 2)) 
  xlim(xlimits)
  ylim(ylimits)
  
  legend('Actions','Context')
  stitle = sprintf('RT : CONGRUENT (N=%d)', height(groupRT));
  title(stitle);
  xlabel('Conditions')
  ylabel('RT')

  % PLOT 2 : INCONGRUENT (Actions vs Context) =============================
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
  
  e1 = errorbar(x, y1, err1);
  hold on
  e2 = errorbar(x, y2, err2);
  
  e1.Marker = "x";
  e2.Marker = "o";
  
  xticks(x)
  xticklabels(round(x, 2)) 
  xlim(xlimits)
  ylim(ylimits)

  legend('Actions','Context')
  stitle = sprintf('RT : INCONGRUENT (N=%d)', height(groupRT));
  title(stitle);
  xlabel('Conditions')
  ylabel('RT')

  % PLOT 3 : ACTIONS (Congruent vs Incongruent) ===========================
  subplot(2,2,3);
  % Define indices for for condition category
  i1 = [1, 6];         % ACTION Probe & Congruent
  i2 = [7, 12];        % ACTION Probe & Incongruent
  
  data1 = [groupRT(:,i1(1):i1(2))];
  data2 = [groupRT(:,i2(1):i2(2))];
  
  y1 = mean(data1);
  y2 = mean(data2);
  
  err1 = std(data1) / sqrt(length(data1));
  err2 = std(data2) / sqrt(length(data2));
  
  e1 = errorbar(x, y1, err1);
  hold on
  e2 = errorbar(x, y2, err2);
  
  e1.Marker = "x";
  e2.Marker = "o";
  
  xticks(x)
  xticklabels(round(x, 2)) 
  xlim(xlimits)
  ylim(ylimits)

  legend('Congruent','Incongruent')
  stitle = sprintf('RT : ACTIONS (N=%d)', height(groupRT));
  title(stitle);
  xlabel('Conditions')
  ylabel('RT')

  % PLOT 4 : CONTEXT (Congruent vs Incongruent) ===========================
  subplot(2,2,4);
  % Define indices for for condition category
  i1 = [13, 18];         % CONTEXT Probe & Congruent
  i2 = [19, 24];        % CONTEXT Probe & Incongruent
  
  data1 = [groupRT(:,i1(1):i1(2))];
  data2 = [groupRT(:,i2(1):i2(2))];
  
  y1 = mean(data1);
  y2 = mean(data2);
  
  err1 = std(data1) / sqrt(length(data1));
  err2 = std(data2) / sqrt(length(data2));
  
  e1 = errorbar(x, y1, err1);
  hold on
  e2 = errorbar(x, y2, err2);
  
  e1.Marker = "x";
  e2.Marker = "o";
  
  xticks(x)
  xticklabels(round(x, 2)) 
  xlim(xlimits)
  ylim(ylimits)

  legend('Congruent','Incongruent')
  stitle = sprintf('RT : CONTEXT (N=%d)', height(groupRT));
  title(stitle);
  xlabel('Conditions')
  ylabel('RT')

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