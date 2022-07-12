function statisticsAccuracy(ExpInfo, save_plots)
% function [stats_act_con, stats_ctx_con,...
%           stats_act_inc, stats_ctx_inc] =...
%           computeAccuracy(ExpInfo, key_yes, key_no, make_plots, save_plots)
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
  fh = figure;

  % General parameters
  xfactor = 1000/60;
  ylimits = [20 109];
  xlimits = [1.6 8.4]*xfactor;
  x = [2:6 8]*xfactor; % in ms

  % PLOT 1 : CONGRUENT (Actions vs Context) ===============================
  subplot(2,2,1);
  assert(height(stats_act_con) == height(stats_ctx_con));
  x = [stats_act_con{:, 'PresTime'}]/0.06; % 0.06 = 60 Hz / 1000 ms
  bar(x, [stats_act_con{:, 'accuracy'}, stats_ctx_con{:, 'accuracy'}]);
  
  xticks([stats_act_con{:, 'PresTime'}]/0.06)
  xticklabels(round([stats_act_con{:, 'PresTime'}]/0.06, 2)) 
  
  xlim(xlimits)
  ylim(ylimits)

  legend('Action','Context')
  title('Accuracy [CONGRUENT]');
  xlabel('Presentation time [ms]')
  ylabel('Accuracy (%)')
  
  % PLOT 2 : INCONGRUENT (Actions vs Context) =============================
  subplot(2,2,2);
  assert(height(stats_act_inc) == height(stats_ctx_inc));
  x = [stats_act_inc{:, 'PresTime'}]/0.06; % 0.06 = 60 Hz / 1000 ms
  bar(x, [stats_act_inc{:, 'accuracy'}, stats_ctx_inc{:, 'accuracy'}]);
  
  xticks([stats_act_inc{:, 'PresTime'}]/0.06)
  xticklabels(round([stats_act_inc{:, 'PresTime'}]/0.06, 2)) 

  xlim(xlimits)
  ylim(ylimits)

  legend('Action','Context')
  title('Accuracy [INCONGRUENT]');
  xlabel('Presentation time [ms]')
  ylabel('Accuracy (%)')

  % PLOT 3 : ACTIONS (Congruent vs Incongruent) ===========================
  subplot(2,2,3);
  assert(height(stats_act_inc) == height(stats_act_con));
  x = [stats_act_inc{:, 'PresTime'}]/0.06; % 0.06 = 60 Hz / 1000 ms
  bar(x, [stats_act_con{:, 'accuracy'}, stats_act_inc{:, 'accuracy'}]);
  
  xticks([stats_act_con{:, 'PresTime'}]/0.06)
  xticklabels(round([stats_act_con{:, 'PresTime'}]/0.06, 2)) 
  
  xlim(xlimits)
  ylim(ylimits)
  
  legend('Congruent','Incongruent')
  title('Accuracy : ACTIONS');
  xlabel('Presentation time [ms]')
  ylabel('Accuracy (%)')
  
  % PLOT 4 : CONTEXT (Congruent vs Incongruent) ===========================
  subplot(2,2,4);
  assert(height(stats_ctx_con) == height(stats_ctx_inc));
  x = [stats_ctx_con{:, 'PresTime'}]/0.06; % 0.06 = 60 Hz / 1000 ms
  bar(x, [stats_ctx_con{:, 'accuracy'}, stats_ctx_inc{:, 'accuracy'}]);
  
  xticks([stats_ctx_con{:, 'PresTime'}]/0.06)
  xticklabels(round([stats_ctx_con{:, 'PresTime'}]/0.06, 2)) 

  xlim(xlimits)
  ylim(ylimits)

  legend('Congruent','Incongruent')
  title('Accuracy : CONTEXT');
  xlabel('Presentation time [ms]')
  ylabel('Accuracy (%)')

  if save_plots
     % define resolution figure to be saved in dpi
   res = 420;
   % recalculate figure size to be saved
   set(fh,'PaperPositionMode','manual')
   fh.PaperUnits = 'inches';
   fh.PaperPosition = [0 0 5000 2500]/res;
   print('-dpng','-r300',['plots/' ExpInfo.Cfg.name '_accuracies'])
  end
end % plots
end % function


%% ########################################################################
% Functions
%% ########################################################################
function t_stats = accuracy(t_stats)
  % 1) Extract nr of HITS and CORRECT REJECTIONS
  % 2) Compute accuracy as the ration of (HITS+CORR_REJECT) / N_samples
  %fprintf('Computing accuracy ...\n')

  for i=1:height(t_stats)
    % Compute accuracy as ratio
    ratio = (t_stats.Hits(i) + t_stats.CorrectRejections(i)) / t_stats.N_samples(i);
    t_stats{i, 'accuracy'} = ratio * 100;
  end
end