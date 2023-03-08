function [TRD_yin, TRD_yang, info] = makeTRDTemplate_v2()
% Creates a template of TrialDefinitions made out of 72 trials, each
% corresponding to a unique target picture in the stimulus set.
% Additionally to pictures it will contain presentation times and other
% default TRD columns.
% It is designed to be kept constant and make changes (for individual subjects)
% further by filling in: trial codes, probes, etc. and for subsequent trial
% shuffling (and not only).
% 
% OV 11.05.22 BriefAC (ActionsInContext)

%% CREATES A BLOCK-OF-TRIALS TEMPLATE FOR THE BRIEF-AC EXPERIMENT
% IDEA: given all design conditions, creates A block with each condition.

%--------------------------------------------------------------------------
% DESIGN & FACTORIAL PARAMETERS
%--------------------------------------------------------------------------
%{
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
info.factorialStructureSlim = [info.nCongruenceLevels, info.nProbeTypeLevels, ...
                           info.nPresTimeLevels, info.nCorrectResponses];
info.factorialStructureFull = [...
    info.nCongruenceLevels, info.nPresTimeLevels,...
    info.nCorrectResponses, info.nProbeLevels, ...
    info.nContextLevels, info.nActionLevels];

info.factorialStructure = [...
    info.nCongruenceLevels, info.nPresTimeLevels,...
    info.nProbeLevels, info.nCorrectResponses];

% STIMULUS LEVEL FACTORS
info.ViewLevels = ["frontal", "lateral"];
info.nViewLevels = length(info.ViewLevels);

info.ActorLevels = ["a1", "a2"];
info.nActorLevels = length(info.ActorLevels);

info.ContextExemplarLevels = ["1", "2"];
info.nContextExemplarLevels = length(info.ContextExemplarLevels);
%}
info = getFactorialStructure();

%HOW MANY TRIALS PER DESIGN CELL DO YOU WANT TO RUN?
%IF YOU ARE INTERESTED IN RT ONLY, >25 IS RECOMMENDED PER PARTICIPANT
%AND CONDITIONS OF INTEREST
%IF YOU ARE INTERESTED IN ERROR RATES, 100 IS RECOMMENDED PER PARTICIPANT
%YOU MAY WANT TO SPAWN THIS NUMBER OVER DIFFERENT SESSIONS IF YOU HAVE A
%BIG DESIGN

%--------------------------------------------------------------------------
% STIMULI PARAMETERS
%--------------------------------------------------------------------------
info.emptyPicture = 1;
info.fixationPicture = 1;

%--------------------------------------------------------------------------
% TIMING & HARDWARE RELATED
%--------------------------------------------------------------------------
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

%--------------------------------------------------------------------------
% RESPONSES
%--------------------------------------------------------------------------
% Record RT only at probe screen
info.startRTonPage = 5;
info.endRTonPage = 5;

%% ------------------------------------------------------------------------
TrialDefinitions = makeTRDblock(info);

%% ------------------------------------------------------------------------
%% Make TRD-clone with counter-balanced INCOMPATIBLE CONTEXT
TRD_yin = TrialDefinitions;
TRD_yang = TrialDefinitions;

% Go through incompatible trials and replace "context" with the other
for iTrial=1:length(TRD_yang)
    % Skip compatible trials
    if isequal(TRD_yang(iTrial).Compatibility, "compatible")
        continue
    end

    % Find other incompatible context
    other = info.ContextLevels(info.ContextLevels ~= TRD_yang(iTrial).Context & ...
                               info.ContextLevels ~= TRD_yang(iTrial).srcContext);
    TRD_yang(iTrial).Context = other;
end

%% ------------------------------------------------------------------------
%% Write to files
save('TRD_yin.mat', 'TRD_yin')
save('TRD_yang.mat', 'TRD_yang')

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

for iCongruence = 1:info.nCongruenceLevels
    for iProbeType = 1:info.nProbeTypeLevels
        for iPresTime = 1:info.nPresTimeLevels
            for iResponse = 1:info.nCorrectResponses      
                for iContext = 1:info.nContextLevels
                    for iAction = 1:info.nActionLevels                        
                        %>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                        % COMPATIBILITY
                        ThisTrial.Compatibility = info.CongruenceLevels(iCongruence);

                        % 1) COMPATIBLE TRIALS
                        %   Context := source context
                        %   Action  := context-compatible action
                        if isequal(ThisTrial.Compatibility, "compatible")
                            % Save "context" for further assignment of probes AND
                            % "correctResponses
                            ThisTrial.Context = info.ContextLevels(iContext);
                            ThisTrial.idxContext = iContext;
                            ThisTrial.srcContext = ThisTrial.Context;
                            ThisTrial.Action = info.ActionLevels(iContext,...
                                                                 iAction);
                            ThisTrial.idxAction = iAction; 
                            
                        % 2) INCOMPATIBLE TRIALS
                        %   Context := action-incompatible context
                        %   Action  := action
                        else
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
                        ThisTrial.probeType = info.ProbeTypeLevels(iProbeType);
                        ThisTrial.correctResponse = info.CorrectResponses(iResponse);
                        
                        % Probes will be assigned in the next step (fillTRD_v2),
                        % randomly for each subject

                        %>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                        % PICTURES: Placeholders
                        ThisTrial.targetPicture = 0;
                        ThisTrial.maskPicture = 0;

                        %THE STRUCTURE IS ALWAYS THE SAME
                        ThisTrial.pictures = [...
                            info.fixationPicture,...
                            info.emptyPicture,...
                            ThisTrial.targetPicture,...
                            ThisTrial.maskPicture,...
                            info.emptyPicture,...
                            info.emptyPicture];

                        %>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                        % DURATIONS:
                        % FOR HOW LONG WILL EACH PICTURE BE PRESENTED?
                        ThisTrial.tOnset = 0;
                        ThisTrial.picDuration = info.PresTimeLevels(iPresTime);
                        ThisTrial.durations = [...
                            info.fixDuration,...
                            info.emptyDuration,...
                            ThisTrial.picDuration,...
                            info.maskDuration,...
                            info.probeDuration,...
                            info.postProbeDuration];

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
            end % Congruence
        end % Probe Type
    end % Correct Response
end % PresTime

% Remove no-longer required columns:
%auxFields = {'idxContext', 'idxAction'};
%TrialDefinitions = rmfield(TrialDefinitions, auxFields);

end % makeTRDblock