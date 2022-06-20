function [TRD, info] = fillTRD(subjectID, nBlocks, lBlock, RespKeys, writeTRD)
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

  %% TEMPORARY Variable defintion
%   nBlocks = 5;
%   lBlock = 144;
%   RespKeys = [0,1];
%   writeTRD = 0;

  %% 0) Asign response key mapping
  % Destination OS
  dstOS = "Windows"; %Windows"; % OR "Linux"
  % get OS-specific YES/NO key assignment and "getCorrectResponseKey" function
  [keyYes, keyNo, getCorrectResponseKey] = assignRespKeysOS(dstOS, RespKeys);


  %% 1) Get template TRD with a given number of blocks
  [TRD, info] = makeTRDTemplate(nBlocks);
  % These contain minimal info about the stimuli (targets & masks).

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% 2) Shuffle all trials together (blockwise)
  TRD = shuffleBlockWise(TRD, lBlock, 'all');
  % TODO : when shuffling all, prevent three consecutive trials with same
  % action


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% 3) Assign "probeType" & "Probe" (blockwise, congruency-wise and probeType-wise)
  %   1/2 trials per block : "context" AND 1/2 : "action" 
  % RULES (COMPLEMENTARY)
  % WITHIN CONGRUENCY & PROBE TYPE - YES vs NO trials (1:1)

  % iterate back over blocks
  ctxt_idxs = 1:info.nContextLevels;
  actn_idxs = 1:info.nActionLevels; % WITHIN CONTEXT

  for iBlock=nBlocks:-1:1
    % find indices of trials within this block
    indices = (iBlock-1)*lBlock + 1 : (iBlock)*lBlock;
    Block = TRD(indices);
    
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    % place here the assignment (for) loop and used 'Block' in place of 'TRD'

    % Collect congruent & incongruent trials
    trialsCongruent = [];
    trialsIncongruent = [];
    nTrials = length(Block);
    for iTrial = 1:nTrials
      if isequal(Block(iTrial).congruency, "congruent")
        trialsCongruent = [trialsCongruent, iTrial];
      else
        trialsIncongruent = [trialsIncongruent, iTrial];
      end
    end
    subBlockCongruent = Block(trialsCongruent);
    subBlockIncongruent = Block(trialsIncongruent);

    % Asign probeType for CONGRUENT sub-blocks
    nTrials = length(subBlockCongruent);
    for iTrial = 1:nTrials
      if iTrial > nTrials/2
        subBlockCongruent(iTrial).probeType = 'context';
      else
        subBlockCongruent(iTrial).probeType = 'action';
      end
    end

    % Asign probeType for INCONGRUENT sub-blocks
    nTrials = length(subBlockIncongruent);
    for iTrial = 1:nTrials
      if iTrial > nTrials/2
        subBlockIncongruent(iTrial).probeType = 'context';
      else
        subBlockIncongruent(iTrial).probeType = 'action';
      end
    end


    % Asign Probe ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    % Sample with replacement 1/2 trials per subBlock and make them
    % "YES"-trials and the remaining - "NO"-trials
    % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    % Shuffle indices of trials in congruent and incongruent sub-blocks
    idxCongruent = randperm(length(subBlockCongruent));
    idxIncongruent = randperm(length(subBlockIncongruent));
    
    % Asign half of them to YES and half to NO for each sub-block
    idxCongruentYes = idxCongruent(1:length(idxCongruent)/2);
    idxCongruentNo = idxCongruent(length(idxCongruent)/2+1:end);
    idxIncongruentYes = idxIncongruent(1:length(idxIncongruent)/2);
    idxIncongruentNo = idxIncongruent(length(idxIncongruent)/2+1:end);

    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    % Asign Probe for CONGRUENT YES-trials
    for idx = 1:length(idxCongruentYes)
      iTrial = idxCongruentYes(idx);
      subBlockCongruent(iTrial).Response = "yes";
      subBlockCongruent(iTrial).correctResponse = getCorrectResponseKey("yes", keyYes, keyNo);
      % assign specific context or action probe
      if isequal(subBlockCongruent(iTrial).probeType, 'context')
        subBlockCongruent(iTrial).Probe = subBlockCongruent(iTrial).context;
      else % presumably "action"
        subBlockCongruent(iTrial).Probe = subBlockCongruent(iTrial).action;
      end
    end

    % Asign Probe for INCONGRUENT YES-trials
    for idx = 1:length(idxIncongruentYes)
      iTrial = idxIncongruentYes(idx);
      subBlockIncongruent(iTrial).Response = "yes";
      subBlockIncongruent(iTrial).correctResponse = getCorrectResponseKey("yes", keyYes, keyNo);
      % assign specific context or action probe
      if isequal(subBlockIncongruent(iTrial).probeType, 'context')
        subBlockIncongruent(iTrial).Probe = subBlockIncongruent(iTrial).context;
      else % presumably "action"
        subBlockIncongruent(iTrial).Probe = subBlockIncongruent(iTrial).action;
      end
    end


    % Asign Probe for CONGRUENT NO-trials
    for idx = 1:length(idxCongruentNo)
      iTrial = idxCongruentNo(idx);
      subBlockCongruent(iTrial).Response = "no";
      subBlockCongruent(iTrial).correctResponse = getCorrectResponseKey("no", keyYes, keyNo);
      % Context probes
      if isequal(subBlockCongruent(iTrial).probeType, 'context')
        % get subset of contexts different than the current one
        inc_ctxt_idxs = ctxt_idxs(ctxt_idxs ~= subBlockCongruent(iTrial).context_idx);
        
        % asign random context from the subset
        subBlockCongruent(iTrial).Probe = info.ContextLevels(datasample(inc_ctxt_idxs, 1));
      
      % Action probes (within context)
      elseif isequal(subBlockCongruent(iTrial).probeType, 'action')
        % get subset of actions from the same source context different than
        % current action
        inc_actn_idxs = actn_idxs(actn_idxs ~= subBlockCongruent(iTrial).action_idx);

        % assign specific action probe from the subset
        subBlockCongruent(iTrial).Probe = info.ActionLevels(subBlockCongruent(iTrial).context_idx,...
                                                            datasample(inc_actn_idxs, 1));
      end
    end


    % Asign Probe for INCONGRUENT NO-trials
    for idx = 1:length(idxIncongruentNo)
      iTrial = idxIncongruentNo(idx);
      subBlockIncongruent(iTrial).Response = "no";
      subBlockIncongruent(iTrial).correctResponse = getCorrectResponseKey("no", keyYes, keyNo);
      % Context probes
      if isequal(subBlockIncongruent(iTrial).probeType, 'context')
        % get subset of contexts different than the current one
        inc_ctxt_idxs = ctxt_idxs(ctxt_idxs ~= subBlockIncongruent(iTrial).context_idx);
        
        % assign random context probe from the subset
        subBlockIncongruent(iTrial).Probe = info.ContextLevels(datasample(inc_ctxt_idxs, 1));

      % Action probes (within context)
      elseif isequal(subBlockIncongruent(iTrial).probeType, 'action')
        % get subset of actions from the same source context different than
        % current action
        inc_actn_idxs = actn_idxs(actn_idxs ~= subBlockIncongruent(iTrial).action_idx);

        % assign random action probe from the subset
        subBlockIncongruent(iTrial).Probe = info.ActionLevels(subBlockIncongruent(iTrial).sourceContext_idx,...
                                                              datasample(inc_actn_idxs, 1));
      end
    end


    % Asign the updated sub-blocks
    Block(trialsCongruent) = subBlockCongruent;
    Block(trialsIncongruent) = subBlockIncongruent;

    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    % In the end assign the updated block
    TRD(indices) = Block;
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% 4) Shuffle all rows again (blockwise)
  TRD = shuffleBlockWise(TRD, lBlock, 'all');
  % TODO : when shuffling all, prevent three consecutive trials with same
  % probe

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% 5) Assign "target Duration" (blockwise, congruency-wise and probeType-wise)
  % iterate back over blocks
  for iBlock=nBlocks:-1:1
    % find indices of trials within this block
    indices = (iBlock-1)*lBlock + 1 : (iBlock)*lBlock;
    Block = TRD(indices);

    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    % place here the assignment (for) loop and used 'Block' in place of 'TRD'
    
    % 1) iterate over Congruency
    for iCongruency=1:info.nCongruencyLevels
      % 2) iterate over probeType
      for iProbeType=1:info.nProbeTypeLevels
        % collect subset of trials based on congruency and probeType
        trialsSet = [];
        nTrials = length(Block);
        for iTrial = 1:nTrials
          if isequal(Block(iTrial).congruency, info.CongruencyLevels(iCongruency))
            if isequal(Block(iTrial).probeType, info.ProbeTypeLevels(iProbeType))
              trialsSet = [trialsSet, iTrial];
            end
          end
        end
       
        % iterate over the subset of selected trials
        count = 1;
        for idx = 1:length(trialsSet)
          iTrial = trialsSet(idx);
          % reset counter if over nr. duration levels
          if count > length(info.DurationLevels); count = 1; end
          % 3) assign duration & increment duration idx
          Block(iTrial).picDuration = info.DurationLevels(count);
          Block(iTrial).durations(3) = info.DurationLevels(count);
          count = count + 1;
        end

        % stick/append the blocks back together
        % DON'T THINK IT'S NECESSARY ANYMORE
      end % probeType

    end % Congruency
    
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    % In the end assign the updated block
    TRD(indices) = Block;
  end


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% 6) Shuffle all trials together (blockwise)
  TRD = shuffleBlockWise(TRD, lBlock, 'all');

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% 7) Add (random) jitter (100-200ms) to blank screen
  jitt_shortest = 18; % in frames (300ms, 60Hz)
  jitt_longest = 36; % in in frames (600ms, 60Hz)
  step = 2; % in frames
  
  type = 'geometric'; % distribution from which to sample (or 'normal')
  pageNumber = 2; % page 2 : blank screen

  TRD = addBlankJitter(TRD, type, jitt_shortest, jitt_longest, step, pageNumber);
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% 8) Create ASF codes based on factors (Congruency, ProbeType, Duration)
  for iTrial = 1:length(TRD)
    if TRD(iTrial).probeType == 0
      disp(TRD(iTrial));

    else
    % Create factors
    iCongruency = find(info.CongruencyLevels == TRD(iTrial).congruency);
    iProbeType = find(info.ProbeTypeLevels == TRD(iTrial).probeType);
    iDuration = find(info.DurationLevels == TRD(iTrial).picDuration);
    
    % Encode factors
    % TYPE 1: with Probe
    iProbe = find(info.ProbeLevels == TRD(iTrial).Probe);
    %code = ASF_encode([iCongruency-1 iProbeType-1 iProbe-1 iDuration-1], info.factorialStructure);
    % TYPE 2: without Probe
    code = ASF_encode([iCongruency-1 iProbeType-1 iDuration-1], info.factorialStructureSimplified);
    
    %fprintf('Code : %d, ProbeType : %d, Probe : %d, Duration : %d\n', code, iProbeType, iProbe, iDuration);
    % Assign
    TRD(iTrial).code = code;
    end
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% 9) Check codes
  codeSanityCheck(TRD, info.factorialStructureSimplified,...
                  info.CongruencyLevels, info.ProbeTypeLevels, info.ProbeLevels, info.DurationLevels);
  %codeSanityCheck(TRD, info.factorialStructure, info.CongruencyLevels,...
  %                info.ProbeTypeLevels, info.ProbeLevels, info.DurationLevels)

  %% 10) Final shuffling : NO CONDITION IS REPEATED MORE THAN TWICE!
  TRD = shuffleConditionalBlockWise(TRD, lBlock);

  %% 10.2) Recode with the full factorial strucure
  for iTrial = 1:length(TRD)
    if TRD(iTrial).probeType == 0
      disp(TRD(iTrial));

    else
    % Create factors
    iCongruency = find(info.CongruencyLevels == TRD(iTrial).congruency);
    iProbeType = find(info.ProbeTypeLevels == TRD(iTrial).probeType);
    iDuration = find(info.DurationLevels == TRD(iTrial).picDuration);
    
    % Encode factors
    % TYPE 1: with Probe
    iProbe = find(info.ProbeLevels == TRD(iTrial).Probe);
    code = ASF_encode([iCongruency-1 iProbeType-1 iProbe-1 iDuration-1], info.factorialStructure);
    
    TRD(iTrial).code = code;
    end
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% 11) Add special trials : start, preparation, pauses and end trials.
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

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% 12) Write TrialDefinitions to trd-file.
  if writeTRD
    if RespKeys(1)
      fname = sprintf('SUB-%02d_left.trd', subjectID);
    else
      fname = sprintf('SUB-%02d_right.trd', subjectID);
    end
    writeTrialDefinitions(TRD, info.factorialStructure, fname)
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Some [AUXILIARY] verbose
  % Compute duration
  durations = [TRD(:).durations];
  duration_frames = sum(durations);
  t_trial_estimate = 2.32; % in seconds (based on one pilot)
  duration_min = duration_frames / 3600; % in minutes (60fps * 60s)
  fprintf('\nN_trials : %d; Total MAX duration : %4.2fmin.\n', length(TRD), duration_min);
  fprintf('Estimated duration: %4.2fmin (%4.2fs per trial)',...
          length(TRD)*t_trial_estimate/60, t_trial_estimate);

end % fillTRD function


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Utility functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
% Code sanity check function
%function codeSanityCheck(TRD, factorialStructure, CongruencyLevels, ProbeTypeLevels, DurationLevels)
function codeSanityCheck(TRD, factorialStructure, CongruencyLevels, ProbeTypeLevels, ProbeLevels, DurationLevels)
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
    c = factors(1);   % congruency
    t = factors(2);   % probe type
    d = factors(3);   % duration

    if length(factors) == 4
      p = factors(3);   % probe
      d = factors(4);   % duration
      % Check Probe : from code vs from TRD
      if ~isequal(ProbeLevels(p+1), TRD(iTrial).Probe)
       fprintf('Probe code is wrong! From code: \"%s\" vs from TRD: \"%s\"\n',...
         ProbeLevels(p+1), TRD(iTrial).Probe)
      end
    end
    % Check Congruency : from code vs from TRD
    if ~isequal(CongruencyLevels(c+1), TRD(iTrial).congruency)
      fprintf('Congruency code is wrong! From code: \"%s\" vs from TRD: \"%s\"\n',...
        CongruencyLevels(c+1), TRD(iTrial).congruency)
    % Check ProbeType : from code vs from TRD
    elseif ~isequal(ProbeTypeLevels(t+1), TRD(iTrial).probeType)
      fprintf('ProbeType code is wrong! From code: \"%s\" vs from TRD: \"%s\"\n',...
        ProbeTypeLevels(t+1), TRD(iTrial).probeType)
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
function TrialDefinitionsNew = addPauseTrials_old(TrialDefinitions, pauseTrial, interval)
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
                         TrialDefinitionsNew(idx_position:end)];

end

%--------------------------------------------------------------------------
function TrialDefinitionsNew = addEndTrial(TrialDefinitions, endTrial)
  % Adds a trial at the beginning of the TrialDefinitions.

  %ADD BLANK TRIALS TO START AND END
  TrialDefinitionsNew = TrialDefinitions;
  TrialDefinitionsNew(end+1) = endTrial;
end