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
info.CongruencyLevels = ["congruent", "incongruent"];
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
trials_action_congruent = {};
trials_context_congruent = {};
trials_action_incongruent = {};
trials_context_incongruent = {};

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

  if isequal(congruency, 'congruent')
    % check if from action probes
    if isequal(probeType, "action")
      trials_action_congruent(end+1, :) = {...
                       ExpInfo.TrialInfo(i).trial.pageDuration(3),...
                       ExpInfo.TrialInfo(i).Response.key,...
                       ExpInfo.TrialInfo(i).trial.correctResponse,...
                       ExpInfo.TrialInfo(i).Response.RT};    
    
    % check if from context probes 
    elseif isequal(probeType, "context")
      trials_context_congruent(end+1, :) = {...
                        ExpInfo.TrialInfo(i).trial.pageDuration(3),...
                        ExpInfo.TrialInfo(i).Response.key,...
                        ExpInfo.TrialInfo(i).trial.correctResponse,...
                        ExpInfo.TrialInfo(i).Response.RT};
    end  
  else
    % check if from action probes
    if isequal(probeType, "action")
      trials_action_incongruent(end+1, :) = {...
                       ExpInfo.TrialInfo(i).trial.pageDuration(3),...
                       ExpInfo.TrialInfo(i).Response.key,...
                       ExpInfo.TrialInfo(i).trial.correctResponse,...
                       ExpInfo.TrialInfo(i).Response.RT};    
    
    % check if from context probes 
    elseif isequal(probeType, "context")
      trials_context_incongruent(end+1, :) = {...
                        ExpInfo.TrialInfo(i).trial.pageDuration(3),...
                        ExpInfo.TrialInfo(i).Response.key,...
                        ExpInfo.TrialInfo(i).trial.correctResponse,...
                        ExpInfo.TrialInfo(i).Response.RT};
    end  
  end

  
end

%% Remove trials with empty cells (no response given)
[rows, cols] = find(cellfun(@isempty,trials_action_congruent));
trials_action_congruent(unique(rows),:)=[];
[rows, cols] = find(cellfun(@isempty,trials_context_congruent));
trials_context_congruent(unique(rows),:)=[];
[rows, cols] = find(cellfun(@isempty,trials_action_incongruent));
trials_action_incongruent(unique(rows),:)=[];
[rows, cols] = find(cellfun(@isempty,trials_context_incongruent));
trials_context_incongruent(unique(rows),:)=[];

%% Convert cells to tables
t_trialsActionCongruent = cell2table(trials_action_congruent,...
                            'VariableNames',{'PresTime' 'ResKey' 'TrueKey' 'RT'});
t_trialsContextCongruent = cell2table(trials_context_congruent,...
                            'VariableNames',{'PresTime' 'ResKey' 'TrueKey' 'RT'});
t_trialsActionIncongruent = cell2table(trials_action_incongruent,...
                            'VariableNames',{'PresTime' 'ResKey' 'TrueKey' 'RT'});
t_trialsContextIncongruent = cell2table(trials_context_incongruent,...
                            'VariableNames',{'PresTime' 'ResKey' 'TrueKey' 'RT'});

%% ########################################################################
% Investigate RT
%%#########################################################################

%% Extract RT = f(presentation time) by probe type
statsActionCongruent = getRTstats(t_trialsActionCongruent);
statsContextCongruent = getRTstats(t_trialsContextCongruent);
statsActionIncongruent = getRTstats(t_trialsActionIncongruent);
statsContextIncongruent = getRTstats(t_trialsContextIncongruent);

%% Plot [CONGRUENT]
% Plot RT's as a function of presentation time
screen_freq = (1/60);
factor = screen_freq*1000;
x = [statsContextCongruent{:, 1}]*factor; % in ms

% Collect mean RT's for action and context probes
yAct = [statsActionCongruent{:, 2}];
yCon = [statsContextCongruent{:, 2}];
% Collect RT's standard deviation for action and context probes
stdAct = [statsActionCongruent{:, 3}];
stdCon = [statsContextCongruent{:, 3}];

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
print('-dpng','-r300','plots/rt_congruent')
% plotshaded(x,[yAct+stdAct; [yAct-stdAct]],'r');
% plotshaded(x,yAct,'r');


%% Plot [INCONGRUENT]
% Plot RT's as a function of presentation time
screen_freq = (1/60);
factor = screen_freq*1000;
x = [statsActionIncongruent{:, 1}]*factor; % in ms

% Collect mean RT's for action and context probes
yAct = [statsActionIncongruent{:, 2}];
yCon = [statsContextIncongruent{:, 2}];
% Collect RT's standard deviation for action and context probes
stdAct = [statsActionIncongruent{:, 3}];
stdCon = [statsContextIncongruent{:, 3}];

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
print('-dpng','-r300','plots/rt_incongruent')

%% Plot ACTIONS : congruent vs incongruent
% Plot RT's as a function of presentation time
screen_freq = (1/60);
factor = screen_freq*1000;
x = [statsContextCongruent{:, 1}]*factor; % in ms

% Collect mean RT's for action and context probes
yAct = [statsActionCongruent{:, 2}];
yCon = [statsActionIncongruent{:, 2}];
% Collect RT's standard deviation for action and context probes
stdAct = [statsActionCongruent{:, 3}];
stdCon = [statsActionIncongruent{:, 3}];

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
print('-dpng','-r300','plots/rt_actions')

%% Plot CONTEXT : congruent vs incongruent
% Plot RT's as a function of presentation time
screen_freq = (1/60);
factor = screen_freq*1000;
x = [statsContextCongruent{:, 1}]*factor; % in ms

% Collect mean RT's for action and context probes
yAct = [statsContextCongruent{:, 2}];
yCon = [statsContextIncongruent{:, 2}];
% Collect RT's standard deviation for action and context probes
stdAct = [statsActionCongruent{:, 3}];
stdCon = [statsContextIncongruent{:, 3}];

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
print('-dpng','-r300','plots/rt_contexts')



%% ########################################################################
% Investigate Sensitivity index (d')
%% ########################################################################

%% Extract statistics: hits, false alarms and their rates by PROBE TYPE & CONGRUENCY
statsActionCongruent = extractResponseStats(t_trialsActionCongruent, key_yes, key_no);
statsContextCongruent = extractResponseStats(t_trialsContextCongruent, key_yes, key_no);
statsActionIncongruent = extractResponseStats(t_trialsActionIncongruent, key_yes, key_no);
statsContextIncongruent = extractResponseStats(t_trialsContextIncongruent, key_yes, key_no);


%% Compute d-prime  
t_statsActionCongruent = dprime(statsActionCongruent);
t_statsContextCongruent = dprime(statsContextCongruent);
t_statsActionIncongruent = dprime(statsActionIncongruent);
t_statsContextIncongruent = dprime(statsContextIncongruent);


%% [CONGRUENT] Plot d-prime
assert(height(t_statsActionCongruent) == height(t_statsContextCongruent));
x = [t_statsActionCongruent{:, 'PresTime'}]/0.06; % 0.06 = 60 Hz / 1000 ms
bar(x, [t_statsActionCongruent{:, 'd-prime'}, t_statsContextCongruent{:, 'd-prime'}]);

xticks([t_statsActionCongruent{:, 'PresTime'}]/0.06)
xticklabels(round([t_statsActionCongruent{:, 'PresTime'}]/0.06, 2)) 
ylim([0, max(t_statsActionCongruent{:, 'd-prime'}) + 1])

legend('Action','Context')
title('Sensitivity index (S1) [CONGRUENT]');
xlabel('Presentation time [ms]')
ylabel('d''')
print('-dpng','-r300','plots/dprime_congruent')

%% [INCONGRUENT] Plot d-prime
assert(height(t_statsActionIncongruent) == height(t_statsContextIncongruent));
x = [t_statsActionIncongruent{:, 'PresTime'}]/0.06; % 0.06 = 60 Hz / 1000 ms
bar(x, [t_statsActionIncongruent{:, 'd-prime'}, t_statsContextIncongruent{:, 'd-prime'}]);

xticks([t_statsActionIncongruent{:, 'PresTime'}]/0.06)
xticklabels(round([t_statsActionIncongruent{:, 'PresTime'}]/0.06, 2)) 
ylim([0, max(t_statsActionIncongruent{:, 'd-prime'}) + 1])

legend('Action','Context')
title('Sensitivity index (S1) [INCONGRUENT]');
xlabel('Presentation time [ms]')
ylabel('d''')
print('-dpng','-r300','plots/dprime_incongruent')

%% Plot d-prime : ACTIONS
assert(height(t_statsActionIncongruent) == height(t_statsActionCongruent));
x = [t_statsActionIncongruent{:, 'PresTime'}]/0.06; % 0.06 = 60 Hz / 1000 ms
bar(x, [t_statsActionCongruent{:, 'd-prime'}, t_statsActionIncongruent{:, 'd-prime'}]);

xticks([t_statsActionCongruent{:, 'PresTime'}]/0.06)
xticklabels(round([t_statsActionCongruent{:, 'PresTime'}]/0.06, 2)) 
ylim([0, max(t_statsActionCongruent{:, 'd-prime'}) + 1])

legend('Congruent','Incongruent')
title('Sensitivity index (S1) : ACTIONS');
xlabel('Presentation time [ms]')
ylabel('d''')
print('-dpng','-r300','plots/dprime_actions')

%% Plot d-prime : ACTIONS
assert(height(t_statsContextCongruent) == height(t_statsContextIncongruent));
x = [t_statsContextCongruent{:, 'PresTime'}]/0.06; % 0.06 = 60 Hz / 1000 ms
bar(x, [t_statsContextCongruent{:, 'd-prime'}, t_statsContextIncongruent{:, 'd-prime'}]);

xticks([t_statsContextCongruent{:, 'PresTime'}]/0.06)
xticklabels(round([t_statsContextCongruent{:, 'PresTime'}]/0.06, 2)) 
ylim([0, max(t_statsContextCongruent{:, 'd-prime'}) + 1])

legend('Congruent','Incongruent')
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
    avg = mean(values);
    stdev = std(values);
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

%% ------------------------------------------------------------------------
function varargout = plotshaded(x,y,fstr)
  % x: x coordinates
  % y: either just one y vector, or 2xN or 3xN matrix of y-data
  % fstr: format ('r' or 'b--' etc)
  %
  % example
  % x=[-10:.1:10];plotshaded(x,[sin(x.*1.1)+1;sin(x*.9)-1],'r');
  % SOURCE: http://jvoigts.scripts.mit.edu/blog/nice-shaded-plots/
   
  if size(y,1)>size(y,2)
      y=y';
  end
   
  if size(y,1)==1 % just plot one line
      plot(x,y,fstr);
  end
   
  if size(y,1)==2 %plot shaded area
      px=[x,fliplr(x)]; % make closed patch
      py=[y(1,:), fliplr(y(2,:))];
      patch(px,py,1,'FaceColor',fstr,'EdgeColor','none');
  end
   
  if size(y,1)==3 % also draw mean
      px=[x,fliplr(x)];
      py=[y(1,:), fliplr(y(3,:))];
      patch(px,py,1,'FaceColor',fstr,'EdgeColor','none');
      plot(x,y(2,:),fstr);
  end
   
  alpha(.2); % make patch transparent
  hold on
end