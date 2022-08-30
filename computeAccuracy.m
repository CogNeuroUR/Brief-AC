function [stats_act_con, stats_ctx_con,...
          stats_act_inc, stats_ctx_inc] =...
          computeAccuracy(ExpInfo, key_yes, key_no, make_plots, save_plots)


%% Extract trials for each probe by decoding trials' ASF code
[t_trialsActionCompatible, t_trialsContextCompatible,...
 t_trialsActionIncompatible, t_trialsContextIncompatible] = getTrialResponses(ExpInfo);

%% Investigate Sensitivity index (d')
% Extract statistics: hits, false alarms and their rates by PROBE TYPE & CONGRUENCY
statsActionCompatible = getResponseStats(t_trialsActionCompatible, key_yes, key_no);
statsContextCompatible = getResponseStats(t_trialsContextCompatible, key_yes, key_no);
statsActionIncompatible = getResponseStats(t_trialsActionIncompatible, key_yes, key_no);
statsContextIncompatible = getResponseStats(t_trialsContextIncompatible, key_yes, key_no);


%% Compute accuracy  
stats_act_con = accuracy(statsActionCompatible);
stats_ctx_con = accuracy(statsContextCompatible);
stats_act_inc = accuracy(statsActionIncompatible);
stats_ctx_inc = accuracy(statsContextIncompatible);


%% ########################################################################
% Plots [COMPATIBLE]
if make_plots
  figure
  assert(height(stats_act_con) == height(stats_ctx_con));
  x = [stats_act_con{:, 'PresTime'}]/0.06; % 0.06 = 60 Hz / 1000 ms
  bar(x, [stats_act_con{:, 'accuracy'}, stats_ctx_con{:, 'accuracy'}]);
  
  xticks([stats_act_con{:, 'PresTime'}]/0.06)
  xticklabels(round([stats_act_con{:, 'PresTime'}]/0.06, 2)) 
  %ylim([0, max(stats_act_con{:, 'accuracy'}) + 1])
  
  legend('Action','Context')
  title('Accuracy [COMPATIBLE]');
  xlabel('Presentation time [ms]')
  ylabel('Accuracy (%)')

  if save_plots
    print('-dpng','-r300', ['plots/' ExpInfo.Cfg.name '_accuracy_compatible'])
  end
  
  %% [INCOMPATIBLE] Plot accuracy
  figure
  assert(height(stats_act_inc) == height(stats_ctx_inc));
  x = [stats_act_inc{:, 'PresTime'}]/0.06; % 0.06 = 60 Hz / 1000 ms
  bar(x, [stats_act_inc{:, 'accuracy'}, stats_ctx_inc{:, 'accuracy'}]);
  
  xticks([stats_act_inc{:, 'PresTime'}]/0.06)
  xticklabels(round([stats_act_inc{:, 'PresTime'}]/0.06, 2)) 
  %ylim([0, max(stats_act_inc{:, 'accuracy'}) + 1])
  
  legend('Action','Context')
  title('Accuracy [INCOMPATIBLE]');
  xlabel('Presentation time [ms]')
  ylabel('Accuracy (%)')

  if save_plots
    print('-dpng','-r300', ['plots/' ExpInfo.Cfg.name '_accuracy_incompatible'])
  end
  
  %% Plot accuracy : ACTIONS
  figure
  assert(height(stats_act_inc) == height(stats_act_con));
  x = [stats_act_inc{:, 'PresTime'}]/0.06; % 0.06 = 60 Hz / 1000 ms
  bar(x, [stats_act_con{:, 'accuracy'}, stats_act_inc{:, 'accuracy'}]);
  
  xticks([stats_act_con{:, 'PresTime'}]/0.06)
  xticklabels(round([stats_act_con{:, 'PresTime'}]/0.06, 2)) 
  %ylim([0, max(stats_act_con{:, 'accuracy'}) + 1])
  
  legend('Compatible','Incompatible')
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
  
  legend('Compatible','Incompatible')
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
function t_stats = accuracy(t_stats)
  % 1) Extract nr of HITS and CORRECT REJECTIONS
  % 2) Compute accuracy as the ration of (HITS+CORR_REJECT) / N_samples
  fprintf('Computing accuracy ...\n')

  for i=1:height(t_stats)
    % Compute accuracy as ratio
    ratio = (t_stats.Hits(i) + t_stats.CorrectRejections(i)) / t_stats.N_samples(i);
    t_stats{i, 'accuracy'} = ratio * 100;
  end
end