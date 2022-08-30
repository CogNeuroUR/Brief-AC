function [TrialDefinitions, info] = makeTRDTemplate(nBlocks)
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
info.CongruencyLevels = ["compatible", "incompatible"];
info.nCongruencyLevels = length(info.CongruencyLevels);

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
info.nProbeLevels = length(info.ProbeLevels);

info.DurationLevels = [2:1:6 8]; % nr x 16.6ms
info.nDurationLevels = length(info.DurationLevels);

% FACTORIAL STRUCTURE : IVs (probeTypes, Probes, Durations)
info.factorialStructure = [info.nCongruencyLevels, info.nProbeTypeLevels, info.nProbeLevels, info.nDurationLevels];
info.factorialStructureSimplified = [info.nCongruencyLevels, info.nProbeTypeLevels, info.nDurationLevels];
%info.factorialStructure = [info.nCongruencyLevels, info.nProbeTypeLevels, info.nDurationLevels];

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
%prefix = ['.' filesep 'stimuli' filesep]; % platform agnostic
prefix = ['.' '\' 'stimuli' '\']; % for stimdef created on Windows
picFormat = 'png';

% Read std-file
fid = fopen('stimdef.std');

tline = fgetl(fid);
std_files = [];
while ischar(tline)
  std_files = [std_files; convertCharsToStrings(tline)];
  tline = fgetl(fid);
end
fclose(fid);

%--------------------------------------------------------------------------
% Sample 
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% TIMING & HARDWARE RELATED
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
% RESPONSES
%--------------------------------------------------------------------------
% Record RT only at probe screen
info.startRTonPage = 5;
info.endRTonPage = 5;

%--------------------------------------------------------------------------
TrialDefinitions = makeOneBlockTRD(info);

%--------------------------------------------------------------------------
TrialDefinitions = repmat(TrialDefinitions, 1, nBlocks);

%--------------------------------------------------------------------------

expName = 'briefAC';
trdName = sprintf('template_%dx%d_%s.trd', nBlocks, length(TrialDefinitions), expName);
%writeTrialDefinitions(TrialDefinitions, info, trdName) 


%--------------------------------------------------------------------------
%% makeTRD Function
%--------------------------------------------------------------------------
function TrialDefinitions = makeOneBlockTRD(info)

  clear TrialDefinitions;
  ctxt_idxs = 1:info.nContextLevels;

  trialCounter = 0;
    for iCongruency = 1:info.nCongruencyLevels
      for iContext = 1:info.nContextLevels
        for iContextExemplar = 1:info.nContextExemplarLevels
          for iAction = 1:info.nActionLevels
            for iView = 1:info.nViewLevels
              for iActor = 1:info.nActorLevels
                %ENCODING OF FACTOR LEVELS (FACTOR LEVELS MUST START AT 0)
                %TODO: correct trial codes
                %ThisTrial.code = ASF_encode([iProbeType-1 iDuration-1], info.factorialStructure);
                
                % Placeholder entries
                ThisTrial.code = 0;
                ThisTrial.tOnset = 0;
                ThisTrial.probeType = 0;
                ThisTrial.Probe = 0;
                ThisTrial.Response = 0;
                
                %<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                %WHICH PICTURES WILL BE SHOWN IN THIS TRIAL? 
                
                ThisTrial.congruency = info.CongruencyLevels(iCongruency);
                
                % COMPATIBLE TRIALS
                if isequal(info.CongruencyLevels(iCongruency), "compatible")
                  % Save "context" for further assignment of probes AND
                  % "correctResponses
                  ThisTrial.context = info.ContextLevels(iContext);
                  ThisTrial.context_idx = iContext;
                  ThisTrial.action = info.ActionLevels(iContext, iAction);
                  fname_target = strjoin([prefix,...
                        sprintf("target_%s-%s_%s_%s_%s_%s.%s",...
                                info.ContextLevels(iContext),...
                                info.ContextExemplarLevels(iContextExemplar), ...
                                info.ContextLevels(iContext),...
                                info.ActionLevels(iContext, iAction),...
                                info.ViewLevels(iView), ...
                                info.ActorLevels(iActor),...
                                picFormat)], '');
                      
                  % Save "context" for further assignment of probes AND
                  % "correctResponses
                  ThisTrial.context = info.ContextLevels(iContext);
                  ThisTrial.sourceContext_idx = iContext;
                  ThisTrial.context_idx = iContext;
                  ThisTrial.action = info.ActionLevels(iContext, iAction);
                  ThisTrial.action_idx = iAction;
                
                % INCOMPATIBLE TRIALS
                else
                  % get subset of incompatible contexts
                  inc_ctxt_idxs = ctxt_idxs(ctxt_idxs ~= iContext);
    
                  % choose random incompatible context
                  iContextInc = datasample(inc_ctxt_idxs, 1);
        
                  % choose random context exemplar
                  iContextExemplarInc = randi(info.nContextExemplarLevels);
    
                  % build file name
                  fname_target = strjoin([prefix,...
                                          sprintf("target_%s-%s_%s_%s_%s_%s.%s",...
                                                  info.ContextLevels(iContextInc),...
                                                  info.ContextExemplarLevels(iContextExemplarInc), ...
                                                  info.ContextLevels(iContext),...
                                                  info.ActionLevels(iContext, iAction),...
                                                  info.ViewLevels(iView), ...
                                                  info.ActorLevels(iActor),...
                                                  picFormat)], '');

                  % Save "context" for further assignment of probes AND
                  % "correctResponses
                  ThisTrial.context = info.ContextLevels(iContextInc);
                  ThisTrial.sourceContext_idx = iContext;
                  ThisTrial.context_idx = iContextInc;
                  ThisTrial.action = info.ActionLevels(iContext, iAction);
                  ThisTrial.action_idx = iAction;

                end
                
                temp_icontext = randi(info.nContextLevels); % for source context
                fname_mask = strjoin([prefix,...
                                      sprintf("mask_%s-%s_%s_%s_%s_%s.%s",...
                                      info.ContextLevels(randi(info.nContextLevels)),...
                                      info.ContextExemplarLevels(randi(info.nContextExemplarLevels)), ...
                                      info.ContextLevels(temp_icontext),...
                                      info.ActionLevels(temp_icontext, randi(info.nActionLevels)),...
                                      info.ViewLevels(randi(info.nViewLevels)), ...
                                      info.ActorLevels(randi(info.nActorLevels)),...
                                      picFormat)], '');
                
       
                ThisTrial.targetPicture = find(std_files==fname_target);
                ThisTrial.maskPicture = find(std_files==fname_mask);
                  
                if isempty(ThisTrial.targetPicture)
                  disp(fname_target);
                end
    
    
                %>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
                %THE STRUCTURE IS ALWAYS THE SAME
                ThisTrial.pictures = [...
                  info.fixationPicture,...
                  info.emptyPicture,...
                  ThisTrial.targetPicture,...
                  ThisTrial.maskPicture,...
                  info.emptyPicture];
    
                %FOR HOW LONG WILL EACH PICTURE BE PRESENTED?
                ThisTrial.picDuration = 8; %info.DurationLevels(iDuration);
                
                ThisTrial.durations = [...
                  info.fixDuration,...
                  info.emptyDuration,...
                  ThisTrial.picDuration,...
                  info.maskDuration,...
                  info.probeDuration];
    
                %WE START MEASURING THE RT AS SOON AS THE PICTURE IS PRESENTED,
                %i.e. PAGE 2
                ThisTrial.startRTonPage = info.startRTonPage;
                ThisTrial.endRTonPage = info.endRTonPage;
                
                % correctResponse placeholder
                ThisTrial.correctResponse = 0;
    
                %NOW WE STORE THIS TRIAL DEFIBITION IN AN ARRAY OF TRIAL
                %DEFINITIONS
                trialCounter = trialCounter + 1;
                TrialDefinitions(trialCounter) = ThisTrial;
              end % Actor
            end % View
          end % Action
        end % ContextExemplar
      end % Context
    end % Congruency


%--------------------------------------------------------------------------
%% Sample incompatible pictures
%--------------------------------------------------------------------------
  function std_incg_files = sampleIncompatiblePictures(info, picFormat)
    % Creates a random "std" list of incompatible pictures
    std_incg_files = [];
    ctxt_idxs = 1:info.nContextLevels;
    for iContext = 1:info.nContextLevels
      for iContextExemplar = 1:info.nContextExemplarLevels
        for iAction = 1:info.nActionLevels
          for iView = 1:info.nViewLevels
            for iActor = 1:info.nActorLevels
              % get subset of incompatible contexts
              inc_ctxt_idxs = ctxt_idxs(ctxt_idxs ~= iContext);

              % choose random incompatible context
              iContextInc = datasample(inc_ctxt_idxs, 1);
    
              % choose random context exemplar
              iContextExemplarInc = randi(info.nContextExemplarLevels);

              % build file name
              fname_target = strjoin([prefix,...
                                      sprintf("target_%s-%s_%s_%s_%s.%s",...
                                              info.ContextLevels(iContextInc),...
                                              info.ContextExemplarLevels(iContextExemplarInc), ...
                                              info.ActionLevels(iContext, iAction),...
                                              info.ViewLevels(iView), ...
                                              info.ActorLevels(iActor),...
                                              picFormat)], '');
              std_incg_files = [std_incg_files; fname_target];
    
            end % iActor
          end % iView
        end % iAction
      end % iContextExemplar
    end % iContext
  end % sampleIncompatiblePictures

end % makeOneBlockTRD
end % makeTRDTemplate