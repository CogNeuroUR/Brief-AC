function groupDprime = computeSensitivityGroup(ExpInfo, make_plots, save_plots)

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
groupDprime = array2table(groupDprime); %array2table(zeros(0,24));
probes = ["AC", "AI", "CC", "CI"];
times = [2:6 8];
vars = {};

for iP=1:length(probes)
  for iT=1:length(times)
    vars = [vars; sprintf('%s_%d', probes(iP), times(iT))];
  end
end

groupDprime.Properties.VariableNames = vars;

%% Add subject IDs to table AND re-arrange columns
groupDprime.Subject = l_subjects';
groupDprime = groupDprime(:, [25, 1:24]);

%% ########################################################################
% PLOTS: TODO
%% ########################################################################
% Plots [CONGRUENT]
if make_plots
  figure
  x = times * 1000/60; % ms
  bar(x, [groupDprime(:,2:7), groupDprime(:,14:19)]);
  
  xticks(x)
  xticklabels(round(x, 2)) 
  ylim([0, 3])
  
  legend('Action','Context')
  title('Sensitivity index (S1) [CONGRUENT]');
  xlabel('Presentation time [ms]')
  ylabel('d''')

  if save_plots
    print('-dpng','-r300', ['plots/' ExpInfo.Cfg.name '_dprime_congruent'])
  end
  
  %% [INCONGRUENT] Plot d-prime
  figure
  assert(height(dprimeAI) == height(dprimeCI));
  x = [dprimeAI{:, 'PresTime'}]/0.06; % 0.06 = 60 Hz / 1000 ms
  bar(x, [dprimeAI{:, 'd-prime'}, dprimeCI{:, 'd-prime'}]);
  
  xticks([dprimeAI{:, 'PresTime'}]/0.06)
  xticklabels(round([dprimeAI{:, 'PresTime'}]/0.06, 2)) 
  ylim([0, max(dprimeAI{:, 'd-prime'}) + 1])
  
  legend('Action','Context')
  title('Sensitivity index (S1) [INCONGRUENT]');
  xlabel('Presentation time [ms]')
  ylabel('d''')

  if save_plots
    print('-dpng','-r300', ['plots/' ExpInfo.Cfg.name '_dprime_incongruent'])
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
    print('-dpng','-r300', ['plots/' ExpInfo.Cfg.name '_dprime_actions'])
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
    print('-dpng','-r300', ['plots/' ExpInfo.Cfg.name '_dprime_context'])
  end
end % plots
end % function