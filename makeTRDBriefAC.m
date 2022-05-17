function makeTRDFastAC(subjectID, runNum, expName)
%function makeTRDFastAC(trdName)

addpath(genpath('/usr/share/psychtoolbox-3/'))
addpath(genpath('/home/ov/asf/code'));

%%CREATES THE  FILE trdName FOR AN EXPERIMENT IN WHICH
%%ALL PICTURES ARE SHOWN ONCE IN THE ORDER AS THEY ARE REFERENCED
%%IN THE STD FILE
%
%%EXAMPLE CALL:
%makeTRDFastAC(104, 1, 'fastAC')

%--------------------------------------------------------------------------
%BASICS ABOUT THE DESIGN
%--------------------------------------------------------------------------
info.ContextLevels = ["kitchen", "office", "workshop"];
info.nContextLevels = length(info.ContextLevels);

info.ContextExemplarLevels = [1, 2];
info.nContextExemplarLevels = length(info.ContextExemplarLevels);

info.ActionLevels = ["cutting", "grating", "whisking";...
                     "hole-punching", "stamping", "stapling";...
                     "hammering", "painting", "sawing"];
info.nActionLevels = length(info.ActionLevels);

info.ViewLevels = ['frontal', 'latera'];
info.nViewLevels = length(info.ViewLevels);

info.ActorLevels = ['a1', 'a2'];
info.nActorLevels = length(info.ActorLevels);

info.ProbeTypeLevels = ["context", "action"]';
info.nProbeTypeLevels = length(info.ProbeTypeLevels);

info.ProbeLevels = ["C1", "C2", "C3";...
                    "A1", "A2", "A3"];
info.nProbeLevels = [length(info.ProbeLevels(1, :)),...
                     length(info.ProbeLevels(2, :))];

info.DurationLevels = [2:1:6 8];
info.nDurationLevels = length(info.DurationLevels);

info.emptyPicture = 1;
info.fixationPicture = 1;


%--------------------------------------------------------------------------
% HARDWARE RELATED
info.screenFrameRate = 60;

%--------------------------------------------------------------------------
% TIMING
info.emptyDuration = 24; %400ms
info.fixDuration = 24; % 400ms
info.maskDuration = 15; % 2000 ms
info.probeDuration = 150; % 2500ms
info.blankDuration = 60; % 1000ms
info.pauseIntervalSecs = 300; % IN SECONDS!
info.pauseInterval = info.pauseIntervalSecs * info.screenFrameRate;
%--------------------------------------------------------------------------

% Record RT only at probe screen
info.startRTonPage = 5;
info.endRTonPage = 5;

% Factorial Structure: IVs (probeTypes, Durations)
info.factorialStructure = [info.nProbeTypeLevels info.nDurationLevels];


%HOW MANY TRIALS PER DESIGN CELL DO YOU WANT TO RUN?
%IF YOU ARE INTERESTED IN RT ONLY, >25 IS RECOMMENDED PER PARTICIPANT
%AND CONDITIONS OF INTEREST
%IF YOU ARE INTERESTED IN ERROR RATES, 100 IS RECOMMENDED PER PARTICIPANT
%YOU MAY WANT TO SPAWN THIS NUMBER OVER DIFFERENT SESSIONS IF YOU HAVE A
%BIG DESIGN
info.nReplications = 1;%4;

trdName = sprintf('SUB%02d_%02d_%s.trd', subjectID, runNum, expName);


%------------------------
% Pause trial Definition
%------------------------
info.pauseTrial.code = 101;
info.pauseTrial.tOnset = 0;
info.pauseTrial.targetPicture = info.emptyPicture; % Whatever number refers to the blank pic
info.pauseTrial.maskPicture = info.emptyPicture;
info.pauseTrial.probe = info.emptyPicture;
info.pauseTrial.pictures = [info.emptyPicture];
info.pauseTrial.picDuration = 0;
info.pauseTrial.durations = [30];
info.pauseTrial.startRTonPage = 1;
info.pauseTrial.endRTonPage = 1;
info.pauseTrial.correctResponse = 0;


%--------------------------------------------------------------------------
%DEFINE ALL TRIALS
%--------------------------------------------------------------------------
TrialDefinitions = makeTrialDefinitions(info);

%--------------------------------------------------------------------------
%RANDOMIZE TRIALS
%--------------------------------------------------------------------------
%TrialDefinitions = shuffle(TrialDefinitions);

%--------------------------------------------------------------------------
% ADD BLANK TRIALS (START & END)
%Add blank trials to start and end (mainly for fMRI)
%TrialDefinitions = addBlankTrials(TrialDefinitions, info, 91);

% ADD "WAIT-TO-START" TRIAL
TrialDefinitions = addEndTrials(TrialDefinitions, info, 103);
TrialDefinitions = addBlankTrials(TrialDefinitions, info, 100);


  
%--------------------------------------------------------------------------
% ADD PAUSE TRIALS EVERY 5 MINUTES
TrialDefinitions = addPauseTrials(TrialDefinitions, info, info.pauseIntervalSecs);                              

%--------------------------------------------------------------------------
%WRITE RANDOMIZED DEFINITION TO TRD FILE
%--------------------------------------------------------------------------
writeTrialDefinitions(TrialDefinitions, info, trdName)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
%function TrialDefinitions = makeTrialDefinitions(info)
%CREATES  AN ARRAY OF TRIAL DEFINITIONS
%TAKES INTO ACCOUNT THE FACTRIAL INFORMATION PROVIDED ABOVE
%THIS IS THE MAIN PART YOU WOULD HAVE TO CHANGE FOR A DIFFERENT KIND OF
%EXPERIMENT
%--------------------------------------------------------------------------
function TrialDefinitions = makeTrialDefinitions(info)
  %<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  % CUSTOM PARAMETERS (OV, 23.08.21)
  pictFormat = 'png';
  prefix = ['.', filesep, 'stimuli_new' filesep];

  fid = fopen('stimdef.std');

  tline = fgetl(fid);
  std_files = [];
  while ischar(tline)
    %disp(tline)
    std_files = [std_files; convertCharsToStrings(tline)];
    tline = fgetl(fid);
  end
  fclose(fid);
  %>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  trialCounter = 0;
  for iReplication = 1:info.nReplications
    for iContext = 1:info.nContextLevels
      for iContextExemplar = 1:info.nContextExemplarLevels
        for iAction = 1:info.nActionLevels
          for iView = 1:info.nViewLevels
            for iActor = 1:info.nActorLevels
              for iProbeType = 1:info.nProbeTypeLevels
                for iProbe = 1:info.nProbeLevels(iProbeType)
                  for iDuration = 1:info.nDurationLevels
                    %ENCODING OF FACTOR LEVELS (FACTOR LEVELS MUST START AT 0)
                    %TODO: correct trial codes
                    ThisTrial.code = ASF_encode([iProbeType-1 iDuration-1], info.factorialStructure);
    
                    ThisTrial.tOnset = 0;
    
                    %<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                    %WHICH PICTURES WILL BE SHOWN IN THIS TRIAL? 
    
                    fname_target = strjoin([prefix,...
                                            sprintf("target_%s_%s_%s_%s_%s.%s",...
                                                    info.ContextLevels(iContext),...
                                                    info.ContextExemplarLevels(iContextExemplar), ...
                                                    info.ActionLevels(iContext, iAction),...
                                                    info.ViewLevels(iView), ...
                                                    info.ActorLevels(iActor),...
                                                    pictFormat)], '');
                    fname_mask = strjoin([prefix,...
                                          sprintf("mask_%s_%s_%s_%s_%s.%s",...
                                          info.ContextLevels(iContext),...
                                          info.ContextExemplarLevels(iContextExemplar), ...
                                          info.ActionLevels(iContext, iAction),...
                                          info.ViewLevels(iView), ...
                                          info.ActorLevels(iActor),...
                                          pictFormat)], '');
                    %ThisTrial.targetPicture = info.catPictures(iAction + (iContext-1)*3);
                    %ThisTrial.maskPicture = info.maskPictures(iAction + (iContext-1)*3);           
                    ThisTrial.targetPicture = find(std_files==fname_target);
                    ThisTrial.maskPicture = find(std_files==fname_mask);
    
                    %>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
                    switch iProbeType
                      case 1 % context
                        fname_probe = strjoin([prefix,...
                                               sprintf("probe_context-%s_yes-left.%s",...
                                               info.ContextLevels(iProbe),...
                                               pictFormat)], '');
    
                        %ThisTrial.probe = info.probeContextPictures(iContext);
    
                        %{
                        ThisTrial.probe = info.probeContextPictures(...
                            randi([1,...
                            length(info.probeContextPictures)]));
                        %}
    
                      case 2 % action
                        fname_probe = strjoin([prefix,...
                                               sprintf("probe_action_%s_%s_yes-left.%s",...
                                               info.ContextLevels(iContext),...
                                               info.ActionLevels(iContext, iProbe),...
                                               pictFormat)], '');
    
                        %ThisTrial.probe = info.probeActionPictures(iAction + (iContext-1)*3);
    
    
                        %ThisTrial.probe = info.probeActionPictures(randi([1,3]) + (iContext-1)*3);
    
                        % For randomization: choose randint(1,3)
                        % instead of iAction
                    end
                    ThisTrial.probe = find(std_files==fname_probe);
    
    
                    %THE STRUCTURE IS ALWAYS THE SAME
                    ThisTrial.pictures = [...
                      info.emptyPicture,... 
                      info.fixationPicture,...
                      ThisTrial.targetPicture,...
                      ThisTrial.maskPicture,...
                      ThisTrial.probe];
    
                    %FOR HOW LONG WILL EACH PICTURE BE PRESENTED?
                    ThisTrial.picDuration = info.DurationLevels(iDuration);
                    ThisTrial.durations = [...
                      info.emptyDuration,...
                      info.fixDuration,...
                      ThisTrial.picDuration,...
                      info.maskDuration,...
                      info.probeDuration];
    
                    %WE START MEASURING THE RT AS SOON AS THE PICTURE IS PRESENTED,
                    %i.e. PAGE 2
                    ThisTrial.startRTonPage = info.startRTonPage;
                    ThisTrial.endRTonPage = info.endRTonPage;
    
                    %WE PROVIDE WHAT SHOULd BE A CORRET RESPONSE
                    %THIS CAN BE USED FOR ONLINE FEEDBACK, BUT ALSO FOR DATA
                    %ANALYSIS
                    switch iProbeType
                      case 1 % context
                        %if ThisTrial.probe == info.probeActionPictures(iAction + (iContext-1)*3) % YES
                        if info.ContextLevels(iContext) == info.ContextLevels(iProbe) % YES
                          ThisTrial.correctResponse = 114; %RIGHT ARROW
                        else % NO
                          ThisTrial.correctResponse = 115; %LEFT ARROW
                        end
    
                        % Switch / if statement to test whether
                        % current target lies in a specific context
                        % something with division by nActions
    
                      case 2 % action
                        %if ThisTrial.probe == info.probeContextPictures(iContext) % YES
                        if info.ActionLevels(iAction) == info.ActionLevels(iProbe) % YES
                          ThisTrial.correctResponse = 114; %RIGHT ARROW
                        else % NO
                          ThisTrial.correctResponse = 115; %LEFT ARROW
                        end
                    end
    
                    %NOW WE STORE THIS TRIAL DEFIBITION IN AN ARRAY OF TRIAL
                    %DEFINITIONS
                    trialCounter = trialCounter + 1;
                    TrialDefinitions(trialCounter) = ThisTrial;
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------------------
%function writeTrialDefinitions(TrialDefinitions, info, fileName)
%WRITES FACTORIAL INFO AND ARRAY OF TRIAL DEFINITIONS TO A FILE
%IF YOU DO NOT USE USER-SUPPLIED TRD-COLUMNS, THIS WORKS FOR ALL
%EXPERIMENTS AND DOES NOT NEED TO BE CHANGED
%--------------------------------------------------------------------------
function writeTrialDefinitions(TrialDefinitions, info, fileName)
  if isempty(fileName)
      fid = 1;
  else
      %THIS OPENS A TEXT FILE FOR WRITING
      fid = fopen(fileName, 'w');
      fprintf(1, 'Creating file %s ...', fileName);
  end

  %WRITE DESIGN INFO
  fprintf(fid, '%4d', info.factorialStructure );
  
  
  nTrials = length(TrialDefinitions);
  for iTrial = 1:nTrials
      nPages = length(TrialDefinitions(iTrial).pictures);
      
      %STORE TRIALDEFINITION IN FILE
      fprintf(fid, '\n'); %New line for new trial
      fprintf(fid, '%4d', TrialDefinitions(iTrial).code);
      fprintf(fid, '\t%4d', TrialDefinitions(iTrial).tOnset);
      for iPage = 1:nPages
          %TWO ENTRIES PER PAGE: 1) Picture, 2) Duration
          fprintf(fid, '\t%4d %4d', TrialDefinitions(iTrial).pictures(iPage), TrialDefinitions(iTrial).durations(iPage));
      end
      fprintf(fid, '\t%4d', TrialDefinitions(iTrial).startRTonPage);
      fprintf(fid, '\t%4d', TrialDefinitions(iTrial).endRTonPage);
      fprintf(fid, '\t%4d', TrialDefinitions(iTrial).correctResponse);
  end
  if fid > 1
      fclose(fid);
  end

  fprintf(1, '\nDONE\n'); %JUST FOR THE COMMAND WINDOW
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TrialDefinitionsNew = shuffle(TrialDefinitions)
  % Perform a trial randomization scheme

  TrialDefinitionsNew = TrialDefinitions;
  codes = [TrialDefinitions.code];
  nTrials = length(codes);

  % The following two sections are mutually exclusive. Comment out whichever
  % section you don't want to use (or comment out both and write your own!)
  %% Vanilla randomization
  %{
  % No constraints on trial order

  randCondIdx = randperm(nTrials);
  % Take the successfully shuffled permutation and permute the
  % TrialDefinitions before outputting them
  TrialDefinitionsNew = TrialDefinitionsNew(randCondIdx);
  %}

  %% Ensure that no condition is ever repeated 
  % (i.e., the code of trial n is different from the code of trial n+1)

  doRepeat = 1;
  iter = 0;
  fprintf(1, 'ITERATION: %06d', iter);
  while doRepeat
      iter = iter + 1;
      if mod(iter, 50) == 0
          fprintf(1, '\b\b\b\b\b\b%06d', iter);
      end

      % We don't want conditions to repeat themselves at all, so we 
      % use a brute-force algorithm, in which we randomize the conditions 
      % and then check that no two equal conditions are next to each other. 
      % Otherwise, we run another iteration

      % First randomize
      randCondIdx = randperm(nTrials);
      shuffledCodes = codes(randCondIdx)';
      % Check the difference between randomized codes (0's indicate that
      % similar codes are adjacent; thus, 2 adjacent zeros would be bad for
      % us)
      diffVec = [diff(shuffledCodes); NaN]; %0 indicates one repetition (streak of 2)
      diffVec2 = [diff(diffVec); NaN]; %0 indicates two repetitions  (streak of 3)
      diffVec3 = [diff(diffVec2); NaN]; %0 indicates three repetitions (streak of 4)

      if ~any(diffVec3==0)
          fprintf(1, '\n');
          doRepeat = 0;
      end
  end
  % Take the successfully shuffled permutation and permute the
  % TrialDefinitions before outputting them
  TrialDefinitionsNew = TrialDefinitionsNew(randCondIdx);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TrialDefinitionsNew = addBlankTrials(TrialDefinitions, info, code)
  %------------------------
  % Blank trial parameters
  %------------------------
  blankTrial.code = code;
  blankTrial.tOnset = 0;
  blankTrial.targetPicture = info.emptyPicture; % Whatever number refers to the blank pic
  blankTrial.maskPicture = info.emptyPicture;
  blankTrial.probe = info.emptyPicture;
  blankTrial.pictures = [info.emptyPicture];
  blankTrial.picDuration = 0; %info.blankDuration
  blankTrial.durations = [info.blankDuration];
  blankTrial.startRTonPage = 1;
  blankTrial.endRTonPage = 1;
  blankTrial.correctResponse = 0;
  %------------------------
  
  %ADD BLANK TRIALS TO START AND END
  nTrials = length(TrialDefinitions);
  TrialDefinitionsNew(1) = blankTrial;
  for iTrial = 1:nTrials
      TrialDefinitionsNew(iTrial+1) = TrialDefinitions(iTrial);
  end
  TrialDefinitionsNew(end+1) = blankTrial;
  
  %{
  % Assign trial onset time to the last blank trial, which is just the
  % duration of the previous trial + the previous trial's onset time (no
  % jitter here)
  onsetPrevious = TrialDefinitionsNew(end-1).tOnset;
  durationPreviousFrames = sum(TrialDefinitionsNew(end-1).durations);
  durationPreviousSecs = (1/info.screenFrameRate)*durationPreviousFrames;
  TrialDefinitionsNew(end).tOnset = onsetPrevious + durationPreviousSecs;

  % Last blank trial needs to last Cfg.Dur.blankTrial seconds
  % So the last blank trial does NOT have a duration of 1 frame, but rather
  % Cfg.Dur.blankTrial*Cfg.Screen.Resolution.hz
  TrialDefinitionsNew(end).durations = info.blankDuration*info.screenFrameRate;
  %}
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TrialDefinitionsNew = addEndTrials(TrialDefinitions, info, code)
  %------------------------
  % Blank trial parameters
  %------------------------
  blankTrial.code = code;
  blankTrial.tOnset = 0;
  blankTrial.targetPicture = info.emptyPicture; % Whatever number refers to the blank pic
  blankTrial.maskPicture = info.emptyPicture;
  blankTrial.probe = info.emptyPicture;
  blankTrial.pictures = [info.emptyPicture];
  blankTrial.picDuration = 0; %info.blankDuration
  blankTrial.durations = [info.blankDuration];
  blankTrial.startRTonPage = 1;
  blankTrial.endRTonPage = 1;
  blankTrial.correctResponse = 0;
  %------------------------
  
  %ADD TRIAL AT THE END
  nTrials = length(TrialDefinitions);
  
  for iTrial = 1:nTrials
    % 25.01.22, OV : removed +1 from TrialDefinitionsNew(iTrial+1)
    % because it was adding an empty line in TRD after the first (blank) trial
    % TrialDefinitionsNew(iTrial+1) = TrialDefinitions(iTrial);  
    TrialDefinitionsNew(iTrial) = TrialDefinitions(iTrial);
  end
  TrialDefinitionsNew(end+1) = blankTrial;
  
  %{
  % Assign trial onset time to the last blank trial, which is just the
  % duration of the previous trial + the previous trial's onset time (no
  % jitter here)
  onsetPrevious = TrialDefinitionsNew(end-1).tOnset;
  durationPreviousFrames = sum(TrialDefinitionsNew(end-1).durations);
  durationPreviousSecs = (1/info.screenFrameRate)*durationPreviousFrames;
  TrialDefinitionsNew(end).tOnset = onsetPrevious + durationPreviousSecs;

  % Last blank trial needs to last Cfg.Dur.blankTrial seconds
  % So the last blank trial does NOT have a duration of 1 frame, but rather
  % Cfg.Dur.blankTrial*Cfg.Screen.Resolution.hz
  TrialDefinitionsNew(end).durations = info.blankDuration*info.screenFrameRate;
  %}
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TrialDefinitionsNew = addPauseTrials(TrialDefinitions, info, interval)
  % Adds pause trials after each "interval" with the given "duration"
   
  %------------------------
  % Iterate over trials to find trial indexes for pauses
  nTrials = length(TrialDefinitions);
  interval_frames = interval * info.screenFrameRate;
  
  t_summed = 0;
  pause_idxs = [];
  for iTrial = 2:nTrials-1
    t_summed = t_summed + sum(TrialDefinitions(iTrial).durations);
    %TrialDefinitionsNew(iTrial) = TrialDefinitions(iTrial);
    
    if t_summed > interval_frames
      t_summed = 0; 
      pause_idxs(end+1) = iTrial + 1;
    end
  end
  
  %------------------------
  % Place pause trials
  TrialDefinitionsNew = TrialDefinitions;
  for idx=1:length(pause_idxs)
    % Add pauseTrial in between pre- & post-idx segments of TRD
    TrialDefinitionsNew = [TrialDefinitionsNew(1:pause_idxs(idx)-1),...
                           info.pauseTrial,...
                           TrialDefinitionsNew(pause_idxs(idx)+1:end)];
  end
    
    % Add pause trial at idx
  TrialDefinitionsNew(end+1) = TrialDefinitions(end);
  
end

%--------------------------------------------------------------------------
end % makeTRD