function [stats_act_con, stats_ctx_con,...
          stats_act_inc, stats_ctx_inc] =...
          computeSensitivity(ExpInfo, key_yes, key_no, make_plots)


%% Extract trials for each probe by decoding trials' ASF code
[t_trialsActionCongruent, t_trialsContextCongruent,...
 t_trialsActionIncongruent, t_trialsContextIncongruent] = getTrialResponses(ExpInfo);

%% Investigate Sensitivity index (d')
% Extract statistics: hits, false alarms and their rates by PROBE TYPE & CONGRUENCY
statsActionCongruent = extractResponseStats(t_trialsActionCongruent, key_yes, key_no);
statsContextCongruent = extractResponseStats(t_trialsContextCongruent, key_yes, key_no);
statsActionIncongruent = extractResponseStats(t_trialsActionIncongruent, key_yes, key_no);
statsContextIncongruent = extractResponseStats(t_trialsContextIncongruent, key_yes, key_no);


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
  title('Sensitivity index (S1) [CONGRUENT]');
  xlabel('Presentation time [ms]')
  ylabel('d''')
  print('-dpng','-r300', ['plots/' ExpInfo.Cfg.name '_dprime_congruent'])
  
  %% [INCONGRUENT] Plot d-prime
  figure
  assert(height(stats_act_inc) == height(stats_ctx_inc));
  x = [stats_act_inc{:, 'PresTime'}]/0.06; % 0.06 = 60 Hz / 1000 ms
  bar(x, [stats_act_inc{:, 'd-prime'}, stats_ctx_inc{:, 'd-prime'}]);
  
  xticks([stats_act_inc{:, 'PresTime'}]/0.06)
  xticklabels(round([stats_act_inc{:, 'PresTime'}]/0.06, 2)) 
  ylim([0, max(stats_act_inc{:, 'd-prime'}) + 1])
  
  legend('Action','Context')
  title('Sensitivity index (S1) [INCONGRUENT]');
  xlabel('Presentation time [ms]')
  ylabel('d''')
  print('-dpng','-r300', ['plots/' ExpInfo.Cfg.name '_dprime_incongruent'])
  
  %% Plot d-prime : ACTIONS
  figure
  assert(height(stats_act_inc) == height(stats_act_con));
  x = [stats_act_inc{:, 'PresTime'}]/0.06; % 0.06 = 60 Hz / 1000 ms
  bar(x, [stats_act_con{:, 'd-prime'}, stats_act_inc{:, 'd-prime'}]);
  
  xticks([stats_act_con{:, 'PresTime'}]/0.06)
  xticklabels(round([stats_act_con{:, 'PresTime'}]/0.06, 2)) 
  ylim([0, max(stats_act_con{:, 'd-prime'}) + 1])
  
  legend('Congruent','Incongruent')
  title('Sensitivity index (S1) : ACTIONS');
  xlabel('Presentation time [ms]')
  ylabel('d''')
  print('-dpng','-r300', ['plots/' ExpInfo.Cfg.name '_dprime_actions'])
  
  %% Plot d-prime : ACTIONS
  figure
  assert(height(stats_ctx_con) == height(stats_ctx_inc));
  x = [stats_ctx_con{:, 'PresTime'}]/0.06; % 0.06 = 60 Hz / 1000 ms
  bar(x, [stats_ctx_con{:, 'd-prime'}, stats_ctx_inc{:, 'd-prime'}]);
  
  xticks([stats_ctx_con{:, 'PresTime'}]/0.06)
  xticklabels(round([stats_ctx_con{:, 'PresTime'}]/0.06, 2)) 
  ylim([0, max(stats_ctx_con{:, 'd-prime'}) + 1])
  
  legend('Congruent','Incongruent')
  title('Sensitivity index (S1) : CONTEXT');
  xlabel('Presentation time [ms]')
  ylabel('d''')
  print('-dpng','-r300', ['plots/' ExpInfo.Cfg.name '_dprime_context'])
end % plots
end % function


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

%% ------------------------------------------------------------------------
function t_stats = dprime(stats)
  % 1) Extract rates
  % 2) Replace zeros and ones (to prevent infinities)
  %   Zeros -> 1/(2N); N : max nr. of observation in a group
  %   Ones  -> 1 - 1/(2N)
  % 3) Compute d-prime

  fprintf('Computing specificity (d-prime)...\n')
  t_stats = cell2table(stats(:, [1, 4, 6, 2]),...
                       'VariableNames',{'PresTime' 'Hit Rate'...
                       'False Alarm Rate' 'N'});

  for i=1:height(t_stats)
    % Action trials
    if t_stats{i, 'Hit Rate'} == 1
      t_stats{i, 'Hit Rate'} = 1 - 1/(2*t_stats{i, 'N'}); end
    if t_stats{i, 'False Alarm Rate'} == 0
      t_stats{i, 'False Alarm Rate'} = 1/(2*t_stats{i, 'N'}); end
    
    % Compute d-prime
    t_stats{i, 'd-prime'} = ...
      norminv(t_stats{i, 'Hit Rate'}) - norminv(t_stats{i,...
                                                      'False Alarm Rate'});
  end
end

%% ------------------------------------------------------------------------
function stats = extractResponseStats(tTrials, key_yes, key_no)
  % Extract responses as a function of presentation time by probe type
  % Iterate over unique values in PresTime and compute mean & std for each
  % Extracted information:
  % = presentation time
  % = hit (correct response)
  % = hit rate (hits / total_responses)
  % = false alarms (hit "yes" when NO; hit "no" when YES)
  % = false alarm rate (false_alarms / total_responses)
  % = hit_rate - falarm_rate (specificity index, i.e. d-prime)

  fprintf('Computing RT-statistics ...\n')

  stats = {};
  uniqTimes = unique(tTrials.PresTime);
  
  for i=1:length(uniqTimes)
    % collect given response and true response
    ResKeys = tTrials.ResKey(tTrials.PresTime==uniqTimes(i));
    TrueKeys = tTrials.TrueKey(tTrials.PresTime==uniqTimes(i));
    % check if there are the same nr. of responses as expected ones
    assert(length(ResKeys) == length(TrueKeys));
    
    % convert to matrix, if cell
    if isequal(class(ResKeys), 'cell')
      ResKeys = cell2mat(ResKeys);
    end
    if isequal(class(TrueKeys), 'cell')
      TrueKeys = cell2mat(TrueKeys);
    end
    
    % extract hits and false alarms
    n_samples = 0;
    hits = 0;
    misses = 0;
    corr_rejections = 0;
    f_alarms = 0;
    
    for j=1:length(ResKeys)
      n_samples = n_samples + 1;
      switch ResKeys(j)
        case key_yes % "yes" response
          if ResKeys(j) == TrueKeys(j)
            hits = hits + 1;
          else % either empty or $key_no
            disp('miss (key_yes)!');
            misses = misses + 1;
          end
        
        case key_no % "no" response
          if ResKeys(j) == TrueKeys(j)
            corr_rejections = corr_rejections + 1;
          elseif ResKeys(j) == key_yes % false alarm
            f_alarms = f_alarms + 1;
          else
            misses = misses + 1;
            disp('miss (key_no)!');
          end
      end
    end
    
    % compute hit- and false alarm rates
    if hits ~= 0
      hit_rate = hits / (hits + misses);
    else
      hit_rate = 0;
    end
    if f_alarms ~= 0
      f_alarm_rate = f_alarms / (f_alarms + corr_rejections);
    else
      f_alarm_rate = 0;
    end
    
    % concatenate
    stats(end+1, :) = {uniqTimes(i),n_samples,...
                       hits, hit_rate,...
                       f_alarms, f_alarm_rate};%,...
                       %norminv(hit_rate) - norminv(f_alarm_rate)};
  end
end

%% ------------------------------------------------------------------------
function [congruency, probeType, Probe] = decodeProbe(code, factorialStructure,...
                                                      CongruencyLevels,...
                                                      ProbeTypeLevels, ProbeLevels)
    % Decode factors from code
    factors = ASF_decode(code, factorialStructure);
    c = factors(1);   % congruency
    t = factors(2);   % probe type
    d = factors(3);   % duration

    if length(factors) == 4
      p = factors(3);   % probe
      d = factors(4);   % duration
      % Check Probe : from code vs from TRD
    end
    
    congruency = CongruencyLevels(c+1);
    probeType = ProbeTypeLevels(t+1);
    Probe = ProbeLevels(p+1);
end