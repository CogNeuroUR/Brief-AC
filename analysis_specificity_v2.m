%% Load data
fname = 'result_TEST_1_1_right.mat';
load(['results' filesep fname]);

key_yes = 39;
key_no = 37;

%% Extract page numbers for probe types
stimNames = ExpInfo.stimNames;

%% Define factorial structure
info.ContextLevels = ["kitchen", "office", "workshop"];
info.nContextLevels = length(info.ContextLevels);

info.ContextExemplarLevels = ["1", "2"];
info.nContextExemplarLevels = length(info.ContextExemplarLevels);

info.ActionLevels = ["cutting", "grating", "whisking";...
                     "hole-punching", "stamping", "stapling";...
                     "hammering", "painting", "sawing"];
info.nActionLevels = length(info.ActionLevels);

info.ProbeTypeLevels = ["context", "action"]';
info.nProbeTypeLevels = length(info.ProbeTypeLevels);

info.ProbeLevels = [info.ContextLevels;...
                    info.ActionLevels];

info.ProbeLevels = reshape(info.ProbeLevels, 1, []);
info.nProbeLevels = length(info.ProbeLevels);

info.DurationLevels = [2:1:6 8]; % nr x 16.6ms
info.nDurationLevels = length(info.DurationLevels);

% FACTORIAL STRUCTURE : IVs (probeTypes, Probes, Durations)
info.factorialStructure = [info.nProbeTypeLevels, info.nProbeLevels, info.nDurationLevels];

%% Decode probe types from trials' ASF code

code = 79;
[probeType, Probe] = decodeProbe(code, info.factorialStructure, info.ProbeTypeLevels, info.ProbeLevels);
fprintf('(%d) %s : %s\n', code, upper(probeType), upper(Probe));


%% Extract trials for each probe by decoding trials' ASF code
% Two types: (1) action; (2) context
% Information extracted:
% = presentation time
% = key pressed by subject
% = true key
% = response time (RT)

% Initialize cell arrays for context & action trials
trials_action = {};
trials_context = {};

% Iterate over trials and extract trials from each probe type
for i=1:length(ExpInfo.TrialInfo)
  % extract trial's probe type from last page number
  last_page = ExpInfo.TrialInfo(i).trial.pageNumber(end);
  
  % decode probeType and Probe
  code = ExpInfo.TrialInfo(i).trial.code;
  % Exclude special trials:
  if code > 999; continue; end
  [probeType, Probe] = decodeProbe(code, info.factorialStructure,...
                                   info.ProbeTypeLevels, info.ProbeLevels);

  % check if from action probes
  if isequal(probeType, "action")
    trials_action(end+1, :) = {...
                     ExpInfo.TrialInfo(i).trial.pageDuration(3),...
                     ExpInfo.TrialInfo(i).Response.key,...
                     ExpInfo.TrialInfo(i).trial.correctResponse,...
                     ExpInfo.TrialInfo(i).Response.RT};    
  
  % check if from context probes 
  elseif isequal(probeType, "context")
    trials_context(end+1, :) = {...
                      ExpInfo.TrialInfo(i).trial.pageDuration(3),...
                      ExpInfo.TrialInfo(i).Response.key,...
                      ExpInfo.TrialInfo(i).trial.correctResponse,...
                      ExpInfo.TrialInfo(i).Response.RT};
  end  
end

%% Remove trials with empty cells (no response given)
[rows, cols] = find(cellfun(@isempty,trials_action));
trials_action(unique(rows),:)=[];
[rows, cols] = find(cellfun(@isempty,trials_context));
trials_context(unique(rows),:)=[];

%% Convert cells to tables
t_trialsAction = cell2table(trials_action,...
                            'VariableNames',{'PresTime' 'ResKey' 'TrueKey' 'RT'});
t_trialsContext = cell2table(trials_context,...
                            'VariableNames',{'PresTime' 'ResKey' 'TrueKey' 'RT'});

%% ########################################################################
% Investigate RT
%%#########################################################################
% Extract RT = f(presentation time) by probe type
%% Action probes
% iterate over unique values in PresTime and compute mean & std for each
statsAction = {};
uniqTimesAction = unique(t_trialsAction.PresTime);

fprintf('\n[ACTION] Target duration: mean & std RT\n')
for i=1:length(uniqTimesAction)
  values = t_trialsAction.RT(t_trialsAction.PresTime==uniqTimesAction(i));
  if isequal(class(values), 'cell'); values = cell2mat(values); end
  avg = mean(values);
  stdev = std(values);
  fprintf('PresTime: %d; Mean RT: %.2fms; SD RT: %.2fms\n',...
          uniqTimesAction(i), avg, stdev);
  statsAction(end+1, :) = {uniqTimesAction(i), avg, stdev};
end

%% Context probes
statsContext = {};
uniqTimesContext = unique(t_trialsContext.PresTime);

fprintf('\n[CONTEXT] Target duration: mean & std RT\n')
for i=1:length(uniqTimesContext)
  values = t_trialsContext.RT(t_trialsContext.PresTime==uniqTimesContext(i));
  if isequal(class(values), 'cell'); values = cell2mat(values); end
  avg = mean(values);
  stdev = std(values);
  fprintf('PresTime: %d; Mean RT: %.2fms; SD RT: %.2fms\n',...
          uniqTimesContext(i), avg, stdev);
  statsContext(end+1, :) = {uniqTimesContext(i), avg, stdev};
end

%% Plot
% Plot RT's as a function of presentation time
x = [statsAction{:, 1}];

% Collect mean RT's for action and context probes
yAct = [statsAction{:, 2}];
yCon = [statsContext{:, 2}];
% Collect RT's standard deviation for action and context probes
stdAct = [statsAction{:, 3}];
stdCon = [statsContext{:, 3}];

errorbar(x,yAct,stdAct);
hold on
errorbar(x,yCon,stdCon);

title('RT comparison for actions and scenes');
legend('Actions','Scene')
xlabel('Presentation time [ms]')
ylabel('RT [ms]')
xlim([1.5 8.5]) 

%% ########################################################################
% Investigate Sensitivity index (d')
%% ########################################################################
%% Extract responses as a function of presentation time by probe type
% Iterate over unique values in PresTime and compute mean & std for each
% Extracted information:
% = presentation time
% = hit (correct response)
% = hit rate (hits / total_responses)
% = false alarms (hit "yes" when NO; hit "no" when YES)
% = false alarm rate (false_alarms / total_responses)
% = hit_rate - falarm_rate (specificity index, i.e. d-prime)

statsAction = {};
uniqTimesAction = unique(t_trialsAction.PresTime);

for i=1:length(uniqTimesAction)
  % collect given response and true response
  ResKeys = t_trialsAction.ResKey(t_trialsAction.PresTime==uniqTimesAction(i));
  TrueKeys = t_trialsAction.TrueKey(t_trialsAction.PresTime==uniqTimesAction(i));
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
  %falarms = 0;
  for j=1:length(ResKeys)
    n_samples = n_samples + 1;
    switch ResKeys(j)
      case key_yes % "yes" response
        if ResKeys(j) == TrueKeys(j)
          hits = hits + 1;
        else
          misses = misses + 1;
        end
      case key_no % "no" response
        if ResKeys(j) == TrueKeys(j)
          corr_rejections = corr_rejections + 1;
        else
          f_alarms = f_alarms + 1;
        end
    end
  end
  
  % compute hit- and false alarm rates
  hit_rate = hits / (hits + misses);
  f_alarm_rate = f_alarms / (f_alarms + corr_rejections);
  
  % concatenate
  statsAction(end+1, :) = {uniqTimesAction(i),n_samples,...
                           hits, hit_rate,...
                           f_alarms, f_alarm_rate};%,...
                           %norminv(hit_rate) - norminv(f_alarm_rate)};
end

%% Same for context
statsContext = {};
uniqTimesContext= unique(t_trialsContext.PresTime);

for i=1:length(uniqTimesAction)
  % collect given response and true response
  ResKeys = t_trialsContext.ResKey(t_trialsContext.PresTime==uniqTimesAction(i));
  TrueKeys = t_trialsContext.TrueKey(t_trialsContext.PresTime==uniqTimesAction(i));
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
  n_obss = 0;
  hits = 0;
  misses = 0;
  corr_rejections = 0;
  f_alarms = 0;
  %falarms = 0;
  for j=1:length(ResKeys)
    n_samples = n_samples + 1;
    switch ResKeys(j)
      case key_yes % "yes" response
        if ResKeys(j) == TrueKeys(j)
          hits = hits + 1;
        else
          misses = misses + 1;
        end
      case key_no % "no" response
        if ResKeys(j) == TrueKeys(j)
          corr_rejections = corr_rejections + 1;
        else
          f_alarms = f_alarms + 1;
        end
    end
  end
  
  % compute hit- and false alarm rates
  hit_rate = hits / (hits + misses);
  f_alarm_rate = f_alarms / (f_alarms + corr_rejections);
  
  % concatenate
  statsContext(end+1, :) = {uniqTimesContext(i),n_samples,...
                           hits, hit_rate,...
                           f_alarms, f_alarm_rate};%,...
                           %norminv(hit_rate) - norminv(f_alarm_rate)};
end

%% Compute d-prime  
% 1) Extract rates
% 2) Replace zeros and ones (to prevent infinities)
%   Zeros -> 1/(2N); N : max nr. of observation in a group
%   Ones  -> 1 - 1/(2N)
% 3) Compute d-prime

t_statsAction = cell2table(statsAction(:, [1, 4, 6, 2]),...
                           'VariableNames',{'PresTime' 'Hit Rate'...
                                             'False Alarm Rate' 'N'});
t_statsContext = cell2table(statsContext(:, [1, 4, 6, 2]),...
                           'VariableNames',{'PresTime' 'Hit Rate'...
                                             'False Alarm Rate' 'N'});
% Check for length
assert(height(t_statsAction) == height(t_statsContext));
for i=1:height(t_statsAction)
  % Action trials
  if t_statsAction{i, 'Hit Rate'} == 1
    t_statsAction{i, 'Hit Rate'} = 1 - 1/(2*t_statsAction{i, 'N'}); end
  if t_statsAction{i, 'False Alarm Rate'} == 0
    t_statsAction{i, 'False Alarm Rate'} = 1/(2*t_statsAction{i, 'N'}); end
  % Context trials
  if t_statsContext{i, 'Hit Rate'} == 1
    t_statsContext{i, 'Hit Rate'} = 1 - 1/(2*t_statsContext{i, 'N'}); end
  if t_statsContext{i, 'False Alarm Rate'} == 0
    t_statsContext{i, 'False Alarm Rate'} = 1/(2*t_statsContext{i, 'N'}); end
  
  % Compute d-prime
  t_statsAction{i, 'd-prime'} = ...
    norminv(t_statsAction{i, 'Hit Rate'}) - norminv(t_statsAction{i,...
                                                    'False Alarm Rate'});
  t_statsContext{i, 'd-prime'} = ...
    norminv(t_statsContext{i, 'Hit Rate'}) - norminv(t_statsContext{i,...
                                                    'False Alarm Rate'});
end

%% Plot d-prime
x = [t_statsAction{:, 'PresTime'}]/0.06; % 0.06 = 60 Hz / 1000 ms
bar(x, [t_statsAction{:, 'd-prime'}, t_statsContext{:, 'd-prime'}]);

xticks([t_statsAction{:, 'PresTime'}]/0.06)
xticklabels(round([t_statsAction{:, 'PresTime'}]/0.06, 2)) 
ylim([0, max(t_statsAction{:, 'd-prime'}) + 1])

legend('Actions','Scene')
title('Sensitivity index (S1) : Actions vs. Scenes');
xlabel('Presentation time [ms]')
ylabel('d''')


%% ------------------------------------------------------------------------
% Probe decoding function
function [probeType, Probe] = decodeProbe(trialCode, factorialStructure, ...
                                          ProbeTypeLevels, ProbeLevels)
  % (ASF_)Decodes the probe type and the probe, given the trial code and the
  % factorial structure with its underlying factors.
  % Custom to "BriefAC" behavioral experiment (ActionsInContext).
  % OV 11.05.22
  %
  % Designed to be used in "ASF_showTrial" function.
  
  % Decode factors from code
  factors = ASF_decode(trialCode,factorialStructure);
  t = factors(1);   % probe type
  p = factors(2);   % probe
  %d = factors(3);   % duration
  
  probeType = ProbeTypeLevels(t+1);
  Probe = ProbeLevels(p+1);
end
