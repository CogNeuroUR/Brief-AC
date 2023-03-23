function tTrials = getTrialResponsesAll(ExpInfo)
% For each trial in log file, extracts:
% = target duration
% = response key given
% = correct key
% = RT
% = congruence, probeType, Probe
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

% Initialize cell arrays for all trials
trials = {};

% Iterate over trials and extract trials from each probe type
for i=1:length(ExpInfo.TrialInfo)  
    % decode probeType and Probe
    code = ExpInfo.TrialInfo(i).trial.code;
    % Exclude special trials:
    if code > 999; continue; end
    
    % Decode congruence and probe
    [congruence, probeType, Probe] = decodeProbe(code, info);
    
    % Extract target "context" and "action"
    target_d = ExpInfo.TrialInfo(i).trial.pageNumber(3);
    target_split = split(std_fids(target_d), '_');
    target_csplit = split(target_split(2), '-');
    
    target_context = target_csplit(1);
    target_action = target_split(4);
    
    trials(end+1, :) = {...
                       ExpInfo.TrialInfo(i).trial.pageDuration(3),...
                       ExpInfo.TrialInfo(i).Response.key,...
                       ExpInfo.TrialInfo(i).trial.correctResponse,...
                       ExpInfo.TrialInfo(i).Response.RT,...
                       congruence, probeType, Probe,...
                       target_context, target_action};
end

%% Convert cells to tables
varnames = {'PresTime' 'ResKey' 'TrueKey' 'RT', 'Congruence', 'ProbeType',...
            'Probe', 'Target_Context', 'Target_Action'};
tTrials = cell2table(trials, 'VariableNames', varnames);

%% Fix empty key values
tTrials = fixEmptyKeys(tTrials);
tTrials = table2struct(tTrials);

function tTrials = fixEmptyKeys(tTrials)
    % check if there are the same nr. of responses as expected ones
    assert(length(tTrials.ResKey) == length(tTrials.TrueKey));
    
    % Look for empty cells in responses and replace with zeros:
    if iscell(tTrials.ResKey)
        emptyCells = cellfun(@isempty,tTrials.ResKey);
        if ismember(1, emptyCells)
            tTrials.ResKey(emptyCells) = {0};
        end
    end
    
    % convert to matrix, if cell
    if iscell(tTrials.ResKey)
        tTrials.ResKey = cell2mat(tTrials.ResKey);
    end
    if iscell(tTrials.TrueKey)
        tTrials.TrueKey = cell2mat(tTrials.TrueKey);
    end
    
    % check AGAIN if of equal size, since cell2mat-ing might shrink an
    % array, if there were empty cell
    assert(length(tTrials.ResKey) == length(tTrials.TrueKey));

end

end