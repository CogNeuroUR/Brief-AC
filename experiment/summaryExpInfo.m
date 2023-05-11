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

%% Collect correct & empty responses
i_correct = 0;
i_empty = 0;
[n_trials, ~] = size(t_trials);
for i=1:n_trials
  response = t_trials.ResKey(i);
  truth = t_trials.TrueKey(i);
  % convert to matrix, if cell
  if isequal(class(response), 'cell')
    response = cell2mat(response);
  end
  if isequal(class(truth), 'cell')
    truth = cell2mat(truth);
  end
  % count empty
  if isequal(response, [])
    i_empty = i_empty + 1;
  end
  % count correct
  if response == truth
      i_correct = i_correct + 1;
  end
end

%% Print
fprintf('====================================================')
fprintf('\nShort response summary:\n');
fprintf('= Correct responses: %d/%d (%.2f%%).\n', i_correct, n_trials,...
                                                i_correct*100/n_trials);
fprintf('= Empty responses: %d/%d (%.2f%%).\n', i_empty, n_trials,...
                                              i_empty*100/n_trials);
fprintf('====================================================')
fprintf('\n');

end

%% ------------------------------------------------------------------------
function t_trial_info = getExpSummary(ExpInfo)

%% Load "info" about factorial structure
info = getDesignParams();

%% Collect trial info
trials = {};
for i=1:length(ExpInfo.TrialInfo)
  % extract trial's probe type from last page number
  last_page = ExpInfo.TrialInfo(i).trial.pageNumber(end);
  
  % decode probeType and Probe
  code = ExpInfo.TrialInfo(i).trial.code;
  % Exclude special trials:
  if code > 999; continue; end
  [congruence, probeType, Probe] = decodeProbe(code, info);



  trials(end+1, :) = {ExpInfo.TrialInfo(i).trial.pageDuration(3),...
                      ExpInfo.TrialInfo(i).Response.key,...
                      ExpInfo.TrialInfo(i).trial.correctResponse,...
                      ExpInfo.TrialInfo(i).Response.RT,...
                      congruence, probeType, Probe};   

end

%% Convert cells to tables
varnames = {'PresTime' 'ResKey' 'TrueKey' 'RT', 'Congruency', 'ProbeType', 'Probe'};
t_trial_info = cell2table(trials, 'VariableNames', varnames);

end
