function [rt_act_con, rt_ctx_con, rt_act_inc, rt_ctx_inc] =...
          computeRTstatistics(ExpInfo, key_yes, key_no, make_plots, save_plots)
% Computes RT statistics (mean & std) per condition for each probe type and
% congruency.
%
% Written for BriefAC (AinC)
% Vrabie 2022

%% Extract trials for each probe by decoding trials' ASF code
[t_trialsActionCongruent, t_trialsContextCongruent,...
 t_trialsActionIncongruent, t_trialsContextIncongruent] = getTrialResponses(ExpInfo);

%% Collect RT statistics
% Extract RT = f(presentation time) by probe type
rt_act_con = getRTstats(t_trialsActionCongruent);
rt_ctx_con = getRTstats(t_trialsContextCongruent);
rt_act_inc = getRTstats(t_trialsActionIncongruent);
rt_ctx_inc = getRTstats(t_trialsContextIncongruent);

%% ########################################################################
% Plots [CONGRUENT]
if make_plots
  figure
  % Plot RT's as a function of presentation time
  screen_freq = (1/60);
  factor = screen_freq*1000;
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
  
  title('RT for Action and Context Probes [CONGRUNET]');
  legend('Actions','Context')
  xlabel('Presentation time [ms]')
  ylabel('RT [ms]')
  xlim([1.5 8.5]*factor)

  if save_plots
    print('-dpng','-r300',['plots/' ExpInfo.Cfg.name '_rt_congruent'])
  end
  
  % Plot [INCONGRUENT]
  figure
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
  
  title('RT for Action and Context Probes [INCONGRUENT]');
  legend('Actions','Context')
  xlabel('Presentation time [ms]')
  ylabel('RT [ms]')
  xlim([1.5 8.5]*factor)

  if save_plots
    print('-dpng','-r300', ['plots/' ExpInfo.Cfg.name '_rt_incongruent'])
  end
  
  % Plot ACTIONS : congruent vs incongruent
  figure
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
  
  title('RTs for Actions');
  legend('Congruent','Incongruent')
  xlabel('Presentation time [ms]')
  ylabel('RT [ms]')
  xlim([1.5 8.5]*factor)

  if save_plots
    print('-dpng','-r300',['plots/' ExpInfo.Cfg.name '_rt_actions'])
  end

  % Plot CONTEXT : congruent vs incongruent
  figure
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
  
  title('RTs for Contexts');
  legend('Congruent','Incongruent')
  xlabel('Presentation time [ms]')
  ylabel('RT [ms]')
  xlim([1.5 8.5]*factor)

  if save_plots
    print('-dpng','-r300', ['plots/' ExpInfo.Cfg.name '_rt_contexts'])
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
    stdev = nanstd(values);
    fprintf('PresTime: %d; Mean RT: %.2fms; SD RT: %.2fms\n',...
            uniqTimes(i), avg, stdev);
    stats(end+1, :) = {uniqTimes(i), avg, stdev};
  end
end