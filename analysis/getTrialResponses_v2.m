function trials_ = getTrialResponses_v2(ExpInfo)
% For each trial in log file, extracts:
%     subID,...
%     keyYes,...
%     i,...
%     picID,...
%     target_context,...
%     target_action,...
%     congruence,...
%     ExpInfo.TrialInfo(i).trial.pageDuration(3),...
%     probeType,...
%     Probe,...
%     ExpInfo.TrialInfo(i).trial.correctResponse,...
%     ExpInfo.TrialInfo(i).Response.key,...
%     ExpInfo.TrialInfo(i).Response.RT,...
%
% Written for BriefAC-v2 (AinC)
% Vrabie 2023

%% Load "info" about factorial structure
info = getDesignParams();

%% Extract trials for each probe by decoding trials' ASF code
% Two types: (1) action; (2) context
% Information extracted:
% = presentation time
% = key pressed by subject
% = true key
% = response time (RT)

% Initialize cell arrays for context & action trials
trials_ = {};

% keyYes
finfo = split(ExpInfo.Cfg.name, '_'); % SUB-XX_keyYes -> [SUB-XX, keyYes]
if length(finfo) == 2 % main
    keyYes = finfo{2};

elseif length(finfo) == 3 % demo
    keyYes = finfo{3};
end

if isequal(keyYes, 'left')
    key_yes = 37;
    key_no = 39;
elseif isequal(keyYes, 'right')
    key_yes = 39;
    key_no = 37;
else
    error('keyYes (%s) not found!', keyYes)
end

% Subject ID
subID = split(finfo{1}, '-'); % [SUB] [XX]
subID = subID{2};

% Iterate over trials and extract trials from each probe type
for i=1:length(ExpInfo.TrialInfo)
    % extract trial's probe type from last page number
    last_page = ExpInfo.TrialInfo(i).trial.pageNumber(end);

    % decode probeType and Probe
    code = ExpInfo.TrialInfo(i).trial.code;
    % Exclude special trials:
    if code > 999; continue; end

    % Decode congruence and probe
    [congruence, probeType, Probe] = decodeProbe(code, info);


    % Extract target "context" and "action"
    picID = ExpInfo.TrialInfo(i).trial.pageNumber(3);
    target_split = split(ExpInfo.Cfg.stimNames{picID}, '_');
    target_csplit = split(target_split(2), '-');

    target_context = target_csplit(1);
    target_action = target_split(4);


    % Dump
    trials_(end+1, :) = {...
        subID,...
        keyYes,...
        i,...
        picID,...
        target_context,...
        target_action,...
        congruence,...
        ExpInfo.TrialInfo(i).trial.pageDuration(3) * ExpInfo.Cfg.Screen.monitorFlipInterval * 1000,...
        probeType,...
        Probe,...
        ExpInfo.TrialInfo(i).trial.correctResponse,...
        ExpInfo.TrialInfo(i).Response.key,...
        ExpInfo.TrialInfo(i).Response.RT,...
    };
end