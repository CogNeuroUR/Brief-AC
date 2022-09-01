function groupDprime = plotSensitivityGroup_compatGain_individual(save_plots)
% Computes sensitivity (d-prime) group statistics (mean & std) per condition for
% each probe type and congruency.
% 
% Written for BriefAC (AinC)
% Vrabie 2022
%set(0,'defaulttextinterpreter','latex')
%set(0,'DefaultTextFontname', 'CMU Serif')
%set(0,'DefaultAxesFontName', 'CMU Serif')
make_plots = 1;
%save_plots = 1;

%% Collect results from files : ExpInfo-s
% get list of files
path_results = 'results/final/';

[groupDprime, ~] = extract_dprime(path_results);

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
  color_compatible = "#00BF95";
  color_incompatible = "#BF002A";
  color_act = "#EDB120";
  color_ctx = "#7E2F8E";
  color_iline = "#555555";

  lgd_location = 'northeast';

  ylimits = [-0.8, 3.15];
  x = [1:2];
  xlabels = {'Action', 'Context'};

  % PLOT : Actions vs Context =============================================
  
  % Define indices for for condition category
  i1 = [1, 6];          % ACTION & COMPATIBLE
  i2 = [7, 12];         % ACTION & INCOMPATIBLE
  i3 = [13, 18];        % CONTEXT & COMPATIBLE
  i4 = [19, 24];        % CONTEXT & INCOMPATIBLE
  

  data1 = [groupDprime(:,i1(1):i1(2))];
  data2 = [groupDprime(:,i2(1):i2(2))];
  data3 = [groupDprime(:,i3(1):i3(2))];
  data4 = [groupDprime(:,i4(1):i4(2))];
  
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
  %set(lgd, 'Interpreter','latex')

  stitle = sprintf('Compatibility gain (N=%d)', height(groupDprime));
  %title(stitle);
  xlabel('Probe Type')
  ylabel('Sensitivity (d'')')
  
  % Print summary results =================================================
  fprintf('\nOverall results: Actions, Context (Compatible vs Incompatible)\n')
  fprintf('\t1) Mean: %.2f, 95%%CI: [%.2f, %.2f].\n', b1, b1-ber1, b1+ber1)
  fprintf('\t2) Mean: %.2f, 95%%CI: [%.2f, %.2f].\n', b3, b3-ber3, b3+ber3)
  fprintf('\t1) Mean: %.2f, 95%%CI: [%.2f, %.2f].\n', b2, b2-ber2, b2+ber2)
  fprintf('\t2) Mean: %.2f, 95%%CI: [%.2f, %.2f].\n', b4, b4-ber4, b4+ber4)

  % SAVE PLOTS ============================================================
  if save_plots
     % define resolution figure to be saved in dpi
   res = 420;
   % recalculate figure size to be saved
   set(fh,'PaperPositionMode','manual')
   fh.PaperUnits = 'inches';
   fh.PaperPosition = [0 0 2500 1500]/res;
   print('-dpng','-r300',['plots/group_dprime_statistics_compatGain_individual'])
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