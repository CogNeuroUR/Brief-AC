function plotAccuracy_pilot(save_plots)
%function [dataAC, dataCC, dataAI, dataCI] =...
%          computeRTstatistics(ExpInfo, key_yes, key_no, make_plots, save_plots)
% Computes RT group statistics (mean & std) per condition for each probe type and
% congruency.
%
% Written for BriefAC (AinC)
% Vrabie 2022
make_plots = 1;
%save_plots = 1;

%% Load results
path_results = 'results/post-pilot/';
[dataAC, dataAI, dataCC, dataCI] = extractData_meanAcc(path_results);

%% ########################################################################
% Plots [COMPATIBLE]
%% ########################################################################
if make_plots
  fh = figure;

  % General parameters
  mark_act = "o";
  mark_ctx = "s";
  color_compatible = "#00ff99";
  color_incompatible = "#BF002A";

  lgd_location = 'northeast';

  xfactor = 1000/60;
  ylimits = [-1.2, 3.7];
  xlimits = [1.3 8.8]*xfactor;
  x = [2:6 8]*xfactor; % in ms
  %xlabels = {'33.3', '50.0', '66.6', '83.3', '100.0', '133.3', 'Overall'};

  % PLOT : ACTIONS (Compatible vs Incompatible) =============================
  subplot(1,2,1);
  % Define indices for for condition category
  data1 = dataAC;
  data2 = dataAI;

  %[y1, err1] = meanCIgroup(data1); % 95% CI
  %[y2, err2] = meanCIgroup(data2); % 95% CI
  [y1, err1] = meanSEgroup(data1); % Standard error
  [y2, err2] = meanSEgroup(data2); % Standard error
  
  e1 = errorbar(x-1.5, y1, err1);
  hold on
  e2 = errorbar(x+1.5, y2, err2);
  yline(0, '--');
  % Individual data
  l1 = plot(x, data1', 'Color', color_compatible);
  l2 = plot(x, data2', 'Color', color_incompatible);
  hold off

  e1.Marker = mark_act;
  e2.Marker = mark_act;
  
  e1.Color = color_compatible;
  e2.Color = color_incompatible;
  e1.MarkerFaceColor = color_compatible;
  e2.MarkerFaceColor = color_incompatible;

  % Transparency for individual lines
  for i=1:length(l1)
    l1(i).Color(4) = 0.4;
    l2(i).Color(4) = 0.4;
  end

  set(e1, 'LineWidth', 0.8)
  set(e2, 'LineWidth', 0.8)
  set(l1, 'LineStyle', '--')
  set(l2, 'LineStyle', '--')

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
  ylabel('Accuracy (%)')


  % PLOT : SCENE (Compatible vs Incompatible) =============================
  subplot(1,2,2);

  data1 = dataCC;
  data2 = dataCI;

  %[y1, err1] = meanCIgroup(data1); % 95% CI
  %[y2, err2] = meanCIgroup(data2); % 95% CI
  [y1, err1] = meanSEgroup(data1); % Standard error
  [y2, err2] = meanSEgroup(data2); % Standard error
  
  e1 = errorbar(x-1.5, y1, err1);
  hold on
  e2 = errorbar(x+1.5, y2, err2);
  yline(0, '--');
  % Individual data
  l1 = plot(x, data1', 'Color', color_compatible);
  l2 = plot(x, data2', 'Color', color_incompatible);
  hold off

  e1.Marker = mark_ctx;
  e2.Marker = mark_ctx;

  e1.Color = color_compatible;
  e2.Color = color_incompatible;
  e1.MarkerFaceColor = color_compatible;
  e2.MarkerFaceColor = color_incompatible;
  
  % Transparency for individual lines
  for i=1:length(l1)
    l1(i).Color(4) = 0.4;
    l2(i).Color(4) = 0.4;
  end

  set(e1, 'LineWidth', 0.8)
  set(e2, 'LineWidth', 0.8)
  set(l1, 'LineStyle', '--')
  set(l2, 'LineStyle', '--')

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
  %ylabel('Sensitivity (d'')')

  % SAVE PLOTS ============================================================
  if save_plots
    % define resolution figure to be saved in dpi
    res = 420;
    % recalculate figure size to be saved
    set(fh,'PaperPositionMode','manual')
    fh.PaperUnits = 'inches';
    fh.PaperPosition = [0 0 4500 1500]/res;
    print('-dpng','-r300','plots/ppilotAcc_group')
    %exportgraphics(fh, 'plots/ppilotAcc_context.eps')
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