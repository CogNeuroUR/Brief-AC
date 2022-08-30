%% Load data
fname = 'SUB-01_pilot-2_right.mat';
load(['results' filesep fname]);

key_yes = 39;
key_no = 37;

%%
addpath(genpath('/home/ov/asf/code'));

%% Extract page numbers for probe types
stimNames = ExpInfo.stimNames;

%% Define factorial structure
%--------------------------------------------------------------------------
% DESIGN & FACTORIAL PARAMETERS
%--------------------------------------------------------------------------
info.CongruencyLevels = ["compatible", "incompatible"];
info.nCongruencyLevels = length(info.CongruencyLevels);

info.ContextLevels = ["kitchen", "office", "workshop"];
info.nContextLevels = length(info.ContextLevels);

info.ContextExemplarLevels = ["1", "2"];
info.nContextExemplarLevels = length(info.ContextExemplarLevels);

info.ActionLevels = ["cutting", "grating", "whisking";...
                     "hole-punching", "stamping", "stapling";...
                     "hammering", "painting", "sawing"];
info.nActionLevels = length(info.ActionLevels);

info.ViewLevels = ["frontal", "lateral"];
info.nViewLevels = length(info.ViewLevels);

info.ActorLevels = ["a1", "a2"];
info.nActorLevels = length(info.ActorLevels);

info.ProbeTypeLevels = ["context", "action"]';
info.nProbeTypeLevels = length(info.ProbeTypeLevels);

info.ProbeLevels = [info.ContextLevels;...
                    info.ActionLevels];

info.ProbeLevels = reshape(info.ProbeLevels, 1, []);
info.nProbeLevels = length(info.ProbeLevels);

info.DurationLevels = [2:1:6 8]; % nr x 16.6ms
info.nDurationLevels = length(info.DurationLevels);

% FACTORIAL STRUCTURE : IVs (probeTypes, Probes, Durations)
info.factorialStructure = [info.nCongruencyLevels, info.nProbeTypeLevels, info.nProbeLevels, info.nDurationLevels];
info.factorialStructureSimplified = [info.nCongruencyLevels, info.nProbeTypeLevels, info.nDurationLevels];

%% Decode probe types from trials' ASF code
code = 79;
[congrunecy, probeType, Probe] = decodeProbe(code, info.factorialStructure,...
                                             info.CongruencyLevels,...
                                             info.ProbeTypeLevels, info.ProbeLevels);
fprintf('(%d) %s : %s\n', code, upper(probeType), upper(Probe));

%% Extract trials for each probe by decoding trials' ASF code
% Two types: (1) action; (2) context
% Information extracted:
% = presentation time
% = key pressed by subject
% = true key
% = response time (RT)

% Initialize cell arrays for context & action trials
trials_action_compatible = {};
trials_context_compatible = {};
trials_action_incompatible = {};
trials_context_incompatible = {};

% Iterate over trials and extract trials from each probe type
for i=1:length(ExpInfo.TrialInfo)
  % extract trial's probe type from last page number
  last_page = ExpInfo.TrialInfo(i).trial.pageNumber(end);
  
  % decode probeType and Probe
  code = ExpInfo.TrialInfo(i).trial.code;
  % Exclude special trials:
  if code > 999; continue; end
  [congruency, probeType, Probe] = decodeProbe(code, info.factorialStructure,...
                                               info.CongruencyLevels,...
                                               info.ProbeTypeLevels, info.ProbeLevels);

  % compatible
  if isequal(congruency, 'compatible')
    % check if from action probes
    if isequal(probeType, "action")
      trials_action_compatible(end+1, :) = {...
                       ExpInfo.TrialInfo(i).trial.pageDuration(3),...
                       ExpInfo.TrialInfo(i).Response.key,...
                       ExpInfo.TrialInfo(i).trial.correctResponse,...
                       ExpInfo.TrialInfo(i).Response.RT,...
                       congruency, probeType, Probe};    
    
    % check if from context probes 
    elseif isequal(probeType, "context")
      trials_context_compatible(end+1, :) = {...
                        ExpInfo.TrialInfo(i).trial.pageDuration(3),...
                        ExpInfo.TrialInfo(i).Response.key,...
                        ExpInfo.TrialInfo(i).trial.correctResponse,...
                        ExpInfo.TrialInfo(i).Response.RT,...
                       congruency, probeType, Probe};
    end

  % incompatible
  else
    % check if from action probes
    if isequal(probeType, "action")
      trials_action_incompatible(end+1, :) = {...
                       ExpInfo.TrialInfo(i).trial.pageDuration(3),...
                       ExpInfo.TrialInfo(i).Response.key,...
                       ExpInfo.TrialInfo(i).trial.correctResponse,...
                       ExpInfo.TrialInfo(i).Response.RT,...
                       congruency, probeType, Probe};    
    
    % check if from context probes 
    elseif isequal(probeType, "context")
      trials_context_incompatible(end+1, :) = {...
                        ExpInfo.TrialInfo(i).trial.pageDuration(3),...
                        ExpInfo.TrialInfo(i).Response.key,...
                        ExpInfo.TrialInfo(i).trial.correctResponse,...
                        ExpInfo.TrialInfo(i).Response.RT,...
                       congruency, probeType, Probe};
    end  
  end

  
end

%% Remove trials with empty cells (no response given)
% TODO: better perform nanmean() & nanstd, s.t. the misses are not ignored,
% but considered for the accuracy.
% TODO : print how many NaNs were found (and for what condition)
% [rows, cols] = find(cellfun(@isempty,trials_action_compatible));
% trials_action_compatible(unique(rows),:)=[];
% [rows, cols] = find(cellfun(@isempty,trials_context_compatible));
% trials_context_compatible(unique(rows),:)=[];
% [rows, cols] = find(cellfun(@isempty,trials_action_incompatible));
% trials_action_incompatible(unique(rows),:)=[];
% [rows, cols] = find(cellfun(@isempty,trials_context_incompatible));
% trials_context_incompatible(unique(rows),:)=[];

%% Convert cells to tables
varnames = {'PresTime' 'ResKey' 'TrueKey' 'RT', 'Congruency', 'ProbeType', 'Probe'};
t_trialsActionCompatible = cell2table(trials_action_compatible,...
                            'VariableNames', varnames);
t_trialsContextCompatible = cell2table(trials_context_compatible,...
                            'VariableNames', varnames);
t_trialsActionIncompatible = cell2table(trials_action_incompatible,...
                            'VariableNames', varnames);
t_trialsContextIncompatible = cell2table(trials_context_incompatible,...
                            'VariableNames', varnames);

%% ########################################################################
% Investigate RT
%%#########################################################################

%% Extract RT = f(presentation time) by probe type
RTstatsActionCompatible = getRTstats(t_trialsActionCompatible);
RTstatsContextCompatible = getRTstats(t_trialsContextCompatible);
RTstatsActionIncompatible = getRTstats(t_trialsActionIncompatible);
RTstatsContextIncompatible = getRTstats(t_trialsContextIncompatible);

%% Plot [COMPATIBLE]
% Plot RT's as a function of presentation time
screen_freq = (1/60);
factor = screen_freq*1000;
x = [RTstatsContextCompatible{:, 1}]*factor; % in ms

% Collect mean RT's for action and context probes
yAct = [RTstatsActionCompatible{:, 2}];
yCon = [RTstatsContextCompatible{:, 2}];
% Collect RT's standard deviation for action and context probes
stdAct = [RTstatsActionCompatible{:, 3}];
stdCon = [RTstatsContextCompatible{:, 3}];

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
print('-dpng','-r300','plots/rt_compatible')
% plotshaded(x,[yAct+stdAct; [yAct-stdAct]],'r');
% plotshaded(x,yAct,'r');


%% Plot [INCOMPATIBLE]
% Plot RT's as a function of presentation time
screen_freq = (1/60);
factor = screen_freq*1000;
x = [RTstatsActionIncompatible{:, 1}]*factor; % in ms

% Collect mean RT's for action and context probes
yAct = [RTstatsActionIncompatible{:, 2}];
yCon = [RTstatsContextIncompatible{:, 2}];
% Collect RT's standard deviation for action and context probes
stdAct = [RTstatsActionIncompatible{:, 3}];
stdCon = [RTstatsContextIncompatible{:, 3}];

e1 = errorbar(x,yAct,stdAct);
hold on
e2 = errorbar(x,yCon,stdCon);

e1.Marker = "x";
e2.Marker = "o";

title('RT for Action and Context Probes [INCOMPATIBLE]');
legend('Actions','Context')
xlabel('Presentation time [ms]')
ylabel('RT [ms]')
xlim([1.5 8.5]*factor)
print('-dpng','-r300','plots/rt_incompatible')

%% Plot ACTIONS : compatible vs incompatible
% Plot RT's as a function of presentation time
screen_freq = (1/60);
factor = screen_freq*1000;
x = [RTstatsContextCompatible{:, 1}]*factor; % in ms

% Collect mean RT's for action and context probes
yAct = [RTstatsActionCompatible{:, 2}];
yCon = [RTstatsActionIncompatible{:, 2}];
% Collect RT's standard deviation for action and context probes
stdAct = [RTstatsActionCompatible{:, 3}];
stdCon = [RTstatsActionIncompatible{:, 3}];

e1 = errorbar(x,yAct,stdAct);
hold on
e2 = errorbar(x,yCon,stdCon);

e1.Marker = "x";
e2.Marker = "o";

title('RTs for Actions');
legend('Compatible','Incompatible')
xlabel('Presentation time [ms]')
ylabel('RT [ms]')
xlim([1.5 8.5]*factor)
print('-dpng','-r300','plots/rt_actions')

%% Plot CONTEXT : compatible vs incompatible
% Plot RT's as a function of presentation time
screen_freq = (1/60);
factor = screen_freq*1000;
x = [statsContextCompatible{:, 1}]*factor; % in ms

% Collect mean RT's for action and context probes
yAct = [RTstatsContextCompatible{:, 2}];
yCon = [RTstatsContextIncompatible{:, 2}];
% Collect RT's standard deviation for action and context probes
stdAct = [RTstatsActionCompatible{:, 3}];
stdCon = [RTstatsContextIncompatible{:, 3}];

e1 = errorbar(x,yAct,stdAct);
hold on
e2 = errorbar(x,yCon,stdCon);

e1.Marker = "x";
e2.Marker = "o";

title('RTs for Contexts');
legend('Compatible','Incompatible')
xlabel('Presentation time [ms]')
ylabel('RT [ms]')
xlim([1.5 8.5]*factor)
print('-dpng','-r300','plots/rt_contexts')



%% ########################################################################
% Investigate Sensitivity index (d')
%% ########################################################################

%% Extract statistics: hits, false alarms and their rates by PROBE TYPE & CONGRUENCY
statsActionCompatible = extractResponseStats(t_trialsActionCompatible, key_yes, key_no);
statsContextCompatible = extractResponseStats(t_trialsContextCompatible, key_yes, key_no);
statsActionIncompatible = extractResponseStats(t_trialsActionIncompatible, key_yes, key_no);
statsContextIncompatible = extractResponseStats(t_trialsContextIncompatible, key_yes, key_no);


%% Compute d-prime  
t_statsActionCompatible = dprime(statsActionCompatible);
t_statsContextCompatible = dprime(statsContextCompatible);
t_statsActionIncompatible = dprime(statsActionIncompatible);
t_statsContextIncompatible = dprime(statsContextIncompatible);


%% [COMPATIBLE] Plot d-prime
assert(height(t_statsActionCompatible) == height(t_statsContextCompatible));
x = [t_statsActionCompatible{:, 'PresTime'}]/0.06; % 0.06 = 60 Hz / 1000 ms
bar(x, [t_statsActionCompatible{:, 'd-prime'}, t_statsContextCompatible{:, 'd-prime'}]);

xticks([t_statsActionCompatible{:, 'PresTime'}]/0.06)
xticklabels(round([t_statsActionCompatible{:, 'PresTime'}]/0.06, 2)) 
ylim([0, max(t_statsActionCompatible{:, 'd-prime'}) + 1])

legend('Action','Context')
title('Sensitivity index (S1) [COMPATIBLE]');
xlabel('Presentation time [ms]')
ylabel('d''')
print('-dpng','-r300','plots/dprime_compatible_nan')

%% [INCOMPATIBLE] Plot d-prime
assert(height(t_statsActionIncompatible) == height(t_statsContextIncompatible));
x = [t_statsActionIncompatible{:, 'PresTime'}]/0.06; % 0.06 = 60 Hz / 1000 ms
bar(x, [t_statsActionIncompatible{:, 'd-prime'}, t_statsContextIncompatible{:, 'd-prime'}]);

xticks([t_statsActionIncompatible{:, 'PresTime'}]/0.06)
xticklabels(round([t_statsActionIncompatible{:, 'PresTime'}]/0.06, 2)) 
ylim([0, max(t_statsActionIncompatible{:, 'd-prime'}) + 1])

legend('Action','Context')
title('Sensitivity index (S1) [INCOMPATIBLE]');
xlabel('Presentation time [ms]')
ylabel('d''')
print('-dpng','-r300','plots/dprime_incompatible_nan')

%% Plot d-prime : ACTIONS
assert(height(t_statsActionIncompatible) == height(t_statsActionCompatible));
x = [t_statsActionIncompatible{:, 'PresTime'}]/0.06; % 0.06 = 60 Hz / 1000 ms
bar(x, [t_statsActionCompatible{:, 'd-prime'}, t_statsActionIncompatible{:, 'd-prime'}]);

xticks([t_statsActionCompatible{:, 'PresTime'}]/0.06)
xticklabels(round([t_statsActionCompatible{:, 'PresTime'}]/0.06, 2)) 
ylim([0, max(t_statsActionCompatible{:, 'd-prime'}) + 1])

legend('Compatible','Incompatible')
title('Sensitivity index (S1) : ACTIONS');
xlabel('Presentation time [ms]')
ylabel('d''')
print('-dpng','-r300','plots/dprime_actions')

%% Plot d-prime : ACTIONS
assert(height(t_statsContextCompatible) == height(t_statsContextIncompatible));
x = [t_statsContextCompatible{:, 'PresTime'}]/0.06; % 0.06 = 60 Hz / 1000 ms
bar(x, [t_statsContextCompatible{:, 'd-prime'}, t_statsContextIncompatible{:, 'd-prime'}]);

xticks([t_statsContextCompatible{:, 'PresTime'}]/0.06)
xticklabels(round([t_statsContextCompatible{:, 'PresTime'}]/0.06, 2)) 
ylim([0, max(t_statsContextCompatible{:, 'd-prime'}) + 1])

legend('Compatible','Incompatible')
title('Sensitivity index (S1) : CONTEXT');
xlabel('Presentation time [ms]')
ylabel('d''')
print('-dpng','-r300','plots/dprime_context')



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