function TRD = fillTRD(nBlocks, lBlock, RespKeys, writeTRD)
  % FILLS A TEMPLATE 'TrialDefinitions' STRUCT WITH NECESSARY ENTRIES,
  % GIVES A STRUCTURE TO THE TRIALS.
  % 
  % BriefAC Experiment (AinC)
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
  % oleg.vrabie@ur.de (2022)

  clear TRD;
  clear info;

  % Get template TRD with a given number of blocks
  [TRD, info] = makeTRDTemplate(nBlocks);
  % These contain minimal info about the stimuli (targets & masks).

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % 1) Shuffle all trials together (blockwise)
  TRD = shuffleBlockWise(TRD, lBlock, 'all');

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % 2) Assign "probeType" (blockwise)
  %   1/2 trials per block : "context" AND 1/2 : "action" 
  % iterate back over blocks
  for iBlock=nBlocks:-1:1
    % find indices of trials within this block
    indices = (iBlock-1)*lBlock + 1 : (iBlock)*lBlock;
    Block = TRD(indices);
    
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    % place here the assignment (for) loop and used 'Block' in place of 'TRD'
    nTrials = length(Block);
    for iTrial = 1:nTrials
      if iTrial > nTrials/2
        Block(iTrial).probeType = 'context';
      else
        Block(iTrial).probeType = 'action';
      end
    end
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    % In the end assign the updated block
    TRD(indices) = Block;
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % 3) Shuffle rows of "probeType" : "context" or "action" (blockwise)
  TRD = shuffleBlockWise(TRD, lBlock, 'probeType');

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % 4) Assign (specific) "Probe" and correct responses : (blockwise)
  % For example, "kitchen" (context), "stapling" (action), etc.

  % Sweep through trials and assign probes in cycle based on ProbeType
  % "context" : "kitchen" -> "office" -> "workshop" -> "kitchen" -> ...
  % "action" : "cutting" -> "grating" -> "whisking" -> "hole-punching" -> ...
  
  % switch internal naming scheme from the operating system specific scheme
  KbName('UnifyKeyNames');
  % Assign keyboard keys
  if RespKeys(1)
    keyYes = 'LeftArrow';
    keyNo = 'RightArrow';
  else
    keyNo = 'LeftArrow';
    keyYes = 'RightArrow';
  end

  % iterate back over blocks
  for iBlock=nBlocks:-1:1
    % find indices of trials within this block
    indices = (iBlock-1)*lBlock + 1 : (iBlock)*lBlock;
    Block = TRD(indices);
    
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    % place here the assignment (for) loop and used 'Block' in place of 'TRD'
    count_ctx = 1;
    count_act = [1, 1, 1];
    for iTrial = 1:length(Block)
      % Context probes
      if isequal(Block(iTrial).probeType, 'context')
        % assign specific context probe
        if count_ctx > length(info.ContextLevels); count_ctx = 1; end
        Block(iTrial).Probe = info.ContextLevels(count_ctx);
        % assign correct response
        Block(iTrial).correctResponse = getCorrectResponse(Block(iTrial).Probe,...
                                                           Block(iTrial).context,...
                                                           keyYes, keyNo);
        % increment
        count_ctx = count_ctx + 1;
      % Action probes (within context)
      elseif isequal(Block(iTrial).probeType, 'action')
        % assign specific action probe
        % Increment action cycle (within context)
        if count_act(Block(iTrial).context_idx) > 3
          count_act(Block(iTrial).context_idx) = 1;
        end
        % assign specific action probe
        Block(iTrial).Probe = info.ActionLevels(Block(iTrial).context_idx,...
                                                count_act(Block(iTrial).context_idx));
        % assign correct response
        Block(iTrial).correctResponse = getCorrectResponse(Block(iTrial).Probe,...
                                                           Block(iTrial).action,...
                                                           keyYes, keyNo);
        % increment
        count_act(Block(iTrial).context_idx) = count_act(Block(iTrial).context_idx) + 1;
      end
    end
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    % In the end assign the updated block
    TRD(indices) = Block;
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % 5) Shuffle all trials together (blockwise)
  TRD = shuffleBlockWise(TRD, lBlock, 'all');

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % 6) Assign "target Duration" (blockwise)
  % iterate back over blocks
  for iBlock=nBlocks:-1:1
    % find indices of trials within this block
    indices = (iBlock-1)*lBlock + 1 : (iBlock)*lBlock;
    Block = TRD(indices);

    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    % place here the assignment (for) loop and used 'Block' in place of 'TRD'
    count = 1;
    for iTrial = 1:length(Block)
        % assign specific context probe
        if count > length(info.DurationLevels); count = 1; end
        Block(iTrial).picDuration = info.DurationLevels(count);
        Block(iTrial).durations(3) = info.DurationLevels(count);
        count = count + 1;
    end
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    % In the end assign the updated block
    TRD(indices) = Block;
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % 7) Shuffle rows of "durations" (blockwise)
  TRD = shuffleBlockWise(TRD, lBlock, 'durations');

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % 8) Shuffle all trials together (blockwise)
  TRD = shuffleBlockWise(TRD, lBlock, 'all');

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % 9) Add (random) jitter to fixation (for a 60Hz screen)
  jitt_shortest = 18; % in frames
  jitt_longest = 36; % in in frames
  step = 2; % in frames
  
  type = 'geometric'; % distribution from which to sample (or 'normal')
  pageNumber = 2; % page 2 : fixation cross

  TRD = addBlankJitter(TRD, type, jitt_shortest, jitt_longest, step, pageNumber);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % 10) Create ASF codes based on factors (ProbeType, Probe, Duration)
  for iTrial = 1:length(TRD)
    % Create factors
    iProbeType = find(info.ProbeTypeLevels == TRD(iTrial).probeType);
    iProbe = find(info.ProbeLevels == TRD(iTrial).Probe);
    iDuration = find(info.DurationLevels == TRD(iTrial).picDuration);
    % Encode factors
    code = ASF_encode([iProbeType-1 iProbe-1 iDuration-1], info.factorialStructure);
    %fprintf('Code : %d, ProbeType : %d, Probe : %d, Duration : %d\n', code, iProbeType, iProbe, iDuration);
    % Assign
    TRD(iTrial).code = code;
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % 11) Check codes
  codeSanityCheck(TRD, info.factorialStructure,...
                  info.ProbeTypeLevels, info.ProbeLevels, info.DurationLevels)

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % 12) Add special trials : start, preparation, pauses and end trials.
  % Add Pause trials
  interval = 72; % 144 trials : 8.7min
  info.pauseTrial = TRD(1);
  info.pauseTrial.code = 1001;
  info.pauseTrial.targetPicture = info.emptyPicture; % Whatever number refers to the blank pic
  info.pauseTrial.maskPicture = info.emptyPicture;
  
  info.pauseTrial.probeType = 'none';
  info.pauseTrial.Probe = 'none';
  info.pauseTrial.context = 'none';
  info.pauseTrial.context_idx = 0;
  info.pauseTrial.action = 'none';
  
  info.pauseTrial.pictures = info.emptyPicture;
  info.pauseTrial.picDuration = 0;
  info.pauseTrial.durations = 30*60; % in frames
  info.pauseTrial.startRTonPage = 1;
  info.pauseTrial.endRTonPage = 1;
  info.pauseTrial.correctResponse = 0;
  
  TRD = addPauseTrials(TRD, info.pauseTrial, interval);

  %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  % Add StartTrial (w/ instructions)
  info.startTrial = info.pauseTrial;
  info.startTrial.code = 1000;
  
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

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % 13) Write TrialDefinitions to trd-file.
  if writeTRD
    fname = sprintf('filled.trd');
    writeTrialDefinitions(TRD, info.factorialStructure, fname)
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Some [AUXILIARY] verbose
  % Compute duration
  durations = [TRD(:).durations];
  duration_frames = sum(durations);
  duration_min = duration_frames / 3600; % in minutes (60fps * 60s)
  fprintf('\nN_trials : %d; Total MAX duration : %4.2fmin.\n', length(TRD), duration_min);

end % function


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
  fprintf('Mean jitter time: %.2fms (min=%.2fs, max=%.2fs).\n',...
          mean(l_jitters)/60, min(l_jitters)/60, max(l_jitters)/60);
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
  fprintf('\nChecking trial codes ...\n');
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