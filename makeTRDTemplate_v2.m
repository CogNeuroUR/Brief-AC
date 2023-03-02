function [TrialDefinitions, info] = makeTRDTemplate_v2(nBlocks)
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

info.ProbeLevels = [info.ContextLevels;...
                    info.ActionLevels];

info.ProbeLevels = reshape(info.ProbeLevels, 1, []);
info.nProbeLevels = length(info.ProbeLevels);

info.PresTimeLevels = [2:1:6 8]; % nr x 16.6ms
info.nPresTimeLevels = length(info.PresTimeLevels);

info.CorrectResponses = ["yes", "no"];
info.nCorrectResponses = length(info.CorrectResponses);

% FACTORIAL STRUCTURE : IVs (probeTypes, Probes, Durations)
info.factorialStructure = [info.nCongruenceLevels, info.nProbeTypeLevels, ...
                           info.nPresTimeLevels, info.nCorrectResponses];
info.factorialStructureFull = [...
    info.nCongruenceLevels, info.nProbeTypeLevels, info.nPresTimeLevels,...
    info.nCorrectResponses, info.nProbeLevels, ...
    info.nContextLevels, info.nActionLevels];

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
%% TIMING & HARDWARE RELATED
%--------------------------------------------------------------------------
info.screenFrameRate = 60;
% pages
info.fixDuration = 30; % 500ms : page 1
info.emptyDuration = 12; %200ms : page 2
info.maskDuration = 15; % 240 ms : page 4
info.probeDuration = 150; % 2500ms : page 4
% pauses
info.pauseIntervalSecs = 300; % IN SECONDS!
info.pauseInterval = info.pauseIntervalSecs * info.screenFrameRate;

%--------------------------------------------------------------------------
%% RESPONSES
%--------------------------------------------------------------------------
% Record RT only at probe screen
info.startRTonPage = 5;
info.endRTonPage = 5;

%--------------------------------------------------------------------------
TrialDefinitions = makeOneBlockTRD(info);

%% --------------------------------------------------------------------------
TrialDefinitions = repmat(TrialDefinitions, 1, nBlocks);

%--------------------------------------------------------------------------
end % makeTRDTemplate
%--------------------------------------------------------------------------
%% makeTRD Function
%--------------------------------------------------------------------------
function TrialDefinitions = makeOneBlockTRD(info)

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
                        ThisTrial.tOnset = 0;
                        ThisTrial.Compatibility = info.CongruenceLevels(iCongruence);
                        
                        %>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                        % COMPATIBILITY
                        % 1) COMPATIBLE TRIALS
                        if isequal(info.CongruenceLevels(iCongruence), "compatible")
                            % Save "context" for further assignment of probes AND
                            % "correctResponses
                            ThisTrial.Context = info.ContextLevels(iContext);
                            ThisTrial.idxSourceContext = iContext;
                            ThisTrial.idxContext = iContext;
                            ThisTrial.Action = info.ActionLevels(iContext,...
                                                                 iAction);
                            ThisTrial.idxAction = iAction; 
                            
                        % 2) INCOMPATIBLE TRIALS
                        % TODO: possible to make it (context) not random?
                        else
                            % get subset of incompatible contexts
                            inc_ctxt_idxs = idxs_ctxt(idxs_ctxt ~= iContext);

                            % choose random incompatible context
                            iContextInc = datasample(inc_ctxt_idxs, 1);

                            % Save "context" for further assignment of probes AND
                            % "correctResponses
                            ThisTrial.Context = info.ContextLevels(iContextInc);
                            ThisTrial.idxSourceContext = iContext;
                            ThisTrial.idxContext = iContextInc;
                            ThisTrial.Action = info.ActionLevels(iContext,...
                                                                 iAction);
                            ThisTrial.idxAction = iAction;
                        end

                        %>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                        % PROBE & RESPONSE
                        ThisTrial.probeType = info.ProbeTypeLevels(iProbeType);
                        ThisTrial.correctResponse = info.CorrectResponses(iResponse);
                        
                        % YES
                        if iResponse == 1
                            % CONTEXT
                            if iProbeType == 1
                                ThisTrial.Probe = ThisTrial.Context;
                            % ACTION
                            else
                                ThisTrial.Probe = ThisTrial.Action;
                            end
                        % NO
                        else
                            % CONTEXT
                            if iProbeType == 1
                                % get subset of contexts different than the current one
                                temp = idxs_ctxt(idxs_ctxt ~= ThisTrial.idxContext);
                                % asign random context from the subset
                                ThisTrial.Probe = info.ContextLevels(...
                                    datasample(temp, 1));
                            % ACTION
                            else
                                % get subset of actions different than the
                                % current one (within context)
                                temp = idxs_actn(idxs_actn ~= ThisTrial.idxAction);
                                % assign specific action probe from the subset
                                ThisTrial.Probe = info.ActionLevels(...
                                    ThisTrial.idxContext, datasample(temp, 1));
                            end
                        end
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
                            info.emptyPicture];

                        %>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                        % DURATIONS:
                        % FOR HOW LONG WILL EACH PICTURE BE PRESENTED?
                        ThisTrial.picDuration = info.PresTimeLevels(iPresTime);
                        
                        ThisTrial.durations = [...
                            info.fixDuration,...
                            info.emptyDuration,...
                            ThisTrial.picDuration,...
                            info.maskDuration,...
                            info.probeDuration];

                        %>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                        %ENCODING OF FACTOR LEVELS (FACTOR LEVELS MUST START AT 0)
                        ThisTrial.code = ASF_encode(...
                            [iCongruence-1, iProbeType-1, iPresTime-1, iResponse-1],...
                            info.factorialStructure);
                        % For inspection purposes
                        ThisTrial.codeFull = ASF_encode(...
                            [iCongruence-1, iProbeType-1, iPresTime-1, iResponse-1,...
                             find(info.ProbeLevels == ThisTrial.Probe),...
                             iContext-1, iAction-1]);

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

end % makeOneBlockTRD