function plotSensitivityGroup_acrossCompatibility(save_plots)
% Computes sensitivity (d-prime) group statistics (mean & std) per condition for
% each probe type and congruency.
% 
% Written for BriefAC (AinC)
% Vrabie 2022
make_plots = 1;
%save_plots = 0;

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
  mark_ctx = "s";
  mark_act = "o";
  %color_act = "#ffd700"; %"#EDB120";
  %color_ctx = "#0028ff"; %"#7E2F8E";
  color_ctx= "black";
  color_act = "#999999";
  color_face = "white";

  lgd_location = 'northeast';

  xfactor = 1000/60;
  ylimits = [-0.2, 2.5];
  xlimits = [1.4 9.6]*xfactor;
  x = [2:7]*xfactor; % in ms
  xlabels = {'33.3', '50.0', '66.6', '83.3', '100.0', '133.3', 'Overall'};


  % PLOT 1 : COMPATIBLE (Actions vs Context) ===============================
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
  xe = 150;
  
  e1 = errorbar(x-1.5, y1, err1);
  hold on
  e2 = errorbar(x+1.5, y2, err2);
  e3 = errorbar(xe-1.5, b1, ber1);
  e4 = errorbar(xe+1.5, b2, ber2);
  yline(0, '--');
  hold off
  
  e1.Marker = mark_act;
  e2.Marker = mark_ctx;
  e3.Marker = mark_act;
  e4.Marker = mark_ctx;
  
  e1.Color = color_act;
  e2.Color = color_ctx;
  e3.Color = color_act;
  e4.Color = color_ctx;
  e1.MarkerFaceColor = color_face;
  e2.MarkerFaceColor = color_face;
  e3.MarkerFaceColor = color_face;
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
  
  %lgd = legend('Action','Scene');
  %lgd.Location = lgd_location;
  %lgd.Color = 'none';
  
  stitle = sprintf('Actions vs Context across compatibility (N=%d)', height(dataAC));
  %title(stitle);
  xlabel('Presentation Time [ms]')
  ylabel('Sensitivity (d'')')
  
  % Print summary results =================================================
  fprintf('\nOverall results: Actions vs Context\n')
  fprintf('\t1) Mean: %.2f, 95%%CI: [%.2f, %.2f].\n', b1, b1-ber1, b1+ber1)
  fprintf('\t2) Mean: %.2f, 95%%CI: [%.2f, %.2f].\n', b2, b2-ber2, b2+ber2)

  % SAVE PLOTS ============================================================
  if save_plots
    % define resolution figure to be saved in dpi
    res = 420;
    % recalculate figure size to be saved
    set(fh,'PaperPositionMode','manual')
    fh.PaperUnits = 'inches';
    fh.PaperPosition = [0 0 2500 1700]/res;
    print('-dpng','-r300','plots/group_dprime_statistics_acrossCompatibility')
    %exportgraphics(fh, 'plots/group_dprime_statistics_acrossCompatibility.eps')
  end
end % if make_plots
end % function