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
info = getDesignParams();

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
trials_action_compatible = {};
trials_context_compatible = {};
trials_action_incompatible = {};
trials_context_incompatible = {};

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
                                               info.CongruenceLevels,...
                                               info.ProbeTypeLevels, info.ProbeLevels);

  % Extract target "context" and "action"
  target_d = ExpInfo.TrialInfo(i).trial.pageNumber(3);
  target_split = split(std_fids(target_d), '_');
  target_csplit = split(target_split(2), '-');
  
  target_context = target_csplit(1);
  target_action = target_split(4);
  
  % compatible
  if isequal(congruency, 'compatible')
    % check if from action probes
    if isequal(probeType, "action")
      trials_action_compatible(end+1, :) = {...
                       ExpInfo.TrialInfo(i).trial.pageDuration(3),...
                       ExpInfo.TrialInfo(i).Response.key,...
                       ExpInfo.TrialInfo(i).trial.correctResponse,...
                       ExpInfo.TrialInfo(i).Response.RT,...
                       congruency, probeType, Probe,...
                       target_context, target_action};    
    
    % check if from context probes 
    elseif isequal(probeType, "context")
      trials_context_compatible(end+1, :) = {...
                        ExpInfo.TrialInfo(i).trial.pageDuration(3),...
                        ExpInfo.TrialInfo(i).Response.key,...
                        ExpInfo.TrialInfo(i).trial.correctResponse,...
                        ExpInfo.TrialInfo(i).Response.RT,...
                        congruency, probeType, Probe,...
                        target_context, target_action};
    end

  % incompatible
  elseif isequal(congruency, 'incompatible')
    % check if from action probes
    if isequal(probeType, "action")
      trials_action_incompatible(end+1, :) = {...
                       ExpInfo.TrialInfo(i).trial.pageDuration(3),...
                       ExpInfo.TrialInfo(i).Response.key,...
                       ExpInfo.TrialInfo(i).trial.correctResponse,...
                       ExpInfo.TrialInfo(i).Response.RT,...
                       congruency, probeType, Probe,...
                       target_context, target_action};    
    
    % check if from context probes 
    elseif isequal(probeType, "context")
      trials_context_incompatible(end+1, :) = {...
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
varnames = {'PresTime' 'ResKey' 'TrueKey' 'RT', 'Congruence', 'ProbeType',...
            'Probe', 'Target_Context', 'Target_Action'};
trials_act_con = cell2table(trials_action_compatible,...
                            'VariableNames', varnames);
trials_ctx_con = cell2table(trials_context_compatible,...
                            'VariableNames', varnames);
trials_act_inc = cell2table(trials_action_incompatible,...
                            'VariableNames', varnames);
trials_ctx_inc = cell2table(trials_context_incompatible,...
                            'VariableNames', varnames);
end

%% ------------------------------------------------------------------------
function [congruency, probeType, Probe] = decodeProbe(code, factorialStructure,...
                                                      CongruencyLevels,...
                                                      ProbeTypeLevels, ProbeLevels)
    % Decode factors from code
    factors = ASF_decode(code, factorialStructure);
    c = factors(1);   % congruence
    d = factors(2);   % duration
    p = factors(3);   % probe
    r = factors(4);   % correct response
    
    congruency = CongruencyLevels(c+1);
    if p+1 > 9
        probeType = ProbeTypeLevels(1);
    else
        probeType = ProbeTypeLevels(2);
    end
    Probe = ProbeLevels(p+1);
end