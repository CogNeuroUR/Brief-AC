function sanity_correctResponseExpInfo()
% Computes sensitivity (d-prime) group statistics (mean & std) per condition for
% each probe type and congruency.
% 
% Written for BriefAC (AinC)
% Vrabie 2022

%% Collect results from files : ExpInfo-s
% get list of files
path_results = 'results/final/';
l_files = dir(path_results);

groupDprime = [];
l_subjects = {};

% collect hit & f. alarm rates for each subject & condition
YESmat = [];
NOmat = [];

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
      
        % *) Collect (Hits + Misses) & (F.Alarms + CorrRejs)
        YESs = [statsAC.Hits + statsAC.Misses;...
              statsAI.Hits + statsAI.Misses;...
              statsCC.Hits + statsCC.Misses;...
              statsCI.Hits + statsCI.Misses];
        YESmat = [YESmat, YESs];

        NOs = [statsAC.FalseAlarms + statsAC.CorrectRejections;...
              statsAI.FalseAlarms + statsAI.CorrectRejections;...
              statsCC.FalseAlarms + statsCC.CorrectRejections;...
              statsCI.FalseAlarms + statsCI.CorrectRejections];
        NOmat = [NOmat, NOs];

      end
    otherwise
      continue
  end % switch

end

%% Collect results from files based specifically on responses : ExpInfo-s
% get list of files
path_results = 'results/final/';
l_files = dir(path_results);

l_subjects = {};

% collect hit & f. alarm rates for each subject & condition
YESmat = [];
NOmat = [];

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

        % Iterate over trials
        for iT=1:length(ExpInfo.TrialInfo)
          % Extract code
        end
        trialdefs(counter).code = aline(1); %#ok<AGROW>
        trialdefs(counter).corrResp = aline(end);

        %

        % *) Collect (Hits + Misses) & (F.Alarms + CorrRejs)
        YESs = [statsAC.Hits + statsAC.Misses;...
              statsAI.Hits + statsAI.Misses;...
              statsCC.Hits + statsCC.Misses;...
              statsCI.Hits + statsCI.Misses];
        YESmat = [YESmat, YESs];

        NOs = [statsAC.FalseAlarms + statsAC.CorrectRejections;...
              statsAI.FalseAlarms + statsAI.CorrectRejections;...
              statsCC.FalseAlarms + statsCC.CorrectRejections;...
              statsCI.FalseAlarms + statsCI.CorrectRejections];
        NOmat = [NOmat, NOs];

      end
    otherwise
      continue
  end % switch

end


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

%groupDprime.Properties.VariableNames = vars;

%% Plot Hmat & Fmat
fh = figure;

data1 = YESmat'/24;
data2 = NOmat'/24;

x = [1:length(vars)];
y1 = mean(data1);
y2 = mean(data2);

err1 = std(data1) / sqrt(length(data1)); % standard error
err2 = std(data2) / sqrt(length(data2)); % standard error


y1 = y1 ./ y2;
err1 = std(data1./data2) / sqrt(length(data1));

e1 = errorbar(x-0.05, y1, err1);
hold on
%e2 = errorbar(x+0.05, y2, err2);
yline(1, '--')
hold off

e1.Marker = "x";
e2.Marker = "o";

xticks(x)
xticklabels(vars)
ylim([0,2])

xlabel('Conditions')
ylabel('Percentage trials')

lgd = legend('YES/NO');
%lgd = legend('YES : Hits + F.Alarms','NO: Misses + Corr. Rej.s');
lgd.Location = 'northeast';
lgd.Color = 'none';

stitle = sprintf('Ratio: YES vs NO correct responses (ExpInfo files; N=%d)', height(data1));
%stitle = sprintf('Correct: Yes vs No  (N=%d)', height(groupDprime));
title(stitle);
%some_confusing_comparison

%% SAVE PLOTS ============================================================
save_plots = 1;
if save_plots
   % define resolution figure to be saved in dpi
 res = 420;
 % recalculate figure size to be saved
 set(fh,'PaperPositionMode','manual')
 fh.PaperUnits = 'inches';
 fh.PaperPosition = [0 0 5000 2500]/res;
 print('-dpng','-r300',['plots/sanity_correctResponsesExpInfos_N21'])
end
  
end %function 