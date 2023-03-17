function groupDprime = plotHitsFAlarms(save_plots)
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
Hmat = [];
Fmat = [];

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
        
        % 3) Compute d-prime  
        dprimeAC = dprime(statsAC);
        dprimeAI = dprime(statsAI);
        dprimeCC = dprime(statsCC);
        dprimeCI = dprime(statsCI);

        % 4) Dump into matrix
        groupDprime = [groupDprime;...
                       dprimeAC.dprime(:)', dprimeAI.dprime(:)',...
                       dprimeCC.dprime(:)', dprimeCI.dprime(:)'];

        % *) Collect (Hits + Misses) & (F.Alarms + CorrRejs)
        Hs = [statsAC.Hits + statsAC.Misses;...
              statsAI.Hits + statsAI.Misses;...
              statsCC.Hits + statsCC.Misses;...
              statsCI.Hits + statsCI.Misses];
        Hmat = [Hmat, Hs];

        Fs = [statsAC.FalseAlarms + statsAC.CorrectRejections;...
              statsAI.FalseAlarms + statsAI.CorrectRejections;...
              statsCC.FalseAlarms + statsCC.CorrectRejections;...
              statsCI.FalseAlarms + statsCI.CorrectRejections];
        Fmat = [Fmat, Fs];

%         Hs = [statsAC.Hits + statsAC.FalseAlarms;...
%               statsAI.Hits + statsAI.FalseAlarms;...
%               statsCC.Hits + statsCC.FalseAlarms;...
%               statsCI.Hits + statsCI.FalseAlarms];
%         Hmat = [Hmat, Hs];
% 
%         Fs = [statsAC.Misses + statsAC.CorrectRejections;...
%               statsAI.Misses + statsAI.CorrectRejections;...
%               statsCC.Misses + statsCC.CorrectRejections;...
%               statsCI.Misses + statsCI.CorrectRejections];
%         Fmat = [Fmat, Fs];

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
data1 = Hmat'/24;
data2 = Fmat'/24;

x = [1:length(vars)];
y1 = mean(data1);
y2 = mean(data2);

err1 = std(data1) / sqrt(length(data1)); % standard error
err2 = std(data2) / sqrt(length(data2)); % standard error

e1 = errorbar(x-0.05, y1, err1);
hold on
e2 = errorbar(x+0.05, y2, err2);
hold off

e1.Marker = "x";
e2.Marker = "o";

xticks(x)
xticklabels(vars)

xlabel('Conditions')
ylabel('Percentage trials')

lgd = legend('Hits + Misses','F.Alarms + Corr. Rej.s');
%lgd = legend('YES : Hits + F.Alarms','NO: Misses + Corr. Rej.s');
lgd.Location = 'northeast';
lgd.Color = 'none';

stitle = sprintf('(N=%d)', height(groupDprime));
%stitle = sprintf('Correct: Yes vs No  (N=%d)', height(groupDprime));
title(stitle);
%some_confusing_comparison

%% SAVE PLOTS ============================================================
if save_plots
   % define resolution figure to be saved in dpi
 res = 420;
 % recalculate figure size to be saved
 set(fh,'PaperPositionMode','manual')
 fh.PaperUnits = 'inches';
 fh.PaperPosition = [0 0 5000 2500]/res;
 print('-dpng','-r300',['plots/group_hits-falarms'])
end
  
end %function 