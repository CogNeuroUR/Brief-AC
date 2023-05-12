function [TRD_left, TRD_right, info] = makeTRDdemo(writeTRD)
%function [TRD_yin, TRD_yang, info] = makeTRDTemplate()
% Creates two template blocks (yin, yang) of trials that has the following
% factors balanced within subject:
%   = Compatibility: {compatible, incompatible}
%   = Probe Type: {context, action}
%   = Presentation Time: {33, 50, 66, 83, 100, 133ms}
%   = Correct response: {yes, no}
%   = Context: {kitchen, office, workshop}
%   = Action: {one of three : within source context}
% but with INCOMPATIBLE CONTEXT counter-balanced across subjects:
%   = GROUP 1: yin (random sample of incompatible contexts)
%   = GROUP 2: yang (incompatible context different that that of yin)
%
% The Probes (question exemplars) as well as the stimulus level factors are
% assigned in the next step with fillTRD():
%   = Probe: {9 x actions + 3 contexts)}
%   = Context exemplar: {1, 2}
%   = Actor: {a1, a2}
%   = Viewpoint: {frontal, lateral}
% 
% BriefAC_v2 (ActionsInContext)
% Vrabie 2023 

%% Debugging vars
%writeTRD = 0;

%% 0.0) Asign response key mapping
% Destination OS
dstOS = "Windows"; %Windows"; % OR "Linux"
% get OS-specific YES/NO key assignment and "getCorrectResponseKey" function
[keyYes, keyNo, getCorrectResponseKey] = assignRespKeysOS(dstOS, [0,1]);

%--------------------------------------------------------------------------
%% DESIGN & FACTORIAL PARAMETERS
%--------------------------------------------------------------------------
info = getDesignParams();

% Change parameters to fit demo stimulus set
info.PresTimeLevels = [4, 6]; % nr x 16.6ms : 67 & 100ms
info.nPresTimeLevels = length(info.PresTimeLevels);

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


%% ------------------------------------------------------------------------
TRD = makeTRDblock(info);

%% Shuffle
% Shuffle all
TRD = shuffleBlockWise(TRD, length(TRD), 'all');

%% Assign probe type, correct response and PT
% Probe Type
probeType = repmat(info.ProbeTypeLevels', 1, 9);
probeType = probeType(randperm(length(probeType)));
% correctResponse-s
resps = repmat(info.CorrectResponses, 1,9);
resps = resps(randperm(length(resps)));
% Presentation time
PTs = repmat(info.PresTimeLevels, 1, 9);
PTs = PTs(randperm(length(PTs)));

for iTrial=1:length(TRD)
    TRD(iTrial).probeType = probeType(iTrial);
    TRD(iTrial).correctResponse = resps(iTrial);
    TRD(iTrial).picDuration = PTs(iTrial);
    TRD(iTrial).durations(3) = PTs(iTrial);
end

% ------------------------------------------------------------------------
%% Assign probe
% 2) Add probes (random)
idxs_ctxt = 2:info.nContextLevels;
idxs_actn = 1:info.nActionLevels;

for iTrial=1:length(TRD)
    % Correct response: YES
    if isequal(TRD(iTrial).correctResponse, "yes")
        % CONTEXT
        if isequal(TRD(iTrial).probeType, "context")
            TRD(iTrial).Probe = TRD(iTrial).Context;
        % ACTION
        elseif isequal(TRD(iTrial).probeType, "action")
            TRD(iTrial).Probe = TRD(iTrial).Action;
        end
    % Correct response: NO
    elseif isequal(TRD(iTrial).correctResponse, "no")
        % CONTEXT
        if isequal(TRD(iTrial).probeType, "context")
            % get subset of contexts different than the current one
            temp = idxs_ctxt(idxs_ctxt ~= TRD(iTrial).idxContext);
            % asign random context from the subset
            TRD(iTrial).Probe = info.ContextLevels(...
                datasample(temp, 1));
        % ACTION
        elseif isequal(TRD(iTrial).probeType, "action")
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

%% 3) Add target and mask images, given trial conditions
% Sample stimulus level factors (Context exemplar, Actor and View)
views = repmat(info.ViewLevels, 1, 12);
views = views(randperm(length(views)));
actors = repmat(info.ActorLevels, 1, 12);
actors= actors(randperm(length(actors)));

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

%% 5) Add jitter (300-600ms) to blank screen (betw. fixation & target)
step = 2; % in frames
type = 'geometric'; % distribution from which to sample (or 'normal')
pageNumber = 2; % page 2 : blank screen

TRD = addBlankJitter(TRD, type, info.fixDurationMin, info.fixDurationMax, step, pageNumber);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 7) Trim down unnecessary columns
% Necessary fields for TRD writing:
fieldsFinal = {'pictures', 'durations', 'code', 'tOnset', 'startRTonPage',...
               'endRTonPage', 'correctResponse'};
% Get rest
fieldsRest = setdiff(fields(TRD),fieldsFinal);
% Remove rest fields from TRD
TRD = rmfield(TRD, fieldsRest);

%% Final shuffling : NO CONDITION IS REPEATED MORE THAN TWICE!
TRD = shuffleConditionalBlockWise(TRD, 9);

%% 8) Add special trials : start, preparation, pauses and end trials.
% Pause trials
interval = 9; % trials between a break
info.pauseTrial = TRD(1);
info.pauseTrial.code = 1001;
info.pauseTrial.pictures = info.emptyPicture;
info.pauseTrial.durations = 30*60; % 30s in frames 
info.pauseTrial.startRTonPage = 1;
info.pauseTrial.endRTonPage = 1;
info.pauseTrial.correctResponse = 0;
% StartTrial (w/ instructions)
info.startTrial = info.pauseTrial;
info.startTrial.code = 1000;
info.startTrial.durations = 120*60; % 2min in frames 
% Finish trial
info.endTrial = info.pauseTrial;
info.endTrial.code = 1002;

% Add trials
TRD = addPauseTrials(TRD, info.pauseTrial, interval);
TRD = addStartTrial(TRD, info.startTrial);
TRD = addEndTrial(TRD, info.endTrial);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% Create left-YES clone
TRD_left = TRD;
TRD_right = TRD;
idx_yes = find([TRD.correctResponse] == keyYes);
idx_no = find([TRD.correctResponse] == keyNo);

[TRD_left(idx_yes).correctResponse] = deal(keyNo);
[TRD_left(idx_no).correctResponse] = deal(keyYes);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 9) Write TrialDefinitions to trd-file.
if writeTRD
    fname_left = 'SUB-00_demo_left.trd';
    fname_right = 'SUB-00_demo_right.trd';
    writeTrialDefinitions(TRD_right, info.factorialStructure, fname_right)
    writeTrialDefinitions(TRD_left, info.factorialStructure, fname_left)
end

%--------------------------------------------------------------------------
end % makeTRDTemplate
%--------------------------------------------------------------------------
%% makeTRD Function
%--------------------------------------------------------------------------
function TrialDefinitions = makeTRDblock(info)

clear TrialDefinitions;
idxs_ctxt = 1:info.nContextLevels;
idxs_actn = 1:info.nActionLevels;

trialCounter = 0;

%for iProbeType = 1:info.nProbeTypeLevels
    % for iResponse = 1:info.nCorrectResponses      
    for iCompat = 1:info.nCongruenceLevels
        for iContext = 1:info.nContextLevels
            for iAction = 1:info.nActionLevels                        
                %>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                % 1) COMPATIBLE TRIALS
                ThisTrial.Compatibility = info.CongruenceLevels(iCompat);

                %   Context := source context
                %   Action  := context-compatible action
                % Save "context" for further assignment of probes AND
                % "correctResponses
                ThisTrial.Context = info.ContextLevels(iContext);
                ThisTrial.idxContext = iContext;
                ThisTrial.srcContext = ThisTrial.Context;
                ThisTrial.Action = info.ActionLevels(iContext,...
                                                     iAction);
                ThisTrial.idxAction = iAction;

                if isequal(ThisTrial.Compatibility, "incompatible")
                    % get subset of incompatible contexts
                    inc_ctxt_idxs = idxs_ctxt(idxs_ctxt ~= iContext);
                    % choose random incompatible context
                    iContextInc = datasample(inc_ctxt_idxs, 1);

                    % Save "context" for further assignment of probes AND
                    % "correctResponses
                    ThisTrial.Context = info.ContextLevels(iContextInc);
                    ThisTrial.idxContext = iContextInc;
                    ThisTrial.srcContext = info.ContextLevels(iContext);
                    ThisTrial.Action = info.ActionLevels(iContext,...
                                                         iAction);
                    ThisTrial.idxAction = iAction;
                end

                
                %>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                % PROBE & RESPONSE
                ThisTrial.probeType = info.ProbeTypeLevels(1);
                %ThisTrial.correctResponse = info.CorrectResponses(iResponse);
                ThisTrial.correctResponse = info.CorrectResponses(1);
                
                % Probes will be assigned in the next step (fillTRD_v2),
                % randomly for each subject

                %>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                % PICTURES: Placeholders
                ThisTrial.targetPicture = 0;
                ThisTrial.maskPicture = 0;

                %THE STRUCTURE IS ALWAYS THE SAME
                ThisTrial.pictures = [...
                    info.emptyPicture,...
                    info.fixationPicture,...
                    ThisTrial.targetPicture,...
                    ThisTrial.maskPicture,...
                    info.emptyPicture];

                %>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                % DURATIONS:
                % FOR HOW LONG WILL EACH PICTURE BE PRESENTED?
                ThisTrial.tOnset = 0;
                ThisTrial.picDuration = info.PresTimeLevels(1);
                ThisTrial.durations = [...
                    info.emptyDuration,...  
                    info.fixDuration,...
                    ThisTrial.picDuration,...
                    info.maskDuration,...
                    info.probeDuration];

                %>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                %ENCODING OF FACTOR LEVELS (FACTOR LEVELS MUST START AT 0)
                % NOTE: Codes will be assigned in the next step (fillTRD_v2),
                
                %>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                %WE START MEASURING THE RT AS SOON AS THE PICTURE IS PRESENTED,
                %i.e. PAGE 2
                ThisTrial.startRTonPage = info.startRTonPage;
                ThisTrial.endRTonPage = info.endRTonPage;                     

                %NOW WE STORE THIS TRIAL DEFIBITION IN AN ARRAY OF TRIAL
                %DEFINITIONS
                trialCounter = trialCounter + 1;
                TrialDefinitions(trialCounter) = ThisTrial;
            end % Action
        end % Context
    end % Correct Response
%end % Probe Type

% Remove no-longer required columns:
%auxFields = {'idxContext', 'idxAction'};
%TrialDefinitions = rmfield(TrialDefinitions, auxFields);

end % makeTRDblock

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
function TrialDefinitionsNew = addEndTrial(TrialDefinitions, endTrial)
  % Adds a trial at the beginning of the TrialDefinitions.

  %ADD BLANK TRIALS TO START AND END
  TrialDefinitionsNew = TrialDefinitions;
  TrialDefinitionsNew(end+1) = endTrial;
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

