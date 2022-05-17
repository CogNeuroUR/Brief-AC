function makeTRDMasCat(subjectID, runNum, expName)
%function makeTRDMasCat(trdName)
%
%%CREATES THE  FILE trdName FOR AN EXPERIMENT IN WHICH
%%ALL PICTURES ARE SHOWN ONCE IN THE ORDER AS THEY ARE REFERENCED
%%IN THE STD FILE
%
%%EXAMPLE CALL:
%makeTRDMasCat(104, 1, 'MasCat')

%--------------------------------------------------------------------------
%BASICS ABOUT THE DESIGN
%--------------------------------------------------------------------------
% IV1: probe: action or context
%info.probeLevels = ["action", "context"]; % action, context
info.probeLevels = ["action", "context", "action", "context", "action", "context"];
info.nProbeLevels = length(info.probeLevels);

% IV2: Target duration: 2, 3, 4, 5 and 8 frames (60Hz)
info.picDurationLevels = [2:1:5 8]; %1 to 6 frames, i.e., 16.6 to 83.3 ms
info.nPicDurationLevels = length(info.picDurationLevels);


%{
%%
% For the naming structure of normal targets:
% target_{context}_{action}.bmp
% and masked targets have the naming structure:
% target_{context}_{action}_masked.bmp
lines_std = regexp(fileread('stimdef.std'), '\n', 'split');
l_nonprobes = regexp(fileread('stimdef.std'), '[^\n]*target[^\n]*', 'match');

l_action_probes = [];
l_context_probes = [];
l_targets = [];
l_masked = []; 

for i = 1: length(l_nonprobes)
    if contains(l_nonprobes(i), 'masked')
        l_masked = [l_masked, find(contains(lines_std, l_nonprobes(i)))];
        %l_masked = [l_masked, l_nonprobes(i)];
    else
        l_targets = [l_targets, find(contains(lines_std, l_nonprobes(i)))];
    end
    
    
    % HERE STOPPED (12.08.21
    temp1 = split(l_nonprobes(1), '/');
    temp2 = split(temp1(3), '_');
        
    
    l_action_probes = [l_action_probes, find(contains(lines_std, strcat('action_', temp2(2), '_', temp2(3))))];
    l_context_probes = [l_context_probes, find(contains(lines_std, strcat('context_', temp2(2), '_', temp2(3))))];

end

% Check if have same length
assert(length(l_masked) == length(l_targets))
assert(length(l_action_probes) == length(l_action_probes))
%%
%}



% Define manually (TODO: automatize for final stimulus set)
l_action_probes = [4:2:20];
l_context_probes = [22:2:26];
l_targets = [27:2:43];
l_masked = [28:2:44]; 

info.catPictures = l_targets;
info.maskPictures = l_masked;

info.Contexts = ["kitchen", "office", "workshop"];
info.nContextLevels = length(info.Contexts);

info.nActionLevels = 3;


% repeat context probes 3 times for balancing
info.probeContextPictures = [l_context_probes, l_context_probes, l_context_probes];
%info.probeContextPictures = l_context_probes;
info.probeActionPictures = l_action_probes;

disp(['Length info.probeContextPictures: ', num2str(size(info.probeContextPictures, 2))])
disp(['Length info.probeActiontPictures: ', num2str(size(info.probeActionPictures, 2))])

info.exemplarLevels = [1]; %12 exemplars per category 
info.nExemplarLevels = length(info.exemplarLevels);
%info.soaLevels = [1, 4, 7]; %1, 4 or 7 frames, i.e., 16.6, 66.7 or 116.7 ms
%info.nSoaLevels = length(info.soaLevels);

info.emptyPicture = 1;
info.fixationPicture = 1;


info.emptyDuration = 24; %400ms
info.fixDuration = 24; % 400ms
info.maskDuration = 120; % 2000 ms
info.probeDuration = 150; % 2500ms

% Record RT only at probe screen
info.startRTonPage = 5;
info.endRTonPage = 5;


%info.factorialStructure = [info.nPrimeLevels info.nSoaLevels info.nMaskLevels]; %prime(l, n, r), soa(50, 100), mask(l, r)
info.factorialStructure = [info.nProbeLevels info.nContextLevels info.nActionLevels info.nPicDurationLevels]; %probeLevels(1, 2), picDuration (2, 3, 4, 5, 8), Contexts (1:1:3)

%HOW MANY TRIALS PER DESIGN CELL DO YOU WANT TO RUN?
%IF YOU ARE INTERESTED IN RT ONLY, >25 IS RECOMMENDED PER PARTICIPANT
%AND CONDITIONS OF INTEREST
%IF YOU ARE INTERESTED IN ERROR RATES, 100 IS RECOMMENDED PER PARTICIPANT
%YOU MAY WANT TO SPAWN THIS NUMBER OVER DIFFERENT SESSIONS IF YOU HAVE A
%BIG DESIGN
info.nReplications = 1;%4;

trdName = sprintf('SUB%02d_%02d_%s.trd', subjectID, runNum, expName);

%--------------------------------------------------------------------------
%DEFINE ALL TRIALS
%--------------------------------------------------------------------------
TrialDefinitions = makeTrialDefinitions(info);

%--------------------------------------------------------------------------
%RANDOMIZE TRIALS
%--------------------------------------------------------------------------
nTrials = length(TrialDefinitions);
%TrialDefinitions = TrialDefinitions(randperm(nTrials));

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
trialCounter = 0;
for iReplication = 1:info.nReplications
  for iExemplar = 1:info.nExemplarLevels
    for iContext = 1:info.nContextLevels
      % TODO
        % code probes in here OR create it before looping
        % online_probes = [action1_in_iContext, action2_in_iContext, action3_in_iContext,
        %                  Context1, Context2, Context3];
        onlineProbeLevels = [1 2 3 ];
        for i =1:3
          onlineProbeLevels = [onlineProbeLevels (i + (iContext-1)*3)];
        end
        
      for iAction = 1:info.nActionLevels
        for iProbe = 1:info.nProbeLevels
          for iPicDur = 1:info.nPicDurationLevels
            %if trialCounter < 200
            %     disp([iContext, iAction, iExemplar, iProbe, iPicDur, iReplication]);
            %end
            
            %ENCODING OF FACTOR LEVELS (FACTOR LEVELS MUST START AT 0)
            %TODO: correct trial codes
            ThisTrial.code = ASF_encode([iPicDur-1 iProbe-1 iExemplar-1], info.factorialStructure);
            
            ThisTrial.tOnset = 0;

            %WHICH PICTURES WILL BE SHOWN IN THIS TRIAL? 
            ThisTrial.catPicture = info.catPictures(iAction + (iContext-1)*3);
            ThisTrial.maskPicture = info.maskPictures(iAction + (iContext-1)*3);

            switch iProbe
              case 1 % action
                ThisTrial.probe = info.probeActionPictures(iAction + (iContext-1)*3);
                
                %ThisTrial.probe = info.probeActionPictures(randi([1,3]) + (iContext-1)*3);
                
                % For randomization: choose randint(1,3)
                % instead of iAction

              case 2 % context
                ThisTrial.probe = info.probeContextPictures(iContext);
                
                %{
                ThisTrial.probe = info.probeContextPictures(...
                    randi([1,...
                    length(info.probeContextPictures)]));
                %}
                
                  % For randomization: choose randint(1,3)
                % instead of iAction
            end


            %THE STRUCTURE IS ALWAYS THE SAME
            ThisTrial.pictures = [...
              info.emptyPicture,... 
              info.fixationPicture,...
              ThisTrial.catPicture,...
              ThisTrial.maskPicture,...
              ThisTrial.probe];

            %FOR HOW LONG WILL EACH PICTURE BE PRESENTED? ONLY ONE DURATION
            %IS TRIAL-DEPENDENT
            %ThisTrial.interStimulusInterval = info.soaLevels(iSoa) - info.primeDuration;
            %THE STRUCTURE IS ALWAYS THE SAME
            %                 ThisTrial.durations = [...
            %                     info.fix1Duration,...
            %                     info.primeDuration,...
            %                     ThisTrial.interStimulusInterval,...
            %                     info.maskDuration,...
            %                     info.emptyDuration];

            ThisTrial.picDuration = info.picDurationLevels(iPicDur);
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
            switch iProbe
              case 1 % action
                if ThisTrial.probe == info.probeActionPictures(iAction + (iContext-1)*3) % YES
                  ThisTrial.correctResponse = 39; %RIGHT ARROW
                else % NO
                  ThisTrial.correctResponse = 37; %LEFT ARROW
                end

                % Switch / if statement to test whether
                % current target lies in a specific context
                % something with division by nActions

              case 2 %context
                %disp([ThisTrial.probe, info.probeContextPictures(iContext)])
                if ThisTrial.probe == info.probeContextPictures(iContext) % YES
                  ThisTrial.correctResponse = 39; %RIGHT ARROW
                else % NO
                  ThisTrial.correctResponse = 37; %LEFT ARROW
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