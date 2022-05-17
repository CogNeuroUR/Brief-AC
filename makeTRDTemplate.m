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
addpath(genpath('/usr/share/psychtoolbox-3/'))
addpath(genpath('/home/ov/asf/code'));

%% CREATES A BLOCK-OF-TRIALS TEMPLATE FOR THE BRIEF-AC EXPERIMENT
% IDEA: given all design conditions, creates A block with each condition.

%--------------------------------------------------------------------------
% DESIGN & FACTORIAL PARAMETERS
%--------------------------------------------------------------------------
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
info.factorialStructure = [info.nProbeTypeLevels, info.nProbeLevels, info.nDurationLevels];

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
prefix = ['./stimuli' filesep];
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
% TIMING & HARDWARE RELATED
%--------------------------------------------------------------------------
info.screenFrameRate = 60;
info.emptyDuration = 24; %400ms
info.fixDuration = 24; % 400ms
info.maskDuration = 15; % 240 ms
info.probeDuration = 150; % 2500ms
%info.blankDuration = 60; % 1000ms
info.pauseIntervalSecs = 300; % IN SECONDS!
info.pauseInterval = info.pauseIntervalSecs * info.screenFrameRate;

%--------------------------------------------------------------------------
% RESPONSES
%--------------------------------------------------------------------------
% Record RT only at probe screen
info.startRTonPage = 5;
info.endRTonPage = 5;

%--------------------------------------------------------------------------
TrialDefinitions = makeTrialDefinitions(info);

%--------------------------------------------------------------------------
expName = 'briefAC';
trdName = sprintf('template_%dx%d_%s.trd', nBlocks, length(TrialDefinitions), expName);
%writeTrialDefinitions(TrialDefinitions, info, trdName)

%--------------------------------------------------------------------------
%% makeTRD Function
%--------------------------------------------------------------------------
function TrialDefinitions = makeTrialDefinitions(info)

  clear TrialDefinitions;
  
  trialCounter = 0;
  for iBlock = 1:nBlocks
    for iContext = 1:info.nContextLevels
      for iContextExemplar = 1:info.nContextExemplarLevels
        for iAction = 1:info.nActionLevels
          for iView = 1:info.nViewLevels
            for iActor = 1:info.nActorLevels
              %ENCODING OF FACTOR LEVELS (FACTOR LEVELS MUST START AT 0)
              %TODO: correct trial codes
              %ThisTrial.code = ASF_encode([iProbeType-1 iDuration-1], info.factorialStructure);
              ThisTrial.code = 0;
  
              ThisTrial.tOnset = 0;
  
              ThisTrial.probeType = 0;
              ThisTrial.Probe = 0;
  
              % Save "context" for further assignment of probes AND
              % "correctResponses
              ThisTrial.context = info.ContextLevels(iContext);
              ThisTrial.context_idx = iContext;
              ThisTrial.action = info.ActionLevels(iContext, iAction);
  
              %<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
              %WHICH PICTURES WILL BE SHOWN IN THIS TRIAL? 
  
              fname_target = strjoin([prefix,...
                                      sprintf("target_%s-%s_%s_%s_%s.%s",...
                                              info.ContextLevels(iContext),...
                                              info.ContextExemplarLevels(iContextExemplar), ...
                                              info.ActionLevels(iContext, iAction),...
                                              info.ViewLevels(iView), ...
                                              info.ActorLevels(iActor),...
                                              picFormat)], '');
  
              %disp(fname_target);
              fname_mask = strjoin([prefix,...
                                    sprintf("mask_%s-%s_%s_%s_%s.%s",...
                                    info.ContextLevels(iContext),...
                                    info.ContextExemplarLevels(iContextExemplar), ...
                                    info.ActionLevels(iContext, iAction),...
                                    info.ViewLevels(iView), ...
                                    info.ActorLevels(iActor),...
                                    picFormat)], '');
              %ThisTrial.targetPicture = info.catPictures(iAction + (iContext-1)*3);
              %ThisTrial.maskPicture = info.maskPictures(iAction + (iContext-1)*3);           
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
  end % Block

%--------------------------------------------------------------------------
%% Write function
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


end % makeTrialDefinitions
end % makeTRDTemplate