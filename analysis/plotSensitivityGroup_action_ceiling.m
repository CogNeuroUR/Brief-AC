function plotSensitivityGroup_action_ceiling(save_plots)
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
%path_results = 'results/final/'; % MAIN EXPERIMENT
path_results = 'results/post-pilot/'; % POST-PILOT EXPERIMENT

[dataAC, dataAI, ~, ~] = extractData_meanDprime(path_results);
[dmaxAC, dmaxAI, ~, ~] = extractData_Dprime_ceiling(path_results);
%[groupDprime, ~] = extractData_meanDprime(path_results);

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

  lgd_location = 'northeast';

  xfactor = 1000/60;
  %ylimits = [-.5, 3.3]; % pilot
  ylimits = [-.5, 4]; % w/ ceiling
  %ylimits = [-.5, 3]; % pilot
  xlimits = [1.3 8.8]*xfactor;
  x = [2:6 8]*xfactor; % in ms
  %xlabels = {'33.3', '50.0', '66.6', '83.3', '100.0', '133.3', 'Overall'};

  % PLOT : ACTIONS (Compatible vs Incompatible) =============================
  data1 = dataAC;
  data2 = dataAI;
  data1c = dmaxAC;
  data2c = dmaxAI;
  
  %[y1, err1] = meanCIgroup(data1); % 95% CI
  %[y2, err2] = meanCIgroup(data2); % 95% CI
  [y1, err1] = meanSEgroup(data1); % Standard error
  [y2, err2] = meanSEgroup(data2); % Standard error
  [c1, cerr1] = meanSEgroup(data1c); % Standard error
  [c2, cerr2] = meanSEgroup(data2c); % Standard error
  
  e1 = errorbar(x-1.5, y1, err1);
  hold on
  e2 = errorbar(x+1.5, y2, err2);
  yline(0, '--');
  rc1 = rectangle('Position', [x(1)-2 c1(1)-cerr1(1) 4 2*cerr1(1)]);
  hold off

  e1.Marker = mark_act;
  e2.Marker = mark_ctx;
  
  e1.Color = color_compatible;
  e2.Color = color_incompatible;
  e1.MarkerFaceColor = color_compatible;
  e2.MarkerFaceColor = color_incompatible;

  rc1.FaceColor = color_compatible;
  rc1.EdgeColor = color_compatible;

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
  
  %stitle = sprintf('ACTIONS (N=%d)', height(data1));
  %title(stitle);
  xlabel('Presentation Time [ms]')
  ylabel('Sensitivity (d'')')

  % SAVE PLOTS ============================================================
  if save_plots
    % define resolution figure to be saved in dpi
    res = 420;
    % recalculate figure size to be saved
    set(fh,'PaperPositionMode','manual')
    fh.PaperUnits = 'inches';
    fh.PaperPosition = [0 0 2500 1500]/res;
    % Save
    prefix = split(path_results, filesep);
    prefix = prefix{end-1};
    path_outfile = [pwd, filesep, 'plots', filesep, 'groupDprime-ceiling_actions_', prefix];
    print('-dpng','-r300', path_outfile)
    exportgraphics(fh, [path_outfile '.eps'])
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
          key_yes = ExpInfo.Cfg.Probe.keyYes;
          key_no = ExpInfo.Cfg.Probe.keyNo;
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