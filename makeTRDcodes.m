function [TrialDefinitions, info] = makeTRDcodes()
% Creates a template of TrialDefinitions composed of nBlocks x 144 trials.
%
% IDEA: FROM CODES TO CONTENTS
% Based on the factors and their levels, create trial codes, and only when ready
% and fully balanced, given the initial rules & criteria, fill it with contents,
% i.e. stimuli.
%
% RULES & CRITERIA:
% * Everything balanced : each factor&level is distributed equally within a block.
% * YES-NO correct responses are a factor in itself (Levels: Yes, No) that spans
%   across all other factors
% * Shuffling only after having all trials defined with a trial-code
% * 
% 
% OV 2022 BriefAC (ActionsInContext)

%% CREATES A BLOCK-OF-TRIALS TEMPLATE FOR THE BRIEF-AC EXPERIMENT
% IDEA: given all design conditions, creates A block with each condition.

%--------------------------------------------------------------------------
% DESIGN & FACTORIAL PARAMETERS
%--------------------------------------------------------------------------
info.CompatibilityLevels = ["compatible", "incompatible"];
info.nCompatibilityLevels = length(info.CompatibilityLevels);

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

info.ProbeTypeLevels = ["action", "context"]';
info.nProbeTypeLevels = length(info.ProbeTypeLevels);

info.CorrectResponsesLevels = ["yes", "no"];
info.nCorrectResponses = length(info.CorrectResponsesLevels);

info.ProbeLevels = [reshape(info.ActionLevels, 1, []), info.ContextLevels];
%[info.ContextLevels; info.ActionLevels];

%info.ProbeLevels = reshape(info.ProbeLevels, 1, []);
info.nProbeLevels = length(info.ProbeLevels);

info.DurationLevels = [2:1:6 8]; % nr x 16.6ms
info.nDurationLevels = length(info.DurationLevels);

% FACTORIAL STRUCTURE : IVs 
% * FULL : (Compatibility, ProbeType, Probe, Duration, CorrectResponse)
% * SIMPLE : (Compatibility, ProbeType, Duration)
info.factorialStructure = [info.nCompatibilityLevels, info.nProbeTypeLevels, ...
                           info.nCorrectResponses, info.nDurationLevels,...
                           info.nProbeLevels];
info.factorialStructureSimplified = [info.nCompatibilityLevels,...
                                     info.nProbeTypeLevels,...
                                     info.nDurationLevels];

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

%% ------------------------------------------------------------------------
% CODES : WHAT FACTORIAL CELL?
%--------------------------------------------------------------------------
TrialDefinitions = makeCodes(info);

%% Check trial codes
if ~checkCodes(TrialDefinitions, info)
  error('Trial codes and factorial info don''t match!')
else
  fprintf('Codes checked!\n')
end

%% Plot code distribution/counts
[C,~,ic] = unique([TrialDefinitions.code]);

a_counts = accumarray(ic,1);
value_counts = [C', a_counts];

bar(value_counts(:, 1), value_counts(:, 2))

%% ------------------------------------------------------------------------
% CONTENTS : WHICH PICTURES WILL BE SHOWN IN THIS TRIAL? 
%-------------------------------------------------------------------------------
% (1) Create "equi-conditional" pools of stimuli (and not only, i.e. any variable
% that stands outside the factorial structure, BUT which still has to be balanced
% over), and (2) sample uniformly from each pool for each trial code
% ==> IN THE END - a balanced trial set.

% Contents:
% * Context
% * Context exemplars
% * Action
% * Actor
% * View
% 
% contents = [info.ContextLevels, info.ContextExemplarLevels, info.ActionLevels,...
%             info.ActorLevels, info.ViewLevels];

nContents = info.nContextLevels * info.nContextExemplarLevels * info.nActionLevels * info.nActorLevels * info.nViewLevels;

nContentCompat = info.nContextLevels * info.nContextExemplarLevels * info.nActionLevels * info.nActorLevels * info.nViewLevels;
nContentIncompat = nContentCompat;
nContentTotal = nContentCompat + nContentIncompat;

% Collapseble content factors: [ContextExemplars, Actors, Views]


%% ------------------------------------------------------------------------
% Iterate over trials containing trial codes and corresponding factor levels and
% attribute content (stimulus), according to the levels.

% FACTORS:
% * Compatibility : "compatible", "incompatible"
% * Probe : ... (N=12)
% * CorrectResponse: "yes", "no"

% YES trials
for iTrial=1:length(TrialDefinitions)
  % Correct Response
  if isequal(TrialDefinitions(iTrial).CorrectResponse, "yes")
    % Probe
    if isequal(TrialDefinitions(iTrial).ProbeType, "action")
      TrialDefinitions(iTrial).tAction = TrialDefinitions(iTrial).Probe;
    else
      TrialDefinitions(iTrial).tContext = TrialDefinitions(iTrial).Probe;
    end
  end
end

% HOW TO FIX AN INCOMPATIBLE SUBSET THAT IS BALANCED ACROSS SUBJECTS?



%-------------------------------------------------------------------------------
% WRAP-UP
%-------------------------------------------------------------------------------
% Write TRD-file
expName = 'briefAC';
trdName = sprintf('template_%d_%s.trd', length(TrialDefinitions), expName);
%writeTrialDefinitions(TrialDefinitions, info, trdName) 


%===============================================================================
end % makeTRDTemplate
%% FUNCTIONS
%===============================================================================
function TrialDefinitions = makeCodes(info)

  clear TrialDefinitions;
  ctxt_idxs = 1:info.nContextLevels;

  trialCounter = 0;
  for iCompatibility = 1:info.nCompatibilityLevels
    for iProbeType = 1:info.nProbeTypeLevels
      % Define the probe subset
      % ACTION Probes
      if isequal(info.ProbeTypeLevels(iProbeType), "action")
        % bla
        probeSet = reshape(info.ActionLevels, 1, []); %info.ProbeLevels(1:9);
      else % CONTEXT Probes
        % blu
        probeSet = repmat(info.ContextLevels, 1, 3); %info.ProbeLevels(10:end);
      end 
      for iProbe = 1:length(probeSet)
        for iDuration = 1:info.nDurationLevels
          for iCorrectResponse = 1:info.nCorrectResponses
            % Factorial details
            ThisTrial.Compatibility = info.CompatibilityLevels(iCompatibility);
            ThisTrial.ProbeType = info.ProbeTypeLevels(iProbeType);
            ThisTrial.CorrectResponse = info.CorrectResponsesLevels(iCorrectResponse);
            ThisTrial.Duration = info.DurationLevels(iDuration);
            ThisTrial.Probe = probeSet(iProbe);
            
            %-----------------------------------------------------------------
            % CODES : WHAT FACTORIAL CELL?
            %-----------------------------------------------------------------
            % Define factors levels
            factor1 = find(info.CompatibilityLevels == ThisTrial.Compatibility);
            factor2 = find(info.ProbeTypeLevels == ThisTrial.ProbeType);
            factor3 = find(info.CorrectResponsesLevels == ThisTrial.CorrectResponse);
            factor4 = find(info.DurationLevels == ThisTrial.Duration);
            factor5 = find(info.ProbeLevels == ThisTrial.Probe);
            
            %ENCODING OF FACTOR LEVELS (FACTOR LEVELS MUST START AT 0)
            ThisTrial.code = ASF_encode([factor1-1, factor2-1, factor3-1,...
                                         factor4-1, factor5-1],...
                                        info.factorialStructure);
            
            %NOW WE STORE THIS TRIAL DEFIBITION IN AN ARRAY OF TRIAL
            %DEFINITIONS
            trialCounter = trialCounter + 1;
            TrialDefinitions(trialCounter) = ThisTrial;

          end % CorrectResponse
        end % Duration
      end % Probe
    end % ProbeType
  end % Compatibility
end % function

function verdict = checkCodes(TrialDefinitions, info)
% Checks codes, given the factorial structure
%% IF all good, verdict = 1, ELSE verdict = 0.
  verdict = 1;

  % Iterate over trials
  for iTrial=1:length(TrialDefinitions)
    % Decode trial code
    ThisTrial = TrialDefinitions(iTrial);
    factors = ASF_decode(ThisTrial.code, info.factorialStructure);
    Compatibility = factors(1);
    ProbeType = factors(2);
    CorrectResponse = factors(3);
    Duration = factors(4);
    Probe = factors(5);

    % Check decoded factors
    % Compatibility
    if ~isequal(ThisTrial.Compatibility, info.CompatibilityLevels(Compatibility+1))
      disp('Compatibility?!')
      verdict = 0; break;
    end

    % ProbeType
    if ~isequal(ThisTrial.ProbeType, info.ProbeTypeLevels(ProbeType+1))
      disp('ProbeType?!')
      verdict = 0; break;
    end

    % Probe
    if ~isequal(ThisTrial.Probe, info.ProbeLevels(Probe+1))
      disp('Probe?!')
      fprintf('Code: %d; Trial: %s vs Decoded: %s\n', ThisTrial.code, ThisTrial.Probe, info.ProbeLevels(Probe+1))
      verdict = 0; break;
    end

    % Duration
    if ~isequal(ThisTrial.Duration, info.DurationLevels(Duration+1))
      disp('Duration?!')
      fprintf('Code: %d; Trial: %d vs Decoded: %d\n', ThisTrial.code, ThisTrial.Duration, info.DurationLevels(Duration+1))
      verdict = 0; break;
    end

    % CorrectResponse
    if ~isequal(ThisTrial.CorrectResponse, info.CorrectResponsesLevels(CorrectResponse+1))
      disp('CorrectResponse?!')
      verdict = 0; break;
    end
  end
end


function TrialDefinitions = fillContentsTRD(TrialDefinitions, info)
% Iterate over trials containing trial codes and corresponding factor levels and
% attribute content (stimulus), according to the levels.

% FACTORS:
% * Compatibility : "compatible", "incompatible"
% * Probe : ... (N=12)
% * CorrectResponse: "yes", "no"
end


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