function plotRT(ExpInfo, save_plots)
%function computeRTstatistics(ExpInfo, key_yes, key_no, save_plots)
% Computes RT statistics (mean & std) per condition for each probe type and
% congruency.
%
% Written for BriefAC (AinC)
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

%% Collect RT statistics
% Extract RT = f(presentation time) by probe type
rt_act_con = getRTstats(t_trialsActionCompatible);
rt_ctx_con = getRTstats(t_trialsContextCompatible);
rt_act_inc = getRTstats(t_trialsActionIncompatible);
rt_ctx_inc = getRTstats(t_trialsContextIncompatible);

%% ########################################################################
% Plots [COMPATIBLE]
if make_plots
  fh = figure;
  
  subplot(2,2,1);
  % Plot RT's as a function of presentation time
  screen_freq = (1/60);
  factor = screen_freq*1000;
  ylimits = [500 1500];
  xlimits = [1.8 8.2]*factor;
  x = [rt_ctx_con{:, 1}]*factor; % in ms
  
  % Collect mean RT's for action and context probes
  yAct = [rt_act_con{:, 2}];
  yCon = [rt_ctx_con{:, 2}];
  % Collect RT's standard deviation for action and context probes
  stdAct = [rt_act_con{:, 3}];
  stdCon = [rt_ctx_con{:, 3}];
  
  e1 = errorbar(x,yAct,stdAct);
  hold on
  e2 = errorbar(x,yCon,stdCon);
  
  e1.Marker = "x";
  e2.Marker = "o";
  
  title('RT : Action & Context Probes [COMPATIBLE]');
  legend('Actions','Context')
  xlabel('Presentation time [ms]')
  ylabel('RT [ms]')
  xlim(xlimits)
  ylim(ylimits);
  
  % Plot [INCOMPATIBLE]
  subplot(2,2,2);
  % Plot RT's as a function of presentation time
  screen_freq = (1/60);
  factor = screen_freq*1000;
  x = [rt_act_inc{:, 1}]*factor; % in ms
  
  % Collect mean RT's for action and context probes
  yAct = [rt_act_inc{:, 2}];
  yCon = [rt_ctx_inc{:, 2}];
  % Collect RT's standard deviation for action and context probes
  stdAct = [rt_act_inc{:, 3}];
  stdCon = [rt_ctx_inc{:, 3}];
  
  e1 = errorbar(x,yAct,stdAct);
  hold on
  e2 = errorbar(x,yCon,stdCon);
  
  e1.Marker = "x";
  e2.Marker = "o";
  
  title('RT : Action & Context Probes [INCOMPATIBLE]');
  legend('Actions','Context')
  xlabel('Presentation time [ms]')
  ylabel('RT [ms]')
  xlim(xlimits)
  ylim(ylimits);
  
  % Plot ACTIONS : compatible vs incompatible
  subplot(2,2,3);
  % Plot RT's as a function of presentation time
  screen_freq = (1/60);
  factor = screen_freq*1000;
  x = [rt_ctx_con{:, 1}]*factor; % in ms
  
  % Collect mean RT's for action and context probes
  yAct = [rt_act_con{:, 2}];
  yCon = [rt_act_inc{:, 2}];
  % Collect RT's standard deviation for action and context probes
  stdAct = [rt_act_con{:, 3}];
  stdCon = [rt_act_inc{:, 3}];
  
  e1 = errorbar(x,yAct,stdAct);
  hold on
  e2 = errorbar(x,yCon,stdCon);
  
  e1.Marker = "x";
  e2.Marker = "o";
  
  title('RT : Actions');
  legend('Compatible','Incompatible')
  xlabel('Presentation time [ms]')
  ylabel('RT [ms]')
  xlim(xlimits)
  ylim(ylimits);

  % Plot CONTEXT : compatible vs incompatible
  subplot(2,2,4);
  % Plot RT's as a function of presentation time
  screen_freq = (1/60);
  factor = screen_freq*1000;
  x = [rt_ctx_con{:, 1}]*factor; % in ms
  
  % Collect mean RT's for action and context probes
  yAct = [rt_ctx_con{:, 2}];
  yCon = [rt_ctx_inc{:, 2}];
  % Collect RT's standard deviation for action and context probes
  stdAct = [rt_act_con{:, 3}];
  stdCon = [rt_ctx_inc{:, 3}];
  
  e1 = errorbar(x,yAct,stdAct);
  hold on
  e2 = errorbar(x,yCon,stdCon);
  
  e1.Marker = "x";
  e2.Marker = "o";
  
  title('RTs : Contexts');
  legend('Compatible','Incompatible')
  xlabel('Presentation time [ms]')
  ylabel('RT [ms]')
  xlim(xlimits)
  ylim(ylimits);

  if save_plots
     % define resolution figure to be saved in dpi
   res = 420;
   % recalculate figure size to be saved
   set(fh,'PaperPositionMode','manual')
   fh.PaperUnits = 'inches';
   fh.PaperPosition = [0 0 5000 2500]/res;
   print('-dpng','-r300',['plots/' ExpInfo.Cfg.name '_RT_statistics'])
  end
end

end



%% ------------------------------------------------------------------------
function stats = getRTstats(t_trials)
  % t_trials : table
  % iterate over unique values in PresTime and compute mean & std for each
  fprintf('Collecting RTs...\n')

  stats = {};
  uniqTimes = unique(t_trials.PresTime);
  
  fprintf('\nTarget duration: mean & std RT\n')
  for i=1:length(uniqTimes)
    values = t_trials.RT(t_trials.PresTime==uniqTimes(i));
    if isequal(class(values), 'cell'); values = cell2mat(values); end
    avg = nanmean(values);
    %stdev = nanstd(values); % SD
    stderr = nanstd(values) / sqrt(length(values)); % SE : standard error
    fprintf('PresTime: %d; Mean RT: %.2fms; SE RT: %.2fms\n',...
            uniqTimes(i), avg, stderr);
    stats(end+1, :) = {uniqTimes(i), avg, stderr};
  end
end