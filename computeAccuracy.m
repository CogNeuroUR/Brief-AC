function [stats_act_con, stats_ctx_con,...
          stats_act_inc, stats_ctx_inc] =...
          computeSensitivity(ExpInfo, key_yes, key_no, make_plots, save_plots)


%% Extract trials for each probe by decoding trials' ASF code
[t_trialsActionCongruent, t_trialsContextCongruent,...
 t_trialsActionIncongruent, t_trialsContextIncongruent] = getTrialResponses(ExpInfo);

%% Investigate Sensitivity index (d')
% Extract statistics: hits, false alarms and their rates by PROBE TYPE & CONGRUENCY
statsActionCongruent = getResponseStats(t_trialsActionCongruent, key_yes, key_no);
statsContextCongruent = getResponseStats(t_trialsContextCongruent, key_yes, key_no);
statsActionIncongruent = getResponseStats(t_trialsActionIncongruent, key_yes, key_no);
statsContextIncongruent = getResponseStats(t_trialsContextIncongruent, key_yes, key_no);


%% Compute accuracy  
stats_act_con = accuracy(statsActionCongruent);
stats_ctx_con = accuracy(statsContextCongruent);
stats_act_inc = accuracy(statsActionIncongruent);
stats_ctx_inc = accuracy(statsContextIncongruent);


%% ########################################################################
% Plots [CONGRUENT]
if make_plots
  figure
  assert(height(stats_act_con) == height(stats_ctx_con));
  x = [stats_act_con{:, 'PresTime'}]/0.06; % 0.06 = 60 Hz / 1000 ms
  bar(x, [stats_act_con{:, 'accuracy'}, stats_ctx_con{:, 'accuracy'}]);
  
  xticks([stats_act_con{:, 'PresTime'}]/0.06)
  xticklabels(round([stats_act_con{:, 'PresTime'}]/0.06, 2)) 
  %ylim([0, max(stats_act_con{:, 'accuracy'}) + 1])
  
  legend('Action','Context')
  title('Accuracy [CONGRUENT]');
  xlabel('Presentation time [ms]')
  ylabel('Accuracy (%)')

  if save_plots
    print('-dpng','-r300', ['plots/' ExpInfo.Cfg.name '_accuracy_congruent'])
  end
  
  %% [INCONGRUENT] Plot accuracy
  figure
  assert(height(stats_act_inc) == height(stats_ctx_inc));
  x = [stats_act_inc{:, 'PresTime'}]/0.06; % 0.06 = 60 Hz / 1000 ms
  bar(x, [stats_act_inc{:, 'accuracy'}, stats_ctx_inc{:, 'accuracy'}]);
  
  xticks([stats_act_inc{:, 'PresTime'}]/0.06)
  xticklabels(round([stats_act_inc{:, 'PresTime'}]/0.06, 2)) 
  %ylim([0, max(stats_act_inc{:, 'accuracy'}) + 1])
  
  legend('Action','Context')
  title('Accuracy [INCONGRUENT]');
  xlabel('Presentation time [ms]')
  ylabel('Accuracy (%)')

  if save_plots
    print('-dpng','-r300', ['plots/' ExpInfo.Cfg.name '_accuracy_incongruent'])
  end
  
  %% Plot accuracy : ACTIONS
  figure
  assert(height(stats_act_inc) == height(stats_act_con));
  x = [stats_act_inc{:, 'PresTime'}]/0.06; % 0.06 = 60 Hz / 1000 ms
  bar(x, [stats_act_con{:, 'accuracy'}, stats_act_inc{:, 'accuracy'}]);
  
  xticks([stats_act_con{:, 'PresTime'}]/0.06)
  xticklabels(round([stats_act_con{:, 'PresTime'}]/0.06, 2)) 
  %ylim([0, max(stats_act_con{:, 'accuracy'}) + 1])
  
  legend('Congruent','Incongruent')
  title('Accuracy : ACTIONS');
  xlabel('Presentation time [ms]')
  ylabel('Accuracy (%)')

  if save_plots
    print('-dpng','-r300', ['plots/' ExpInfo.Cfg.name '_accuracy_actions'])
  end
  
  %% Plot accuracy : ACTIONS
  figure
  assert(height(stats_ctx_con) == height(stats_ctx_inc));
  x = [stats_ctx_con{:, 'PresTime'}]/0.06; % 0.06 = 60 Hz / 1000 ms
  bar(x, [stats_ctx_con{:, 'accuracy'}, stats_ctx_inc{:, 'accuracy'}]);
  
  xticks([stats_ctx_con{:, 'PresTime'}]/0.06)
  xticklabels(round([stats_ctx_con{:, 'PresTime'}]/0.06, 2)) 
  %ylim([0, max(stats_ctx_con{:, 'accuracy'}) + 1])
  
  legend('Congruent','Incongruent')
  title('Accuracy : CONTEXT');
  xlabel('Presentation time [ms]')
  ylabel('Accuracy (%)')

  if save_plots
    print('-dpng','-r300', ['plots/' ExpInfo.Cfg.name '_accuracy_context'])
  end
end % plots
end % function


%% ########################################################################
% Functions
%% ########################################################################
function t_stats = accuracy(stats)
  % 1) Extract nr of HITS and CORRECT REJECTIONS
  % 2) Compute accuracy as the ration of (HITS+CORR_REJECT) / N_samples
  fprintf('Computing accuracy ...\n')
  t_stats = cell2table(stats(:, [1, 3, 7, 2]),...
                       'VariableNames',{'PresTime' 'Hits'...
                                        'CorrRejections' 'N'});

  for i=1:height(t_stats)
    % Compute accuracy as ratio
    ratio = (t_stats{i, 'Hits'} + t_stats{i, 'CorrRejections'})...
                              / t_stats{i, 'N'};
    t_stats{i, 'accuracy'} = ratio * 100;
  end
end