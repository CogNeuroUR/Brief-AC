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

%% Compute d-prime  
stats_act_con = dprime(statsActionCongruent);
stats_ctx_con = dprime(statsContextCongruent);
stats_act_inc = dprime(statsActionIncongruent);
stats_ctx_inc = dprime(statsContextIncongruent);


%% ########################################################################
% Plots [CONGRUENT]
if make_plots
  figure
  assert(height(stats_act_con) == height(stats_ctx_con));
  x = [stats_act_con{:, 'PresTime'}]/0.06; % 0.06 = 60 Hz / 1000 ms
  bar(x, [stats_act_con{:, 'd-prime'}, stats_ctx_con{:, 'd-prime'}]);
  
  xticks([stats_act_con{:, 'PresTime'}]/0.06)
  xticklabels(round([stats_act_con{:, 'PresTime'}]/0.06, 2)) 
  ylim([0, max(stats_act_con{:, 'd-prime'}) + 1])
  
  legend('Action','Context')
  title('Sensitivity index [CONGRUENT]');
  xlabel('Presentation time [ms]')
  ylabel('d''')

  if save_plots
    print('-dpng','-r300', ['plots/' ExpInfo.Cfg.name '_dprime_congruent'])
  end
  
  %% [INCONGRUENT] Plot d-prime
  figure
  assert(height(stats_act_inc) == height(stats_ctx_inc));
  x = [stats_act_inc{:, 'PresTime'}]/0.06; % 0.06 = 60 Hz / 1000 ms
  bar(x, [stats_act_inc{:, 'd-prime'}, stats_ctx_inc{:, 'd-prime'}]);
  
  xticks([stats_act_inc{:, 'PresTime'}]/0.06)
  xticklabels(round([stats_act_inc{:, 'PresTime'}]/0.06, 2)) 
  ylim([0, max(stats_act_inc{:, 'd-prime'}) + 1])
  
  legend('Action','Context')
  title('Sensitivity index [INCONGRUENT]');
  xlabel('Presentation time [ms]')
  ylabel('d''')

  if save_plots
    print('-dpng','-r300', ['plots/' ExpInfo.Cfg.name '_dprime_incongruent'])
  end
  
  %% Plot d-prime : ACTIONS
  figure
  assert(height(stats_act_inc) == height(stats_act_con));
  x = [stats_act_inc{:, 'PresTime'}]/0.06; % 0.06 = 60 Hz / 1000 ms
  bar(x, [stats_act_con{:, 'd-prime'}, stats_act_inc{:, 'd-prime'}]);
  
  xticks([stats_act_con{:, 'PresTime'}]/0.06)
  xticklabels(round([stats_act_con{:, 'PresTime'}]/0.06, 2)) 
  ylim([0, max(stats_act_con{:, 'd-prime'}) + 1])
  
  legend('Congruent','Incongruent')
  title('Sensitivity index : ACTIONS');
  xlabel('Presentation time [ms]')
  ylabel('d''')

  if save_plots
    print('-dpng','-r300', ['plots/' ExpInfo.Cfg.name '_dprime_actions'])
  end
  
  %% Plot d-prime : ACTIONS
  figure
  assert(height(stats_ctx_con) == height(stats_ctx_inc));
  x = [stats_ctx_con{:, 'PresTime'}]/0.06; % 0.06 = 60 Hz / 1000 ms
  bar(x, [stats_ctx_con{:, 'd-prime'}, stats_ctx_inc{:, 'd-prime'}]);
  
  xticks([stats_ctx_con{:, 'PresTime'}]/0.06)
  xticklabels(round([stats_ctx_con{:, 'PresTime'}]/0.06, 2)) 
  ylim([0, max(stats_ctx_con{:, 'd-prime'}) + 1])
  
  legend('Congruent','Incongruent')
  title('Sensitivity index : CONTEXT');
  xlabel('Presentation time [ms]')
  ylabel('d''')

  if save_plots
    print('-dpng','-r300', ['plots/' ExpInfo.Cfg.name '_dprime_context'])
  end
end % plots
end % function


%% ########################################################################
% Functions
%% ########################################################################
%% ------------------------------------------------------------------------
function t_stats = dprime(t_stats)
  % 1) Extract rates
  % 2) Replace zeros and ones (to prevent infinities)
  %   Zeros -> 1/(2N); N : max nr. of observation in a group
  %   Ones  -> 1 - 1/(2N)
  % 3) Compute d-prime

  for i=1:height(t_stats)
    % Convert proportions of 0 and 1 to 1/(2N) and 1-1/(2N)
    % See Macmillan & Creelman (2005), Page 8.
    if t_stats.H(i) == 1
      t_stats.H(i) = 1 - 1/(2*(t_stats.Hits(i) + t_stats.Misses(i)));
    end
    if t_stats.FalseAlarms(i) == 0
      t_stats.FalseAlarms(i) = 1/((t_stats.FalseAlarms(i) + t_stats.CorrectRejections(i)));
    end
    
    % Compute d-prime
    t_stats{i, 'd-prime'} = norminv(t_stats.H(i)) - norminv(t_stats.FalseAlarms(i));
  end
end