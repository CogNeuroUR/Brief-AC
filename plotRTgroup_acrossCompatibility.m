function groupRT = plotRTgroup_acrossCompatibility(save_plots)
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
  ylimits = [700 1050]; % without individual lines
  %ylimits = [490 1250];
  xlimits = [1.6 9.4]*xfactor;
  %x = [2:6 8]*xfactor; % in ms
  x = [2:7]*xfactor; % in ms
  %x = [1:6];
  xlabels = {'33.3', '50.0', '66.6', '83.3', '100.0', '133.3', 'Overall'};

  % PLOT : Actions vs Context =============================================
  
  % Define indices for for condition category
  i11 = [1, 6];          % ACTION & CONGRUENT
  i12 = [7, 12];         % ACTION & INCONGRUENT
  i21 = [13, 18];        % CONTEXT & CONGRUENT
  i22 = [19, 24];        % CONTEXT & INCONGRUENT
  
  data11 = [groupRT(:,i11(1):i11(2))];
  data12 = [groupRT(:,i12(1):i12(2))];
  data21 = [groupRT(:,i21(1):i21(2))];
  data22 = [groupRT(:,i22(1):i22(2))];

  % Average within the subject across compatibility
  data1 = [data11; data12];
  data2 = [data21; data22];
  
  [y1, err1] = meanCIgroup(data1);
  [y2, err2] = meanCIgroup(data2);
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
  
  e1.Color = color_act;
  e2.Color = color_ctx;
  e3.Color = color_act;
  e4.Color = color_ctx;
  e1.MarkerFaceColor = color_act;
  e2.MarkerFaceColor = color_ctx;
  e3.MarkerFaceColor = color_act;
  e4.MarkerFaceColor = color_ctx;

  set(e1, 'LineWidth', 0.8)
  set(e2, 'LineWidth', 0.8)

  
  xticks([x, xe])
  xticklabels(xlabels) 
  xlim(xlimits)
  ylim(ylimits)
  
  lgd = legend('Actions','Context');
  lgd.Location = lgd_location;
  lgd.Color = 'none';

  stitle = sprintf('Actions vs Context across compatibility (N=%d)', height(groupRT));
  title(stitle);
  xlabel('Presentation Time [ms]')
  ylabel('RT [ms]')

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
   fh.PaperPosition = [0 0 2500 1500]/res;
   print('-dpng','-r300',['plots/group_RT_statistics_acrossCompatibility'])
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