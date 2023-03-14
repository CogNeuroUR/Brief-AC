function [TRD, info] = fillTRD_v2(subjectID, yin, nBlocks, RespKeys, writeTRD)
% FILLS A TEMPLATE 'TrialDefinitions' STRUCT WITH NECESSARY ENTRIES,
% GIVES A STRUCTURE TO THE TRIALS.
% 
% BriefAC-v2 Experiment (AinC)
% Inspired from Hafri, Papfragou & Trueswell (2013) = Gist of events
% 
% (final) Trial structure:
% 1) Blank screen : 500ms
% 2) Fixation on blank : 300ms (jitter : 300:33:600ms, geometric distrib.)
% 3) Target picture : [33ms, 50ms, 66ms, 83ms, 100ms, 133ms]
% 4) Mask : 240ms
% 5) Probe screen : until response (max 2500ms).
% 
% VARIABLES:
%   nBlocks : number of blocks to build (int)
%   lBlock : block length (int)
%   RespKeys : (list of bool)
%     (1, 0) for "Yes" : left key, "No" : right key
%     (0, 1) for "No" : left key, "Yes" : right key"
%   writeTRD : whether to write the TRD to file (bool)
%
% oleg.vrabie@ur.de (2023)

clear TRD;
clear info;

%% TEMPORARY Variable defintion
% nBlocks = 1;
% lBlock = 432;
% RespKeys = [0,1];
% writeTRD = 0;
% yin = 1;

%% 0.0) Asign response key mapping
% Destination OS
dstOS = "Windows"; %Windows"; % OR "Linux"
% get OS-specific YES/NO key assignment and "getCorrectResponseKey" function
[keyYes, keyNo, getCorrectResponseKey] = assignRespKeysOS(dstOS, RespKeys);

%% 0.5) Stimuli files
% Read std-file
fid = fopen('stimdef.std');

tline = fgetl(fid);
std_files = [];
while ischar(tline)
    std_files = [std_files; convertCharsToStrings(tline)];
    tline = fgetl(fid);
end
fclose(fid);

prefix = ['.' '\' 'stimuli' '\']; % for stimdef created on Windows
picFormat = 'png';


%% 1) Get template TRD with a given number of blocks
[TRD, info] = makeTRDTemplate_v2();
lBlock = length(TRD) / 2;

% if yin == 1
%     TRD = load('TRD_yin.mat', 'TRD_yin');
%     TRD = TRD.TRD_yin;
% else
%     TRD = load('TRD_yang.mat', 'TRD_yang');
%     TRD = TRD.TRD_yang;
% end
% lBlock = length(TRD);
% % Replicate by the wanted amount of blocks
% TRD = repmat(TRD, 1, nBlocks);

% Get info (with factorial structure)
info = getDesignParams();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2) Add probes (random)
idxs_ctxt = 1:info.nContextLevels;
idxs_actn = 1:info.nActionLevels;

for iTrial=1:length(TRD)
    % Correct response: YES
    if isequal(TRD(iTrial).correctResponse, "yes")
        % CONTEXT
        if isequal(TRD(iTrial).probeType, "context")
            TRD(iTrial).Probe = TRD(iTrial).Context;
        % ACTION
        else
            TRD(iTrial).Probe = TRD(iTrial).Action;
        end
    % Correct response: NO
    else
        % CONTEXT
        if isequal(TRD(iTrial).probeType, "context")
            % get subset of contexts different than the current one
            temp = idxs_ctxt(idxs_ctxt ~= TRD(iTrial).idxContext);
            % asign random context from the subset
            TRD(iTrial).Probe = info.ContextLevels(...
                datasample(temp, 1));
        % ACTION
        else
            % get subset of actions different than the
            % current one (within context)
            temp = idxs_actn(idxs_actn ~= TRD(iTrial).idxAction);
            % assign specific action probe from the subset
            TRD(iTrial).Probe = info.ActionLevels(...
                TRD(iTrial).idxContext, datasample(temp, 1));
        end
    end

    %>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    %ENCODING OF FACTOR LEVELS (FACTOR LEVELS MUST START AT 0)
    TRD(iTrial).code = ASF_encode([...
        find(info.CongruenceLevels==TRD(iTrial).Compatibility)-1,...
        find(info.PresTimeLevels==TRD(iTrial).picDuration)-1,...
        find(info.ProbeLevels==TRD(iTrial).Probe)-1,...
        find(info.CorrectResponses==TRD(iTrial).correctResponse)-1],...
        info.factorialStructure);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3) Add target images
% Sample stimulus level factors (Context exemplar, Actor and View)

% Iterate over trials in TRD
for iTrial=1:length(TRD)
    % Map correct response to [0,1]
    TRD(iTrial).correctResponse = ...
        getCorrectResponseKey(TRD(iTrial).correctResponse, keyYes, keyNo);
    % Build target picture name
    fname_target = strjoin([prefix,...
                            sprintf("target_%s-%s_%s_%s_%s_%s.%s",...
                                    TRD(iTrial).Context,...
                                    datasample(info.ContextExemplarLevels,1), ...
                                    TRD(iTrial).srcContext,...
                                    TRD(iTrial).Action,...
                                    datasample(info.ViewLevels, 1), ...
                                    datasample(info.ActorLevels, 1),...
                                    picFormat)], '');
    % Build mask picture name: random OR different than target?
    temp_ictxt= randi(info.nContextLevels); % for source context
    fname_mask = strjoin([prefix,...
                          sprintf("mask_%s-%s_%s_%s_%s_%s.%s",...
                                  datasample(info.ContextLevels, 1),...
                                  datasample(info.ContextExemplarLevels,1), ...
                                  info.ContextLevels(temp_ictxt),...
                                  info.ActionLevels(temp_ictxt,...
                                                    randi(info.nActionLevels)),...
                                  datasample(info.ViewLevels, 1), ...
                                  datasample(info.ActorLevels, 1),...
                                  picFormat)], '');
    % Find the built filenames in std_files
    TRD(iTrial).targetPicture = find(std_files==fname_target);
    TRD(iTrial).maskPicture = find(std_files==fname_mask);
    % Check whether any files found
    if isempty(TRD(iTrial).targetPicture)
        error('Target fname not found! (%s)', fname_target)
    elseif isempty(TRD(iTrial).maskPicture)
        error('Mask fname not found! (%s)', fname_mask)
    end
    % Assign found std_files to ASF pages: 3: target, 4: mask
    TRD(iTrial).pictures(3) = TRD(iTrial).targetPicture;
    TRD(iTrial).pictures(4) = TRD(iTrial).maskPicture;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 4) Shuffle all trials together (blockwise)
TRD = shuffleBlockWise(TRD, lBlock, 'all');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 5) Add jitter (300-600ms) to blank screen (betw. fixation & target)
jitt_shortest = 18; % in frames (300ms, 60Hz)
jitt_longest = 36; % in in frames (600ms, 60Hz)
step = 2; % in frames
type = 'geometric'; % distribution from which to sample (or 'normal')
pageNumber = 2; % page 2 : blank screen

TRD = addBlankJitter(TRD, type, jitt_shortest, jitt_longest, step, pageNumber);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 6) Final shuffling
% Final shuffling : NO CONDITION IS REPEATED MORE THAN TWICE!
TRD = shuffleConditionalBlockWise(TRD, lBlock); % [DOESN'T DO WHAT'S EXPECTED]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 7) Trim down unnecessary columns
% Necessary fields for TRD writing:
fieldsFinal = {'pictures', 'durations', 'code', 'tOnset', 'startRTonPage',...
               'endRTonPage', 'correctResponse'};
% Get rest
fieldsRest = setdiff(fields(TRD),fieldsFinal);
% Remove rest fields from TRD
TRD = rmfield(TRD, fieldsRest);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 8) Add special trials : start, preparation, pauses and end trials.
% Add Pause trials
interval = 108; % trials between a break
info.pauseTrial = TRD(1);
info.pauseTrial.code = 1001;
info.pauseTrial.pictures = info.emptyPicture;
info.pauseTrial.durations = 30*60; % 30s in frames 
info.pauseTrial.startRTonPage = 1;
info.pauseTrial.endRTonPage = 1;
info.pauseTrial.correctResponse = 0;

TRD = addPauseTrials(TRD, info.pauseTrial, interval);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Add StartTrial (w/ instructions)
info.startTrial = info.pauseTrial;
info.startTrial.code = 1000;
info.startTrial.durations = 120*60; % 2min in frames 
TRD = addStartTrial(TRD, info.startTrial);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% TODO Add (10s) preparation (after StartTrial)
info.prepTrial = TRD(1);
info.prepTrial = info.pauseTrial;
info.prepTrial.code = 1003;
info.prepTrial.durations = 10*60; % in frames
idx_position = 2; % second trial in the list, right after start trial

TRD = addBlankTrial(TRD, info.prepTrial, idx_position);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Add Finish trial
info.endTrial = info.pauseTrial;
info.endTrial.code = 1002;

TRD = addEndTrial(TRD, info.endTrial);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 9) Write TrialDefinitions to trd-file.
if writeTRD
    if RespKeys(1)
        fname = sprintf('SUB-%02d_left.trd', subjectID);
    else
        fname = sprintf('SUB-%02d_right.trd', subjectID);
    end
    writeTrialDefinitions(TRD, info.factorialStructure, fname)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Some [AUXILIARY] verbose
% Compute duration
durations = [TRD(:).durations];
duration_frames = sum(durations);
t_trial_estimate = 3.3; % in seconds (based on one pilot)
duration_min = duration_frames / 3600; % in minutes (60fps * 60s)
fprintf('\nN_trials : %d; Total MAX duration : %4.2fmin.\n', length(TRD), duration_min);
fprintf('Estimated duration: %4.2fmin (%4.2fs per trial)\n\n',...
      length(TRD)*t_trial_estimate/60, t_trial_estimate);

end % fillTRD function


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Utility functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ------------------------------------------------------------------------
function TrialDefinitions = addBlankJitter(TrialDefinitions, type, lowest, highest, step, pageNumber)
  % Jitters the blank page duration in between two stimuli presentations,
  % given that the blank page is always the first one before the stimulus page
  %
  % Types of distributions:
  % a) geometric
  % b) normal
  nTrials = length(TrialDefinitions);
  l_jitters = [];
  
  if isequal(type, 'geometric')
    p = 0.5; % TODO : why?
  
    for iTrial = 2:nTrials
      jitter = getRandNumGeometric(lowest,...
                                   highest,...
                                   step,...
                                   p);
      TrialDefinitions(iTrial).durations(pageNumber) = jitter;
      l_jitters = [l_jitters, jitter];
    end
    
  elseif isequal(type, 'normal')
    % Define the first onset, since it is currently NaN;
    randVec = (lowest:step:highest);

    for iTrial = 2:nTrials
      % Randomize the randVec
      randIdx = randperm(length(randVec));
      jitter = randVec(randIdx);

      %Assign new onset time using the first element of the jitter vector
      TrialDefinitions(iTrial).durations(pageNumber) = jitter;
      l_jitters = [l_jitters, jitter];
    end
  
  else
    error('Unknown jittering type: \"%s\"', type);

  end
  fprintf('Mean jitter time: %.2fs (min=%.2fs, max=%.2fs).\n',...
          mean(l_jitters)/60, min(l_jitters)/60, max(l_jitters)/60);
end


%% ------------------------------------------------------------------------
function [keyYes, keyNo, getCorrectResponseKey] = assignRespKeysOS(dstOS, RespKeys)
  % LINUX : switch internal naming scheme from the operating system specific scheme
  % WINDOWS : asign manually
  if isequal(dstOS, "Linux")
    KbName('UnifyKeyNames');
    getCorrectResponseKey = @(correctResponse, keyYes, keyNo) getCorrectResponseKeyLinux(correctResponse, keyYes, keyNo);

    % Assign keyboard keys
    if RespKeys(1)
      keyYes = 'LeftArrow';
      keyNo = 'RightArrow';
    else
      keyNo = 'LeftArrow';
      keyYes = 'RightArrow';
    end
  elseif isequal(dstOS, "Windows")
    getCorrectResponseKey = @(correctResponse, keyYes, keyNo) getCorrectResponseKeyWin(correctResponse, keyYes, keyNo);
    if RespKeys(1)
      keyYes = 37;  % 'LeftArrow'
      keyNo = 39;   %'RightArrow'
    else
      keyNo = 37;   % 'LeftArrow'
      keyYes = 39;   %'RightArrow'
    end
  else
    error('Given destination OS is not in the list ("Linux", "Windows")');
  end
end


%% ------------------------------------------------------------------------
function key = getCorrectResponseKeyLinux(correctResponse, keyYes, keyNo)
  % Returns the correctResponse key, based on probe and true value.
  if isequal(correctResponse, "yes")
    key = KbName(keyYes);
  else
    key = KbName(keyNo);
  end
end

%% ------------------------------------------------------------------------
function key = getCorrectResponseKeyWin(correctResponse, keyYes, keyNo)
  % Returns the correctResponse key, based on probe and true value.
  if isequal(correctResponse, "yes")
    key = keyYes;
  else
    key = keyNo;
  end
end

%--------------------------------------------------------------------------
function TrialDefinitionsNew = addPauseTrials(TrialDefinitions, pauseTrial, interval)
  % Adds pause trials after each "interval" of trials.   
  %------------------------
  % Iterate over trials to find trial indexes for pauses
  nTrials = length(TrialDefinitions);
  
  % Sweep through trials and find positions to place pauses
  pause_idxs = [];
  for iTrial = nTrials-1:-1:1
    %TrialDefinitionsNew(iTrial) = TrialDefinitions(iTrial);
    
    if mod(iTrial, interval) == 0
      pause_idxs(end+1) = iTrial + 1;
    end
  end

  %------------------------
  % Place pause trials
  TrialDefinitionsNew = TrialDefinitions;
  for iTrial = nTrials-1:-1:1
    if mod(iTrial, interval) == 0
    % Add pauseTrial in between pre- & post-idx segments of TRD
    TrialDefinitionsNew = [TrialDefinitionsNew(1:iTrial), ...
                           pauseTrial,...
                           TrialDefinitionsNew(iTrial+1:end)];
    end
  end    
  
end

%--------------------------------------------------------------------------
function TrialDefinitionsNew = addStartTrial(TrialDefinitions, startTrial)
  % Adds a trial at the beginning of the TrialDefinitions.

  %ADD START TRIALS AT START
  nTrials = length(TrialDefinitions);
  TrialDefinitionsNew(1) = startTrial;
  for iTrial = 1:nTrials
      TrialDefinitionsNew(iTrial+1) = TrialDefinitions(iTrial);
  end
end

%--------------------------------------------------------------------------
function TrialDefinitionsNew = addBlankTrial(TrialDefinitions, blankTrial, idx_position)
  % Adds a trial at the beginning of the TrialDefinitions.

  %ADD BLANK TRIAL at given position
  TrialDefinitionsNew = TrialDefinitions;
  TrialDefinitionsNew = [TrialDefinitionsNew(1:idx_position-1),...
                         blankTrial,...
                         TrialDefinitionsNew(idx_position:end)];

end

%--------------------------------------------------------------------------
function TrialDefinitionsNew = addEndTrial(TrialDefinitions, endTrial)
  % Adds a trial at the beginning of the TrialDefinitions.

  %ADD BLANK TRIALS TO START AND END
  TrialDefinitionsNew = TrialDefinitions;
  TrialDefinitionsNew(end+1) = endTrial;
end