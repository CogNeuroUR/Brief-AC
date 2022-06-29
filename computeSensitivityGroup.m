function groupDprime = computeSensitivityGroup(make_plots, save_plots)

%% Collect results from files : ExpInfo-s
% get list of files
path_results = 'results/final/';
l_files = dir(path_results);

groupDprime = [];
l_subjects = {};

% iterate over files
for i=1:length(l_files)
  path2file = [path_results, l_files(i).name];
  
  % check if of mat-extension
  [fPath, fName, fExt] = fileparts(l_files(i).name);
  
  switch fExt
    case '.mat'
      % ignore demo-results
      if ~contains(l_files(i).name, 'demo')
        fprintf('%s : %s\n', l_files(i).name, fExt);
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

%% Add subject IDs to table AND re-arrange columns
%groupDprime.Subject = l_subjects';
%groupDprime = groupDprime(:, [25, 1:24]);

%% ########################################################################
% PLOTS: TODO
%% ########################################################################
%%

figure
x = [1:12];
%indices = [2:7, 14:19]; % TODO :  use these instead
i1 = [1, 6];
i2 = [13, 18];
data1 = [groupDprime(:,i1(1):i1(2))];
data2 = [groupDprime(:,i2(1):i2(2))];

y1 = mean(data1);
y2 = mean(data2);

err1 = std(data1);
err2 = std(data2);

errorbar(x, [y1, y2], err);

xticks(x)
%xticklabels(round(x, 2)) 
xticklabels([vars(i1(1):i1(2)); vars(i2(1):i2(2))]);
ylim([-1, 3.2])
xlim([0.5, 12.5])

%legend('Congruent (AC & CC)')
title('Sensitivity index [CONGRUENT : Actions and Context]');
xlabel('Conditions')
ylabel('d''')

%%
% Plots [CONGRUENT]
if make_plots
  figure
  x = [1:12];
  %indices = [2:7, 14:19]; % TODO :  use these instead
  i1 = [1, 6];
  i2 = [13, 18];
  data = [groupDprime(:,i1(1):i1(2)), groupDprime(:,i2(1):i2(2))];
  y = mean(data);
  err = std(data);
  errorbar(x, y, err);
  
  xticks(x)
  %xticklabels(round(x, 2)) 
  xticklabels([vars(i1(1):i1(2)); vars(i2(1):i2(2))]);
  ylim([-1, 3.2])
  xlim([0.5, 12.5])
  
  %legend('Congruent (AC & CC)')
  title('Sensitivity index [CONGRUENT : Actions and Context]');
  xlabel('Conditions')
  ylabel('d''')

  if save_plots
    print('-dpng','-r300', ['plots/' ExpInfo.Cfg.name '_group_dprime_congruent'])
  end
  
%% [INCONGRUENT] Plot d-prime
  figure
  x = [1:12];
  %indices = [2:7, 14:19]; % TODO :  use these instead
  i1 = [1, 6];
  i2 = [13, 18];
  data = [groupDprime(:,i1(1):i1(2)), groupDprime(:,i2(1):i2(2))];
  y = mean(data);
  err = std(data);
  errorbar(x, y, err);
  
  xticks(x)
  %xticklabels(round(x, 2)) 
  xticklabels([vars(i1(1):i1(2)); vars(i2(1):i2(2))]);
  ylim([-1, 3.2])
  xlim([0.5, 12.5])
  
  %legend('Congruent (AC & CC)')
  title('Sensitivity index [CONGRUENT : Actions and Context]');
  xlabel('Conditions')
  ylabel('d''')

  if save_plots
    print('-dpng','-r300', ['plots/' ExpInfo.Cfg.name '_group_dprime_incongruent'])
  end
  
  %% Plot d-prime : ACTIONS
  figure
  assert(height(dprimeAI) == height(dprimeAC));
  x = [dprimeAI{:, 'PresTime'}]/0.06; % 0.06 = 60 Hz / 1000 ms
  bar(x, [dprimeAC{:, 'd-prime'}, dprimeAI{:, 'd-prime'}]);
  
  xticks([dprimeAC{:, 'PresTime'}]/0.06)
  xticklabels(round([dprimeAC{:, 'PresTime'}]/0.06, 2)) 
  ylim([0, max(dprimeAC{:, 'd-prime'}) + 1])
  
  legend('Congruent','Incongruent')
  title('Sensitivity index (S1) : ACTIONS');
  xlabel('Presentation time [ms]')
  ylabel('d''')

  if save_plots
    print('-dpng','-r300', ['plots/' ExpInfo.Cfg.name '_group_dprime_actions'])
  end
  
  %% Plot d-prime : ACTIONS
  figure
  assert(height(dprimeCC) == height(dprimeCI));
  x = [dprimeCC{:, 'PresTime'}]/0.06; % 0.06 = 60 Hz / 1000 ms
  bar(x, [dprimeCC{:, 'd-prime'}, dprimeCI{:, 'd-prime'}]);
  
  xticks([dprimeCC{:, 'PresTime'}]/0.06)
  xticklabels(round([dprimeCC{:, 'PresTime'}]/0.06, 2)) 
  ylim([0, max(dprimeCC{:, 'd-prime'}) + 1])
  
  legend('Congruent','Incongruent')
  title('Sensitivity index (S1) : CONTEXT');
  xlabel('Presentation time [ms]')
  ylabel('d''')

  if save_plots
    print('-dpng','-r300', ['plots/' ExpInfo.Cfg.name '_group_dprime_context'])
  end
end % plots
end % function