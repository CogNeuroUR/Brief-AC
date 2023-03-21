function groupRT = plotRTgroup_compatGain_individual(save_plots)
%function [rt_act_con, rt_ctx_con, rt_act_inc, rt_ctx_inc] =...
%          computeRTstatistics(ExpInfo, key_yes, key_no, make_plots, save_plots)
% Computes RT group statistics (mean & std) per condition for each probe type and
% congruency.
%
% Written for BriefAC (AinC)
% Vrabie 2022
make_plots = 1;
%save_plots = 1;

%% Collect results from files : ExpInfo-s
% get list of files
path_results = 'results/final/';

[dataAC, dataAI, dataCC, dataCI] = extractData_meanRT(path_results);

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
% Plots [COMPATIBLE]
%% ########################################################################
if make_plots
  fh = figure('visible','off');

  % General parameters
  color_compatible = "#00BF95";
  color_incompatible = "#BF002A";
  color_iline = "#555555";

  lgd_location = 'northeast';

  ylimits = [450 1300]; % without individual lines
  x = [1:2];
  xlabels = {'Action', 'Scene'};

  % PLOT : Actions vs Context =============================================  
  % Extract mean data
  [y1, ~] = meanSEgroup(dataAC);
  [y2, ~] = meanSEgroup(dataAI);
  [y3, ~] = meanSEgroup(dataCC);
  [y4, ~] = meanSEgroup(dataCI);
  
  % Mean and 95%CI on differences across PT
  %[b1, ber1] = simple_ci(y1);
  %[b2, ber2] = simple_ci(y2);
  %[b3, ber3] = simple_ci(y3);
  %[b4, ber4] = simple_ci(y4);

  % Mean and SE on differences across PT
  [b1, ber1] = meanSEgroup(y1);
  [b2, ber2] = meanSEgroup(y2);
  [b3, ber3] = meanSEgroup(y3);
  [b4, ber4] = meanSEgroup(y4);

  % Concatenate (1st row: compatible; 2nd row: incompatible)
  y = [b1, b2; b3, b4];
  yerr = [ber1, ber2; ber3, ber4];

  b = bar(x, y);
  hold on
  % From https://stackoverflow.com/a/59257318
  for k = 1:size(y,2)
    % get x positions per group
    xpos = b(k).XData + b(k).XOffset;
    % draw errorbar
    errorbar(xpos, y(:,k), yerr(:,k), 'LineStyle', 'none', ... 
        'Color', 'k', 'LineWidth', 1);
  end
  
  % data from individual subjects
  data_ind_act = [mean(dataAC, 2), mean(dataAI, 2)];
  data_ind_ctx = [mean(dataCC, 2), mean(dataCI, 2)];
  x_ind = [0.92, 1.08];
  l1 = indiplot(x_ind, data_ind_act, color_iline);
  l2 = indiplot(x_ind+1, data_ind_ctx, color_iline);
  hold off

  b(1).FaceColor = color_compatible;
  b(2).FaceColor = color_incompatible;

  xticklabels(xlabels) 
  ylim(ylimits)
  
  lgd = legend('Compatible','Incompatible');
  lgd.Location = lgd_location;
  lgd.Color = 'none';

  stitle = sprintf('Compatibility gain (N=%d)', height(dataAC));
  %title(stitle);
  xlabel('Probe Type')
  ylabel('Reaction Time [ms]')

  % Print summary results =================================================
  fprintf('\nOverall results: Actions, Context (Compatible vs Incompatible)\n')
  fprintf('\t1) Mean: %.1f, 95%%CI: [%.1f, %.1f].\n', b1, b1-ber1, b1+ber1)
  fprintf('\t2) Mean: %.1f, 95%%CI: [%.1f, %.1f].\n', b3, b3-ber3, b3+ber3)
  fprintf('\t1) Mean: %.1f, 95%%CI: [%.1f, %.1f].\n', b2, b2-ber2, b2+ber2)
  fprintf('\t2) Mean: %.1f, 95%%CI: [%.1f, %.1f].\n', b4, b4-ber4, b4+ber4)

  % SAVE PLOTS ============================================================
  if save_plots
     % define resolution figure to be saved in dpi
   res = 420;
   % recalculate figure size to be saved
   set(fh,'PaperPositionMode','manual')
   fh.PaperUnits = 'inches';
   fh.PaperPosition = [0 0 2300 1700]/res;
   print('-dpng','-r400',['plots/group_RT_statistics_compatGain_individual'])
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