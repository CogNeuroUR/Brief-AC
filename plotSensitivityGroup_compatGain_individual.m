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

[dataAC, dataAI, dataCC, dataCI] = extractData_meanDprime(path_results);

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
  color_incompatible = "#FF0066";
  color_iline = "#555555";

  lgd_location = 'northeast';

  ylimits = [-0.8, 3.15];
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
  %set(lgd, 'Interpreter','latex')

  stitle = sprintf('Compatibility gain (N=%d)', height(dataAC));
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
   fh.PaperPosition = [0 0 2300 1700]/res;
   print('-dpng','-r400',['plots/group_dprime_statistics_compatGain_individual'])
  end
end % if make_plots
end % function