%% DESIGN PARAMETERS
info.ContextLevels = ["kitchen", "office", "workshop"];
info.nContextLevels = length(info.ContextLevels);

info.ContextExemplarLevels = ["1", "2"];
info.nContextExemplarLevels = length(info.ContextExemplarLevels);

info.ActionLevels = ["cutting", "grating", "whisking";...
                     "hole-punching", "stamping", "stapling";...
                     "hammering", "painting", "sawing"];
info.nActionLevels = length(info.ActionLevels);
info.ViewLevels = ["frontal", "lateral"];
info.nViewLevels = length(info.ViewLevels);

info.ActorLevels = ["a1", "a2"];
info.nActorLevels = length(info.ActorLevels);

info.ProbeTypeLevels = ["context", "action"]';
info.nProbeTypeLevels = length(info.ProbeTypeLevels);

info.ProbeLevels = [info.ContextLevels;...
                    info.ActionLevels];

info.ProbeLevels = reshape(info.ProbeLevels, 1, []);
%info.nProbeLevels = [length(info.ProbeLevels(1, :)),...
%                     length(info.ProbeLevels(2, :))];
info.nProbeLevels = length(info.ProbeLevels);

info.DurationLevels = [2:1:6 8];
info.nDurationLevels = length(info.DurationLevels);
info.factorialStructure = [info.nProbeTypeLevels, info.nProbeLevels, info.nDurationLevels];

%% Load template
TRD = makeTRDTemplate('test');

%% Extract number of trials
nTrials = length(TRD);

%% Atribute half of them to CONTEXT-probes
% and the other half to ACTION-probes
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
    count_ctx = count_ctx + 1;
  % Action probes (within context)
  elseif isequal(TRD(iTrial).probeType, 'action')
    % assign specific action probe
    % Increment action cycle (within context)
    if count_act(TRD(iTrial).context_idx) > 3
      count_act(TRD(iTrial).context_idx) = 1;
    end
    TRD(iTrial).Probe = info.ActionLevels(TRD(iTrial).context_idx,count_act(TRD(iTrial).context_idx));
    count_act(TRD(iTrial).context_idx) = count_act(TRD(iTrial).context_idx) + 1;
  end
end

%% Shuffle TOGETHER the rows of the "probeType" and "Probe" columns in TRD
%idx = randperm(length(TRD));
%[TRD(:).probeType] = TRD(idx).probeType;
%[TRD(:).Probe] = TRD(idx).Probe;

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

%% Write to .trd file
%info.factorialStructure = [length(info.ProbeTypeLevels) length(info.DurationLevels)];
writeTrialDefinitions(TRD, info, 'briefac_trials_assigned.trd')

%% Create ASF codes

for iTrial = 1:length(TRD)
  iProbe = find(info.ProbeTypeLevels == TRD(iTrial).probeType);
  iDuration = find(info.DurationLevels == TRD(iTrial).picDuration);
  code = ASF_encode([iProbe-1 iDuration-1], info.factorialStructure);
  fprintf('Code : %d, Probe : %d, Duration : %d\n', code, iProbe, iDuration);
  TRD(iTrial).code = code;
end

%% [Experimental] Create ASF codes accounting for Actions and Contexts

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

%% Decode : SANITY CHECK
for iTrial = 1:length(TRD)
  % Decode factors from code
  factors = ASF_decode(TRD(iTrial).code, info.factorialStructure);
  t = factors(1);   % probe type
  p = factors(2);   % probe
  d = factors(3);   % duration
  
  % Check ProbeType : from code vs from TRD
  if ~isequal(info.ProbeTypeLevels(t+1), TRD(iTrial).probeType)
    fprintf('ProbeType code is wrong! From code: \"%s\" vs from TRD: \"%s\"\n',...
      info.ProbeTypeLevels(t+1), TRD(iTrial).probeType)
  % Check Probe : from code vs from TRD
  elseif ~isequal(info.ProbeLevels(p+1), TRD(iTrial).Probe)
    fprintf('Probe code is wrong! From code: \"%s\" vs from TRD: \"%s\"\n',...
      info.ProbeLevels(p+1), TRD(iTrial).Probe)
  % Check Duration : from code vs from TRD
  elseif ~isequal(info.DurationLevels(d+1), TRD(iTrial).picDuration)
    fprintf('Duration code is wrong! From code: \"%d\" vs from TRD: \"%d\"\n',...
      info.DurationLevels(d+1), TRD(iTrial).picDuration)
  end
end



%% ?
writeTrialDefinitions(TRD, info, 'briefac_trials_assigned.trd')


%%
code = 6;
[probeType, Probe] = decodeProbe(code, info.factorialStructure, info.ProbeTypeLevels, info.ProbeLevels);
fprintf('(%d) %s : %s\n', code, upper(probeType), upper(Probe));


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
% Write function
function writeTrialDefinitions(TRD, info, fileName)
  if isempty(fileName)
      fid = 1;
  else
      %THIS OPENS A TEXT FILE FOR WRITING
      fid = fopen(fileName, 'w');
      fprintf(1, 'Creating file %s ...', fileName);
  end

  %WRITE DESIGN INFO
  fprintf(fid, '%4d', info.factorialStructure );
  
  
  nTrials = length(TRD);
  for iTrial = 1:nTrials
      nPages = length(TRD(iTrial).pictures);
      
      %STORE TRIALDEFINITION IN FILE
      fprintf(fid, '\n'); %New line for new trial
      fprintf(fid, '%4d', TRD(iTrial).code);
      fprintf(fid, '\t%4d', TRD(iTrial).tOnset);
      for iPage = 1:nPages
          %TWO ENTRIES PER PAGE: 1) Picture, 2) Duration
          fprintf(fid, '\t%4d %4d', TRD(iTrial).pictures(iPage), TRD(iTrial).durations(iPage));
      end
      fprintf(fid, '\t%4d', TRD(iTrial).startRTonPage);
      fprintf(fid, '\t%4d', TRD(iTrial).endRTonPage);
      fprintf(fid, '\t%4d', TRD(iTrial).correctResponse);
  end
  if fid > 1
      fclose(fid);
  end

  fprintf(1, '\nDONE\n'); %JUST FOR THE COMMAND WINDOW
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