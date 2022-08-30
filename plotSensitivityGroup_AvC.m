function groupDprime = plotSensitivityGroup_AvC(save_plots)
% Written for BriefAC (AinC)
% Vrabie 2022

make_plots = 1;
%save_plots = 0;

%% Collect results from files : ExpInfo-s
% get list of files
path_results = 'results/final/';

[groupDprime, ~] = extractData_meanDprime(path_results);

%% ########################################################################
% Plots [COMPATIBLE]
%% ########################################################################
if make_plots
  fh = figure;

  % General parameters
  color_compatible = "#77AC30";
  color_incompatible = "#D95319";

  lgd_location = 'northeast';

  xfactor = 1000/60;
  ylimits = [-2, 3];
  xlimits = [1.6 9.4]*xfactor;
  x = [1:6 8];
  xlabels = {'33.3', '50.0', '66.6', '83.3', '100.0', '133.3', 'Overall'};

  % Define indices for for condition category
  i1 = [1, 6];          % ACTION Probe & COMPATIBLE
  i2 = [13, 18];        % CONTEXT Probe & COMPATIBLE
  i3 = [7, 12];         % ACTION Probe & INCOMPATIBLE
  i4 = [19, 24];        % CONTEXT Probe & INCOMPATIBLE
  
  data1 = [groupDprime(:,i1(1):i1(2))];
  data2 = [groupDprime(:,i2(1):i2(2))];
  data3 = [groupDprime(:,i3(1):i3(2))];
  data4 = [groupDprime(:,i4(1):i4(2))];
  
  % compute differences in RT : Action - Context
  diff_compatible = data1 - data2;
  diff_incompatible = data3 - data4;

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

  b(1).FaceColor = color_compatible;
  b(2).FaceColor = color_incompatible;

  xticks(x)
  xticklabels(xlabels) 
  ylim(ylimits)
  
  lgd = legend('Compatible', 'Incompatible');
  lgd.Location = 'northeast';
  lgd.Color = 'none';

  stitle = sprintf('Action - Context (N=%d)', height(groupDprime));
  %title(stitle);
  xlabel('Presentation Time [ms]')
  ylabel('Sensitivity difference : A-C (d'')')

  % SAVE PLOTS ============================================================
  if save_plots
     % define resolution figure to be saved in dpi
   res = 420;
   % recalculate figure size to be saved
   set(fh,'PaperPositionMode','manual')
   fh.PaperUnits = 'inches';
   fh.PaperPosition = [0 0 2500 1500]/res;
   print('-dpng','-r300',['plots/groupDprime_AvC'])
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