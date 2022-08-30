function plotSensitivity(ExpInfo, save_plots)
%function statisticsSensitivity(ExpInfo, key_yes, key_no, save_plots)
%
% Vrabie 2022

%% Custom parameters:
exp_name = split(ExpInfo.Cfg.name, '_');
if isequal(exp_name{2}, 'right')
  key_yes = 39;
  key_no = 37;
elseif isequal(exp_name{2}, 'left')
  key_yes = 37;
  key_no = 39;
end

make_plots = 1;

%% Extract trials for each probe by decoding trials' ASF code
[t_trialsActionCompatible, t_trialsContextCompatible,...
 t_trialsActionIncompatible, t_trialsContextIncompatible] = getTrialResponses(ExpInfo);

%% Investigate Sensitivity index (d')
% Extract statistics: hits, false alarms and their rates by PROBE TYPE & CONGRUENCY
statsActionCompatible = getResponseStats(t_trialsActionCompatible, key_yes, key_no);
statsContextCompatible = getResponseStats(t_trialsContextCompatible, key_yes, key_no);
statsActionIncompatible = getResponseStats(t_trialsActionIncompatible, key_yes, key_no);
statsContextIncompatible = getResponseStats(t_trialsContextIncompatible, key_yes, key_no);

%% Compute d-prime  
stats_act_con = dprime(statsActionCompatible);
stats_ctx_con = dprime(statsContextCompatible);
stats_act_inc = dprime(statsActionIncompatible);
stats_ctx_inc = dprime(statsContextIncompatible);


%% ########################################################################
% Plots [COMPATIBLE]
if make_plots
  % Plot parameters
  fh = figure;
  screen_freq = (1/60);
  factor = screen_freq*1000;
  ylimits = [-1.5, 3.1];
  xlimits = [1.6 8.4]*factor;
  x = [stats_act_con{:, 'PresTime'}]/0.06; % in ms


  % Plot [COMPATIBLE]
  subplot(2,2,1);
  assert(height(stats_act_con) == height(stats_ctx_con));
  bar(x, [stats_act_con{:, 'dprime'}, stats_ctx_con{:, 'dprime'}]);
  
  xticks([stats_act_con{:, 'PresTime'}]/0.06)
  xticklabels(round([stats_act_con{:, 'PresTime'}]/0.06, 2)) 
  xlim(xlimits)
  ylim(ylimits)
  
  legend('Action','Context')
  title('Sensitivity index [COMPATIBLE]');
  xlabel('Presentation time [ms]')
  ylabel('d''')

  
  % Plot [INCOMPATIBLE]
  subplot(2,2,2);
  assert(height(stats_act_inc) == height(stats_ctx_inc));
  bar(x, [stats_act_inc{:, 'dprime'}, stats_ctx_inc{:, 'dprime'}]);
  
  xticks([stats_act_inc{:, 'PresTime'}]/0.06)
  xticklabels(round([stats_act_inc{:, 'PresTime'}]/0.06, 2)) 
  xlim(xlimits)
  ylim(ylimits)
  
  legend('Action','Context')
  title('Sensitivity index [INCOMPATIBLE]');
  xlabel('Presentation time [ms]')
  ylabel('d''')
  
  % Plot [ACTIONS]
  subplot(2,2,3);
  assert(height(stats_act_inc) == height(stats_act_con));
  bar(x, [stats_act_con{:, 'dprime'}, stats_act_inc{:, 'dprime'}]);
  
  xticks([stats_act_con{:, 'PresTime'}]/0.06)
  xticklabels(round([stats_act_con{:, 'PresTime'}]/0.06, 2)) 
  xlim(xlimits)
  ylim(ylimits)
  
  legend('Compatible','Incompatible')
  title('Sensitivity index : ACTIONS');
  xlabel('Presentation time [ms]')
  ylabel('d''')
  
  % Plot  : CONTEXT
  subplot(2,2,4);
  assert(height(stats_ctx_con) == height(stats_ctx_inc));
  bar(x, [stats_ctx_con{:, 'dprime'}, stats_ctx_inc{:, 'dprime'}]);
  
  xticks([stats_ctx_con{:, 'PresTime'}]/0.06)
  xticklabels(round([stats_ctx_con{:, 'PresTime'}]/0.06, 2)) 
  xlim(xlimits)
  ylim(ylimits)
  
  legend('Compatible','Incompatible')
  title('Sensitivity index : CONTEXT');
  xlabel('Presentation time [ms]')
  ylabel('d''')

  if save_plots
     % define resolution figure to be saved in dpi
   res = 420;
   % recalculate figure size to be saved
   set(fh,'PaperPositionMode','manual')
   fh.PaperUnits = 'inches';
   fh.PaperPosition = [0 0 5000 2500]/res;
   print('-dpng','-r300',['plots/' ExpInfo.Cfg.name '_sensitivity_statistics'])
  end
end % plots
end % function