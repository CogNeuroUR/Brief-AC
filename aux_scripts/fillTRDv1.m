%% Load template
nBlocks = 2;
[TRD, info] = makeTRDTemplate(nBlocks);

%% Responses : YES - left OR right
% TODO : implement a list, s.t. nr. of left-yes and left-no are balanced
% across subjects.
KbName('UnifyKeyNames'); % switch internal naming scheme from the operating system specific scheme
keyYes = 'LeftArrow';
keyNo = 'RightArrow';

%% [TEMPORARY] Blockwise assignment
lBlock = 72;
nTrials = length(TRD);

% check if lBlocks is multiple of nTrials
if mod(nTrials, lBlock) ~= 0
  error('lBlocks is not a multiple of nTrials!');
else
  nBlocks = nTrials / lBlock;
end

% iterate over blocks
for iBlock=nBlocks:-1:1
  indices = (iBlock-1)*lBlock + 1 : (iBlock)*lBlock;
  disp(length(indices));
  disp(indices);
  fprintf('\n')
  Block = TRD((iBlock-1)*lBlocks : (iBlock)*lBlocks);
end
  


%% Atribute half of them to CONTEXT-probes
% and the other half to ACTION-probes
nTrials = length(TRD);
for iTrial = 1:nTrials
  if iTrial > nTrials/2
    TRD(iTrial).probeType = 'context';
  else
    TRD(iTrial).probeType = 'action';
  end
end

%% Shuffle the rows of the "probeType" column in TRD
%TRD = shuffle(TRD);
idx = randperm(length(TRD));
[TRD(:).probeType] = TRD(idx).probeType;

%% Assign "Probes" based on probe type: specific Action or specific Context
% Flatten the "ActionLevels" array
%info.ActionLevels = reshape(info.ActionLevels, 1, []);

% Sweep through trials and assign probes in cycle based on ProbeType
% "context" : "kitchen" -> "office" -> "workshop" -> "kitchen" -> ...
% "action" : "cutting" -> "grating" -> "whisking" -> "hole-punching" -> ...
count_ctx = 1;
count_act = [1, 1, 1];
for iTrial = 1:length(TRD)
  % Context probes
  if isequal(TRD(iTrial).probeType, 'context')
    % assign specific context probe
    if count_ctx > length(info.ContextLevels); count_ctx = 1; end
    TRD(iTrial).Probe = info.ContextLevels(count_ctx);
    % assign correct response
    TRD(iTrial).correctResponse = getCorrectResponse(TRD(iTrial).Probe,...
                                                     TRD(iTrial).context,...
                                                     keyYes, keyNo);
    % increment
    count_ctx = count_ctx + 1;
  % Action probes (within context)
  elseif isequal(TRD(iTrial).probeType, 'action')
    % assign specific action probe
    % Increment action cycle (within context)
    if count_act(TRD(iTrial).context_idx) > 3
      count_act(TRD(iTrial).context_idx) = 1;
    end
    % assign specific action probe
    TRD(iTrial).Probe = info.ActionLevels(TRD(iTrial).context_idx,count_act(TRD(iTrial).context_idx));
    % assign correct response
    TRD(iTrial).correctResponse = getCorrectResponse(TRD(iTrial).Probe,...
                                                     TRD(iTrial).action,...
                                                     keyYes, keyNo);
    % increment
    count_act(TRD(iTrial).context_idx) = count_act(TRD(iTrial).context_idx) + 1;
  end
end


%% Shuffle all trials TOGETHER
idx = randperm(length(TRD));
[TRD(:)] = TRD(idx);
%[TRD(:).probeType] = TRD(idx).probeType;
%[TRD(:).Probe] = TRD(idx).Probe;

%% Assign "Duration"
count = 1;
for iTrial = 1:length(TRD)
    % assign specific context probe
    if count > length(info.DurationLevels); count = 1; end
    TRD(iTrial).picDuration = info.DurationLevels(count);
    TRD(iTrial).durations(3) = info.DurationLevels(count);
    count = count + 1;
end

%% Shuffle "Durations"
idx = randperm(length(TRD));
[TRD(:).picDuration] = TRD(idx).picDuration;
[TRD(:).durations] = TRD(idx).durations;

%% Create ASF codes accounting for Actions and Contexts

for iTrial = 1:length(TRD)
  % Create factors
  iProbeType = find(info.ProbeTypeLevels == TRD(iTrial).probeType);
  iProbe = find(info.ProbeLevels == TRD(iTrial).Probe);
  iDuration = find(info.DurationLevels == TRD(iTrial).picDuration);
  % Encode factors
  code = ASF_encode([iProbeType-1 iProbe-1 iDuration-1], info.factorialStructure);
  fprintf('Code : %d, ProbeType : %d, Probe : %d, Duration : %d\n', code, iProbeType, iProbe, iDuration);
  % Assign
  TRD(iTrial).code = code;
end

%% Sanity check (with function)
codeSanityCheck(TRD, info.factorialStructure, info.ProbeTypeLevels, info.ProbeLevels, info.DurationLevels)

%% Shuffle all trials AGAIN
idx = randperm(length(TRD));
[TRD(:)] = TRD(idx);

%% Add Pause trials
interval = 72; % 144 trials : 8.7min
info.pauseTrial = TRD(1);
info.pauseTrial.code = 1001;
info.pauseTrial.targetPicture = info.emptyPicture; % Whatever number refers to the blank pic
info.pauseTrial.maskPicture = info.emptyPicture;
info.pauseTrial.Probe = 'none';
info.pauseTrial.probeType = 'none';
info.pauseTrial.pictures = info.emptyPicture;
info.pauseTrial.picDuration = 0;
info.pauseTrial.durations = 30*60; % in frames
info.pauseTrial.startRTonPage = 1;
info.pauseTrial.endRTonPage = 1;
info.pauseTrial.correctResponse = 0;

TRD = addPauseTrials(TRD, info.pauseTrial, interval);

%% Add StartTrial (w/ instructions)
info.startTrial = info.pauseTrial;
info.startTrial.code = 1000;

TRD = addStartTrial(TRD, info.startTrial);

%% TODO Add (10s) preparation (after StartTrial)
info.prepTrial = TRD(1);
info.prepTrial = info.pauseTrial;
info.prepTrial.code = 1003;
info.prepTrial.durations = 10*60; % in frames
idx_position = 2; % second trial in the list, right after start trial

TRD = addBlankTrial(TRD, info.prepTrial, idx_position);


%% Add Finish trial
info.endTrial = info.pauseTrial;
info.endTrial.code = 1002;

TRD = addEndTrial(TRD, info.endTrial);

%% Add fixation jitter
jitt_shortest = 18; % in frames
jitt_longest = 36; % in in frames
type = 'geometric';
step = 2; % in frames
pageNumber = 2; % page 2 : fixation cross
TRD = addBlankJitter(TRD, type, jitt_shortest, jitt_longest, step, pageNumber);

%% [AUXILIARY] Compute duration
durations = [TRD(:).durations];
duration_frames = sum(durations);
duration_min = duration_frames / 3600;
fprintf('\nN_trials : %d; Total MAX duration : %4.2fmin.\n', length(TRD), duration_min);

%% Write Trials to TRD file
writeTrialDefinitions(TRD, info.factorialStructure, 'test_fix-jit.trd')


%% [AUXILIARY] Test probe decoding function
code = 6;
[probeType, Probe] = decodeProbe(code, info.factorialStructure, info.ProbeTypeLevels, info.ProbeLevels);
fprintf('(%d) %s : %s\n', code, upper(probeType), upper(Probe));

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
      jitter = drawNumberFromGeoDist_GA(lowest,...
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
  fprintf('Mean jitter time: %.2fs\n', mean(l_jitters)/60);
end

%% ------------------------------------------------------------------------
function TrialDefinitions = addBlankJitterSecs(TrialDefinitions, type, lowest, highest, step, pageNumber)
  % Jitters the blank page duration in between two stimuli presentations,
  % given that the blank page is always the first one before the stimulus page
  %
  % Types of distributions:
  % a) geometric
  % b) normal
  nTrials = length(TrialDefinitions);
  l_jitters = [];
  screen_freq_hz = 60;
  
  if isequal(type, 'geometric')
    p = 0.5; % TODO : why?
  
    for iTrial = 2:nTrials
      jitter = drawNumberFromGeoDist_GA(lowest*screen_freq_hz,...
                                        highest*screen_freq_hz,...
                                        step*screen_freq_hz,...
                                        p);
      TrialDefinitions(iTrial).durations(pageNumber) = jitter;
      l_jitters = [l_jitters, jitter];
    end
    
  elseif isequal(type, 'normal')
    % Define the first onset, since it is currently NaN;
    randVec = (lowest:step:highest)*screen_freq_hz;

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
  fprintf('Mean jitter time: %.2fs\n', mean(l_jitters)/screen_freq_hz);
end

%% ------------------------------------------------------------------------
function key = getCorrectResponse(probe, truth, keyYes, keyNo)
  % Returns the correctResponse key, based on probe and true value.
  if isequal(probe, truth)
    key = KbName(keyYes);
  else
    key = KbName(keyNo);
  end
end

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

%--------------------------------------------------------------------------
% Code sanity check function
function codeSanityCheck(TRD, factorialStructure, ProbeTypeLevels, ProbeLevels, DurationLevels)
  % Checks equality between assigned trial codes and conditions show
  % by (ASF_)decoding the code, given the factorial structure.
  % Custom to "BriefAC" behavioral experiment (ActionsInContext).
  % OV 11.05.22
  %
  % NOTE: To be run before writing trials to a ".trd" file!

  % Sweep through the trials and extract codes
  fprintf('Starting checking trial codes ...\n');
  for iTrial = 1:length(TRD)
    % Decode factors from code
    factors = ASF_decode(TRD(iTrial).code,factorialStructure);
    t = factors(1);   % probe type
    p = factors(2);   % probe
    d = factors(3);   % duration
    
    % Check ProbeType : from code vs from TRD
    if ~isequal(ProbeTypeLevels(t+1), TRD(iTrial).probeType)
      fprintf('ProbeType code is wrong! From code: \"%s\" vs from TRD: \"%s\"\n',...
        ProbeTypeLevels(t+1), TRD(iTrial).probeType)
    % Check Probe : from code vs from TRD
    elseif ~isequal(ProbeLevels(p+1), TRD(iTrial).Probe)
      fprintf('Probe code is wrong! From code: \"%s\" vs from TRD: \"%s\"\n',...
        ProbeLevels(p+1), TRD(iTrial).Probe)
    % Check Duration : from code vs from TRD
    elseif ~isequal(DurationLevels(d+1), TRD(iTrial).picDuration)
      fprintf('Duration code is wrong! From code: \"%d\" vs from TRD: \"%d\"\n',...
        DurationLevels(d+1), TRD(iTrial).picDuration)
    end
  end
  fprintf('Code check finished.\n')
end

%--------------------------------------------------------------------------
function TrialDefinitionsNew = addPauseTrials(TrialDefinitions, pauseTrial, interval)
  % Adds pause trials after each "interval" of trials.   
  %------------------------
  % Iterate over trials to find trial indexes for pauses
  nTrials = length(TrialDefinitions);
  
  % Sweep through trials and find positions to place pauses
  pause_idxs = [];
  for iTrial = 2:nTrials-1
    %TrialDefinitionsNew(iTrial) = TrialDefinitions(iTrial);
    
    if mod(iTrial, interval) == 0
      pause_idxs(end+1) = iTrial + 1;
    end
  end

  %------------------------
  % Place pause trials
  TrialDefinitionsNew = TrialDefinitions;
  for idx=1:length(pause_idxs)
    % Add pauseTrial in between pre- & post-idx segments of TRD
    TrialDefinitionsNew = [TrialDefinitionsNew(1:pause_idxs(idx)-1), ...
                           pauseTrial,...
                           TrialDefinitionsNew(pause_idxs(idx)+1:end)];
  end
    
    % Add pause trial at idx
  TrialDefinitionsNew(end+1) = TrialDefinitions(end);
  
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
                         TrialDefinitionsNew(idx_position+1:end)];

end

%--------------------------------------------------------------------------
function TrialDefinitionsNew = addEndTrial(TrialDefinitions, endTrial)
  % Adds a trial at the beginning of the TrialDefinitions.

  %ADD BLANK TRIALS TO START AND END
  TrialDefinitionsNew = TrialDefinitions;
  TrialDefinitionsNew(end+1) = endTrial;
end