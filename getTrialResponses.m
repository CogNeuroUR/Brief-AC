function [trials_act_con, trials_ctx_con,...
          trials_act_inc, trials_ctx_inc] = getTrialResponses(ExpInfo)
% For each trial in log file, extracts:
% = target duration
% = response key given
% = correct key
% = RT
% = congruency, probeType, Probe
% 
% Written for BriefAC (AinC)
% Vrabie 2022

%% Load "info" about factorial structure
info = getFactorialStructure();

%% Load stimulus definitions
std_fids = read_std();

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

% TODOs
% [x] collect target action
% [x] collect target context

% Iterate over trials and extract trials from each probe type
for i=1:length(ExpInfo.TrialInfo)
  % extract trial's probe type from last page number
  last_page = ExpInfo.TrialInfo(i).trial.pageNumber(end);
  
  % decode probeType and Probe
  code = ExpInfo.TrialInfo(i).trial.code;
  % Exclude special trials:
  if code > 999; continue; end

  % Decode congruency and probe
  [congruency, probeType, Probe] = decodeProbe(code, info.factorialStructure,...
                                               info.CongruencyLevels,...
                                               info.ProbeTypeLevels, info.ProbeLevels);

  % Extract target "context" and "action"
  target_d = ExpInfo.TrialInfo(i).trial.pageNumber(3);
  target_split = split(std_fids(target_d), '_');
  target_csplit = split(target_split(2), '-');
  
  target_context = target_csplit(1);
  target_action = target_split(4);
  
  % congruent
  if isequal(congruency, 'congruent')
    % check if from action probes
    if isequal(probeType, "action")
      trials_action_congruent(end+1, :) = {...
                       ExpInfo.TrialInfo(i).trial.pageDuration(3),...
                       ExpInfo.TrialInfo(i).Response.key,...
                       ExpInfo.TrialInfo(i).trial.correctResponse,...
                       ExpInfo.TrialInfo(i).Response.RT,...
                       congruency, probeType, Probe,...
                       target_context, target_action};    
    
    % check if from context probes 
    elseif isequal(probeType, "context")
      trials_context_congruent(end+1, :) = {...
                        ExpInfo.TrialInfo(i).trial.pageDuration(3),...
                        ExpInfo.TrialInfo(i).Response.key,...
                        ExpInfo.TrialInfo(i).trial.correctResponse,...
                        ExpInfo.TrialInfo(i).Response.RT,...
                        congruency, probeType, Probe,...
                        target_context, target_action};
    end

  % incongruent
  else
    % check if from action probes
    if isequal(probeType, "action")
      trials_action_incongruent(end+1, :) = {...
                       ExpInfo.TrialInfo(i).trial.pageDuration(3),...
                       ExpInfo.TrialInfo(i).Response.key,...
                       ExpInfo.TrialInfo(i).trial.correctResponse,...
                       ExpInfo.TrialInfo(i).Response.RT,...
                       congruency, probeType, Probe,...
                       target_context, target_action};    
    
    % check if from context probes 
    elseif isequal(probeType, "context")
      trials_context_incongruent(end+1, :) = {...
                        ExpInfo.TrialInfo(i).trial.pageDuration(3),...
                        ExpInfo.TrialInfo(i).Response.key,...
                        ExpInfo.TrialInfo(i).trial.correctResponse,...
                        ExpInfo.TrialInfo(i).Response.RT,...
                        congruency, probeType, Probe,...
                        target_context, target_action};
    end  
  end

end

%% Convert cells to tables
varnames = {'PresTime' 'ResKey' 'TrueKey' 'RT', 'Congruency', 'ProbeType',...
            'Probe', 'Target_Context', 'Target_Action'};
trials_act_con = cell2table(trials_action_congruent,...
                            'VariableNames', varnames);
trials_ctx_con = cell2table(trials_context_congruent,...
                            'VariableNames', varnames);
trials_act_inc = cell2table(trials_action_incongruent,...
                            'VariableNames', varnames);
trials_ctx_inc = cell2table(trials_context_incongruent,...
                            'VariableNames', varnames);
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