function plotRT_single_acrossCompatibility(save_plots)
%function [rt_act_con, rt_ctx_con, rt_act_inc, rt_ctx_inc] =...
%          computeRTstatistics(ExpInfo, key_yes, key_no, make_plots, save_plots)
% Computes RT group statistics (mean & std) per condition for each probe type and
% congruency.
%
% Written for BriefAC (AinC)
% Vrabie 2022
% Vrabie 2023
make_plots = 1;
save_plots = 1;
path_results = 'results/tests/';
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

[dataAC, dataAI, dataCC, dataCI] = extractData_meanRT(path_results);

%% ########################################################################
% Plots [COMPATIBLE]
%% ########################################################################
if make_plots
  fh = figure;

  % General parameters
  mark_ctx = "s";
  mark_act = "o";
  color_ctx= "black";
  color_act = "#999999";
  color_face = "white";

  lgd_location = 'northeast';

  xfactor = 1000/60;
  ylimits = [800 1300];
  x = info.PresTimeLevels*xfactor; % in ms
  xlimits = [x(1) - 20, x(end) + 40];
  xlabels = {'33.3', '50.0', '66.6', '83.3', '116.6', '150.0', 'Overall'};
  % PLOT : Actions vs Context =============================================

  % Average within the subject across compatibility
  data1 = [dataAC; dataAI];
  data2 = [dataCC; dataCI];
  
  %[y1, err1] = meanCIgroup(data1); % 95% CI
  %[y2, err2] = meanCIgroup(data2); % 95% CI
  [y1, err1] = meanSEgroup(data1); % Standard error
  [y2, err2] = meanSEgroup(data2); % Standard error

  % Add Overall
  %[b1, ber1] = simple_ci(y1); % 95% CI
  %[b2, ber2] = simple_ci(y2); % 95% CI
  [b1, ber1] = meanSEgroup(y1); % Standard error
  [b2, ber2] = meanSEgroup(y2); % Standard error
  xe = 180;

  e1 = errorbar(x, y1, err1);
  hold on
  e2 = errorbar(x, y2, err2);
  e3 = errorbar(xe, b1, ber1);
  e4 = errorbar(xe, b2, ber2);
  hold off
  
  e1.Marker = mark_act;
  e2.Marker = mark_ctx;
  e3.Marker = mark_act;
  e4.Marker = mark_ctx;
  
  e1.Color = color_act;
  e2.Color = color_ctx;
  e3.Color = color_act;
  e4.Color = color_ctx;
  e1.MarkerFaceColor = color_act;
  e2.MarkerFaceColor = color_face;
  e3.MarkerFaceColor = color_act;
  e4.MarkerFaceColor = color_face;

  set(e1, 'LineWidth', 0.9)
  set(e2, 'LineWidth', 0.9)
  set(e3, 'LineWidth', 0.9)
  set(e4, 'LineWidth', 0.9)

  set(gca, 'Box', 'off') % removes upper and right axis

  xticks([x, xe])
  xticklabels(xlabels) 
  xlim(xlimits)
  ylim(ylimits)
  
  lgd = legend('Action','Scene');
  lgd.Location = lgd_location;
  %lgd.Title.String = 'Probe Type';
  %lgd.Box = 'off';
  lgd.Color = 'none';

  stitle = sprintf('Reaction Time across compatibility (N=%d)', height(dataAC));
  title(stitle);
  xlabel('Presentation Time [ms]')
  ylabel('Reaction Time [ms]')

  % Print summary results =================================================
  fprintf('\nOverall results: Actions vs Context\n')
  fprintf('\t1) Mean: %.1f, 95%%CI: [%.1f, %.1f].\n', b1, b1-ber1, b1+ber1)
  fprintf('\t2) Mean: %.1f, 95%%CI: [%.1f, %.1f].\n', b2, b2-ber2, b2+ber2)

  % SAVE PLOTS ============================================================
  if save_plots
    % define resolution figure to be saved in dpi
    res = 420;
    % recalculate figure size to be saved
    set(fh,'PaperPositionMode','manual')
    fh.PaperUnits = 'inches';
    fh.PaperPosition = [0 0 2500 1700]/res;
    print('-dpng','-r300','plots/RT_Actions-Scenes_acrossCompatibility_single')
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
          if isequal(ExpInfo.Cfg.probe.Yes, {'left'})
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