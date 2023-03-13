function [TRD_yin, TRD_yang, info] = makeTRDTemplate_v2()
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

%% CREATES A BLOCK-OF-TRIALS TEMPLATE FOR THE BRIEF-AC EXPERIMENT
% IDEA: given all design conditions, creates A block with each condition.

%--------------------------------------------------------------------------
% DESIGN & FACTORIAL PARAMETERS
%--------------------------------------------------------------------------
info = getDesignParams();

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