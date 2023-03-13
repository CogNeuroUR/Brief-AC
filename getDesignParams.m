function info = getDesignParams()
%-------------------------------------------------------------------------------
% DESIGN & FACTORIAL PARAMETERS
%-------------------------------------------------------------------------------
info.CongruenceLevels = ["compatible", "incompatible"];
info.nCongruenceLevels = length(info.CongruenceLevels);

info.ContextLevels = ["kitchen", "office", "workshop"];
info.nContextLevels = length(info.ContextLevels);

info.ActionLevels = ["cutting", "grating", "whisking";...
                     "hole-punching", "stamping", "stapling";...
                     "hammering", "painting", "sawing"];
info.nActionLevels = length(info.ActionLevels);

info.ProbeTypeLevels = ["context", "action"]';
info.nProbeTypeLevels = length(info.ProbeTypeLevels);

info.ProbeLevels = [reshape(info.ActionLevels', [1 9]), info.ContextLevels];
info.nProbeLevels = length(info.ProbeLevels);

info.PresTimeLevels = [2:1:6 8]; % nr x 16.6ms
info.nPresTimeLevels = length(info.PresTimeLevels);

info.CorrectResponses = ["yes", "no"];
info.nCorrectResponses = length(info.CorrectResponses);

% FACTORIAL STRUCTURE : IVs (probeTypes, Probes, Durations)
info.factorialStructure = [info.nCongruenceLevels, info.nPresTimeLevels,...
                           info.nProbeLevels, info.nCorrectResponses];
info.factorialStructureSimplified = [...
    info.nCongruenceLevels, info.nProbeTypeLevels, info.nPresTimeLevels];

% STIMULUS LEVEL FACTORS
info.ViewLevels = ["frontal", "lateral"];
info.nViewLevels = length(info.ViewLevels);

info.ActorLevels = ["a1", "a2"];
info.nActorLevels = length(info.ActorLevels);

info.ContextExemplarLevels = ["1", "2"];
info.nContextExemplarLevels = length(info.ContextExemplarLevels);

%-------------------------------------------------------------------------------
% STIMULI PARAMETERS
%-------------------------------------------------------------------------------
info.emptyPicture = 1;
info.fixationPicture = 1;

%-------------------------------------------------------------------------------
% TIMING & HARDWARE RELATED
%-------------------------------------------------------------------------------
info.screenFrameRate = 60;
% pages
info.fixDuration = 30; % 500ms : page 1
info.emptyDuration = 12; %200ms : page 2
info.maskDuration = 15; % 240 ms : page 4
info.probeDuration = 150; % 2500ms : page 5
info.postProbeDuration = 30; % 2500ms : page 6
% pauses
info.pauseIntervalSecs = 300; % IN SECONDS!
info.pauseInterval = info.pauseIntervalSecs * info.screenFrameRate;

%-------------------------------------------------------------------------------
% RESPONSES
%-------------------------------------------------------------------------------
% Record RT only at probe screen
info.startRTonPage = 5;
info.endRTonPage = 5;

%-------------------------------------------------------------------------------
% SPECIAL TRIALS
%-------------------------------------------------------------------------------
% Add StartTrial (w/ instructions)
info.startTrial.code = 1000;
info.startTrial.pictures = info.emptyPicture;
info.startTrial.durations = 120*60; % 2min in frames 
info.startTrial.startRTonPage = 1;
info.startTrial.endRTonPage = 1;
info.startTrial.correctResponse = 0;

% TODO Add (10s) preparation (after StartTrial)
info.prepTrial = info.startTrial;
info.prepTrial.code = 1003;
info.prepTrial.durations = 10*60; % in frames

% Add Pause trials
info.pauseTrial.interval = 108; % trials between a break
info.pauseTrial = info.startTrial;
info.pauseTrial.code = 1001;
info.pauseTrial.pictures = info.emptyPicture;
info.pauseTrial.durations = 30*60; % 30s in frames 
info.pauseTrial.startRTonPage = 1;
info.pauseTrial.endRTonPage = 1;
info.pauseTrial.correctResponse = 0;

% Add Finish trial
info.endTrial = info.pauseTrial;
info.endTrial.code = 1002;

end