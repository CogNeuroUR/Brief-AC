function groupDprime = statisticsSensitivityGroup_combi_ci(save_plots)
% Computes sensitivity (d-prime) group statistics (mean & std) per condition for
% each probe type and congruency.
% 
% Written for BriefAC (AinC)
% Vrabie 2022
make_plots = 1;
save_plots = 1;

%% Collect results from files : ExpInfo-s
% get list of files
path_results = 'results/final/';

[groupDprime, l_subjects] = extract_dprime(path_results);

%% TABLE (auxiliary!)
%groupDprime = array2table(groupDprime); %array2table(zeros(0,24));
probes = ["AC", "AI", "CC", "CI"];
times = [2:6 8];
vars = {};

for iP=1:length(probes)
  for iT=1:length(times)
    vars = [vars; sprintf('%s_%d', probes(iP), times(iT))];
  end
end

%% ########################################################################
% PLOTS
%% ########################################################################
if make_plots
  fh = figure;
  
  % General parameters
  xfactor = 1000/60;
  ylimits = [-1, 3];
  xlimits = [1.6 8.4]*xfactor;
  x = [2:6 8]*xfactor; % in ms

  % PLOT 1 : CONGRUENT (Actions vs Context) ===============================
  subplot(2,2,1);
  % Define indices for for condition category
  i1 = [1, 6];         % ACTION Probe & CONGRUENT
  i2 = [13, 18];       % CONTEXT Probe & CONGRUENT
  
  data1 = [groupDprime(:,i1(1):i1(2))];
  data2 = [groupDprime(:,i2(1):i2(2))];
  
  [y1, err1] = statisticsSampleConditional(data1);
  [y2, err2] = statisticsSampleConditional(data2);

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

  xticks(x)
  xticklabels(round(x, 2)) 
  xlim(xlimits)
  ylim(ylimits)
  
  lgd = legend('Actions','Context');
  lgd.Location = 'northwest';
  lgd.Color = 'none';
  
  stitle = sprintf('CONGRUENT (N=%d)', height(groupDprime));
  title(stitle);
  ylabel('d-prime')

  % PLOT 2 : INCONGRUENT (Actions vs Context) =============================
  subplot(2,2,2);
  % Define indices for for condition category
  i1 = [7, 12];         % ACTION Probe & INCONGRUENT
  i2 = [19, 24];        % CONTEXT Probe & INCONGRUENT

  data1 = [groupDprime(:,i1(1):i1(2))];
  data2 = [groupDprime(:,i2(1):i2(2))];
  
  [y1, err1] = statisticsSampleConditional(data1);
  [y2, err2] = statisticsSampleConditional(data2);

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
  
  xticks(x)
  xticklabels(round(x, 2)) 
  xlim(xlimits)
  ylim(ylimits)

  lgd = legend('Actions','Context');
  lgd.Location = 'northwest';
  lgd.Color = 'none';

  stitle = sprintf('INCONGRUENT (N=%d)', height(groupDprime));
  title(stitle);

  % PLOT 3 : ACTIONS (Congruent vs Incongruent) ===========================
  subplot(2,2,3);
  % Define indices for for condition category
  i1 = [1, 6];         % ACTION Probe & Congruent
  i2 = [7, 12];        % ACTION Probe & Incongruent

  data1 = [groupDprime(:,i1(1):i1(2))];
  data2 = [groupDprime(:,i2(1):i2(2))];
  
  [y1, err1] = statisticsSampleConditional(data1);
  [y2, err2] = statisticsSampleConditional(data2);

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
  
  xticks(x)
  xticklabels(round(x, 2)) 
  xlim(xlimits)
  ylim(ylimits)

  lgd = legend('Congruent','Incongruent');
  lgd.Location = 'northwest';
  lgd.Color = 'none';
  
  stitle = sprintf('ACTIONS (N=%d)', height(groupDprime));
  title(stitle);
  xlabel('Presentation Time [ms]')
  ylabel('d-prime')

  % PLOT 4 : CONTEXT (Congruent vs Incongruent) ===========================
  subplot(2,2,4);
  % Define indices for for condition category
  i1 = [13, 18];         % CONTEXT Probe & Congruent
  i2 = [19, 24];        % CONTEXT Probe & Incongruent

  data1 = [groupDprime(:,i1(1):i1(2))];
  data2 = [groupDprime(:,i2(1):i2(2))];
  
  [y1, err1] = statisticsSampleConditional(data1);
  [y2, err2] = statisticsSampleConditional(data2);

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

  xticks(x)
  xticklabels(round(x, 2)) 
  xlim(xlimits)
  ylim(ylimits)

  lgd = legend('Congruent','Incongruent');
  lgd.Location = 'northwest';
  lgd.Color = 'none';
  
  stitle = sprintf('CONTEXT (N=%d)', height(groupDprime));
  title(stitle);
  xlabel('Presentation Time [ms]')
  %ylabel('d''')
  
  % SAVE PLOTS ============================================================
  if save_plots
     % define resolution figure to be saved in dpi
   res = 420;
   % recalculate figure size to be saved
   set(fh,'PaperPositionMode','manual')
   fh.PaperUnits = 'inches';
   fh.PaperPosition = [0 0 5000 2500]/res;
   print('-dpng','-r300',['plots/group_dprime_statistics_combi_ci'])
  end
end % if make_plots
end % function

%% ------------------------------------------------------------------------
function [groupDprime, l_subjects] = extract_dprime(path_results)
  l_files = dir(path_results);
  
  groupDprime = [];
  l_subjects = {};
  
  % iterate over files
  fprintf('Sweeping through files ...\n');
  for i=1:length(l_files)
    path2file = [path_results, l_files(i).name];
    
    % check if of mat-extension
    [fPath, fName, fExt] = fileparts(l_files(i).name);
    
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
  
          statsAC = getResponseStats(trialsAC, key_yes, key_no);
          statsAI = getResponseStats(trialsAI, key_yes, key_no);
          statsCC = getResponseStats(trialsCC, key_yes, key_no);
          statsCI = getResponseStats(trialsCI, key_yes, key_no);
          
          % 3) Compute d-prime  
          dprimeAC = dprime(statsAC);
          dprimeAI = dprime(statsAI);
          dprimeCC = dprime(statsCC);
          dprimeCI = dprime(statsCI);
  
          % 4) Dump into matrix
          groupDprime = [groupDprime;...
                         dprimeAC.dprime(:)', dprimeAI.dprime(:)',...
                         dprimeCC.dprime(:)', dprimeCI.dprime(:)'];
  
        end
      otherwise
        continue
    end % switch
  
  end
end