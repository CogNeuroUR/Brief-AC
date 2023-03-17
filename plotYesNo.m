function groupDprime = plotYesNo(save_plots)
% Computes sensitivity (d-prime) group statistics (mean & std) per condition for
% each probe type and congruency.
% 
% Written for BriefAC (AinC)
% Vrabie 2022
make_plots = 1;

%% Collect results from files : ExpInfo-s
% get list of files
path_results = 'results/final/';
l_files = dir(path_results);

groupDprime = [];
l_subjects = {};

% collect hit & f. alarm rates for each subject & condition
RCmat = [];
RImat = [];

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
        key_yes = ExpInfo.Cfg.Probe.keyYes;
        key_no = ExpInfo.Cfg.Probe.keyNo;
        l_subjects = [l_subjects, fName];

        statsAC = getResponseStats(trialsAC, key_yes, key_no);
        statsAI = getResponseStats(trialsAI, key_yes, key_no);
        statsCC = getResponseStats(trialsCC, key_yes, key_no);
        statsCI = getResponseStats(trialsCI, key_yes, key_no);
        
        % *) Collect (Hits + Misses) & (F.Alarms + CorrRejs)
        RC = [statsAC.RateYesNo;...
              statsCC.RateYesNo];
        RI = [statsAI.RateYesNo;...
              statsCI.RateYesNo];
        RCmat = [RCmat, RC];
        RImat = [RImat, RI];

      end
    otherwise
      continue
  end % switch

end

%% TABLE (auxiliary!)
%groupDprime = array2table(groupDprime); %array2table(zeros(0,24));
probes = ["A", "S"];
times = [2:6 8];
vars = {};

for iP=1:length(probes)
  for iT=1:length(times)
    vars = [vars; sprintf('%s_%d', probes(iP), times(iT))];
  end
end

%groupDprime.Properties.VariableNames = vars;

%% Plot Hmat & Fmat
fh = figure;

color_compatible = "#00BF95";
color_incompatible = "#BF002A";

x = [1:length(vars)]';

data1 = RCmat';
data2 = RImat';

y1 = mean(data1);
y2 = mean(data2);
err1 = std(data1) / sqrt(length(data1)); % standard error
err2 = std(data2) / sqrt(length(data2)); % standard error

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
      'Color', 'k', 'LineWidth', 0.65);
end
yline(1, '--', 'Same')
%yline(mean(y, 'all'), '-', 'Mean', 'Color', 'blue')
means = mean(y);
yline(means(1), '-', 'Mean', 'Color', color_compatible)
yline(means(2), '-', 'Mean', 'Color', color_incompatible)
hold off

b(1).FaceColor = color_compatible;
b(2).FaceColor = color_incompatible;

xticks(x)
xticklabels(vars)

xlabel('Conditions')
ylabel('Ratio Expected answers : YES/NO')

lgd = legend('Compatible','Incompatible');
%lgd = legend('YES : Hits + F.Alarms','NO: Misses + Corr. Rej.s');
lgd.Location = 'northeast';
lgd.Color = 'none';

stitle = sprintf('Expected answers: YES vs NO (N=%d)', length(l_subjects));
title(stitle);

%% SAVE PLOTS ============================================================
if save_plots
   % define resolution figure to be saved in dpi
 res = 420;
 % recalculate figure size to be saved
 set(fh,'PaperPositionMode','manual')
 fh.PaperUnits = 'inches';
 fh.PaperPosition = [0 0 5000 2500]/res;
 print('-dpng','-r300',['plots/group_yes-vs-no'])
end
  
end %function 