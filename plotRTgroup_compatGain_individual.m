function groupRT = plotRTgroup_compatGain_individual(save_plots)
%function [rt_act_con, rt_ctx_con, rt_act_inc, rt_ctx_inc] =...
%          computeRTstatistics(ExpInfo, key_yes, key_no, make_plots, save_plots)
% Computes RT group statistics (mean & std) per condition for each probe type and
% congruency.
%
% Written for BriefAC (AinC)
% Vrabie 2022
make_plots = 1;
save_plots = 1;

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
% Plots [COMPATIBLE]
%% ########################################################################
if make_plots
  fh = figure;

  % General parameters
  color_compatible = "#77AC30";
  color_incompatible = "#D95319";
  color_act = "#EDB120";
  color_ctx = "#7E2F8E";

  lgd_location = 'northeast';

  ylimits = [350 1350]; % without individual lines
  x = [1:2];
  xlabels = {'Action', 'Context'};

  % PLOT : Actions vs Context =============================================
  
  % Define indices for for condition category
  i1 = [1, 6];          % ACTION & COMPATIBLE
  i2 = [7, 12];         % ACTION & INCOMPATIBLE
  i3 = [13, 18];        % CONTEXT & COMPATIBLE
  i4 = [19, 24];        % CONTEXT & INCOMPATIBLE
  
  data1 = [groupRT(:,i1(1):i1(2))];
  data2 = [groupRT(:,i2(1):i2(2))];
  data3 = [groupRT(:,i3(1):i3(2))];
  data4 = [groupRT(:,i4(1):i4(2))];
  
  [y1, ~] = meanCIgroup(data1);
  [y2, ~] = meanCIgroup(data2);
  [y3, ~] = meanCIgroup(data3);
  [y4, ~] = meanCIgroup(data4);
  
  % Mean and 95%CI on differences across PT
  [b1, ber1] = simple_ci(y1);
  [b2, ber2] = simple_ci(y2);
  [b3, ber3] = simple_ci(y3);
  [b4, ber4] = simple_ci(y4);

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
  data_ind_act = [mean(data1, 2), mean(data2, 2)];
  data_ind_ctx = [mean(data3, 2), mean(data4, 2)];
  x_ind = [0.92, 1.08];
  l1 = plot(x_ind, data_ind_act, '-o', 'Color',color_act, 'Marker', 'o');
  l2 = plot(x_ind+1, data_ind_ctx, '-o', 'Color',color_ctx, 'Marker', 's');
  hold off

  b(1).FaceColor = color_compatible;
  b(2).FaceColor = color_incompatible;

  xticklabels(xlabels) 
  ylim(ylimits)
  
  lgd = legend('Compatible','Incompatible');
  lgd.Location = lgd_location;
  lgd.Color = 'none';

  stitle = sprintf('Compatibility gain (N=%d)', height(groupRT));
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
   fh.PaperPosition = [0 0 2500 1500]/res;
   print('-dpng','-r300',['plots/group_RT_statistics_compatGain_individual'])
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