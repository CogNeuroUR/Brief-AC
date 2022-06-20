function summaryExpInfo(ExpInfo)
% Computes RT statistics (mean & std) per condition for each probe type and
% congruency.
%
% Written for BriefAC (AinC)
% Vrabie 2022

%% Extract trials for each probe by decoding trials' ASF code
[t_trialsActionCongruent, t_trialsContextCongruent,...
 t_trialsActionIncongruent, t_trialsContextIncongruent] = getTrialResponses(ExpInfo);

%% ------------------------------------------------------------------------
t_trials = getExpSummary(ExpInfo);

i_correct = 0;
i_empty = 0;
[n_trials, ~] = size(t_trials);
for i=1:n_trials
  if isequal(t_trials.ResKey(i), {[]})
    i_empty = i_empty + 1;
  end
  if isequal(t_trials.ResKey(i), t_trials.TrueKey(i))
      i_correct = i_correct + 1;
  end
end

fprintf('====================================================')
fprintf('\nShort response summary:\n');
fprintf('= Correct responses: %d/%d.\n', i_correct, n_trials);
fprintf('= Empty responses: %d/%d.\n', i_empty, n_trials);
fprintf('====================================================')
fprintf('\n');

end

%% ------------------------------------------------------------------------
function t_trial_info = getExpSummary(ExpInfo)

%% Load "info" about factorial structure
info = getFactorialStructure();

%% Collect trial info
trials = {};
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



  trials(end+1, :) = {ExpInfo.TrialInfo(i).trial.pageDuration(3),...
                      ExpInfo.TrialInfo(i).Response.key,...
                      ExpInfo.TrialInfo(i).trial.correctResponse,...
                      ExpInfo.TrialInfo(i).Response.RT,...
                      congruency, probeType, Probe};   

end

%% Convert cells to tables
varnames = {'PresTime' 'ResKey' 'TrueKey' 'RT', 'Congruency', 'ProbeType', 'Probe'};
t_trial_info = cell2table(trials, 'VariableNames', varnames);

end
