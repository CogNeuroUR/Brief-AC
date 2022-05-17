% Creates all possible factorial cells, given the variables' levels

%% Initialize variables
info.Contexts = ["kitchen", "office", "workshop"];
info.nContextLevels = length(info.Contexts);

info.Actions = ["chopping-vegetables", "cutting-bread", "peeling-potatoes";...
                "hole-punching", "stamping", "writing";...
                "rasping-wood", "sawing-wood", "using-wrench"];
info.nActionLevels = length(info.Actions);
  
info.ProbeTypes = ["context", "action"]';
info.nProbeTypeLevels = length(info.ProbeTypes);

info.Probes = ["C1", "C2", "C3";...
               "A1", "A2", "A3"];
info.nProbeLevels = [length(info.Probes(1, :)), length(info.Probes(2, :))];

info.Durations = [2:1:5 8];
info.nDurationLevels = length(info.Durations);

pictFormat = 'jpeg';
prefix = ['.', filesep, 'stimuli' filesep];

%% Collect filenames from STD file
fid = fopen('stimdef.std');

tline = fgetl(fid);
std_files = [];
while ischar(tline)
  %disp(tline)
  std_files = [std_files; convertCharsToStrings(tline)];
  tline = fgetl(fid);
end
fclose(fid);

%% Extract directly pageNumber
combinations = ["Context", "Action", "Probe", "Duration", "PagNr_Target", "PagNr_Mask", "PagNr_Probe"];

for iContext = 1:info.nContextLevels
  for iAction = 1:info.nActionLevels
    for iProbeType = 1:info.nProbeTypeLevels
      for iProbe = 1:info.nProbeLevels(iProbeType)
        for iDuration = 1:info.nDurationLevels
          % Define filenames of the target and mask, which are independent
          % of the Probe screen
          fname_target = strjoin([prefix,...
                        sprintf("target_%s_%s.%s",...
                                info.Contexts(iContext),...
                                info.Actions(iContext, iAction),...
                                pictFormat)], '');
          fname_mask = strjoin([prefix,...
                               sprintf("mask_%s_%s.%s",...
                               info.Contexts(iContext),...
                               info.Actions(iContext, iAction),...
                               pictFormat)], '');
                                 
          switch iProbeType
            case 1 % context
              fname_probe = strjoin([prefix,...
                                    sprintf("probe_context-%s_yes-left.%s",...
                                            info.Contexts(iProbe),...
                                            pictFormat)], '');
              combinations = [combinations;
                              info.Contexts(iContext),...
                              info.Actions(iContext, iAction),...
                              sprintf("context-%s",info.Contexts(iProbe)),...
                              (iDuration * 100)/6,...
                              find(std_files==fname_target),...
                              find(std_files==fname_mask),...
                              find(std_files==fname_probe)];
                              

            case 2 % action
              fname_probe = strjoin([prefix,...
                                    sprintf("probe_action_%s_%s_yes-left.%s",...
                                            info.Contexts(iContext),...
                                            info.Actions(iContext, iProbe),...
                                            pictFormat)], '');
              combinations = [combinations;
                              info.Contexts(iContext),...
                              info.Actions(iContext,iAction),...
                              sprintf("action_%s_%s",info.Contexts(iContext), info.Actions(iContext, iProbe)),...
                              (iDuration * 100)/6,...
                              find(std_files==fname_target),...
                              find(std_files==fname_mask),...
                              find(std_files==fname_probe)];
          end
        end
      end
    end
  end
end

%% Compute combinations, i.e. factorial cells

combinations = ["Context", "Action", "Probe", "Duration", "Pic_Target", "Pic_Mask", "Pic_Probe"];

for iContext = 1:info.nContextLevels
  for iAction = 1:info.nActionLevels
    for iProbeType = 1:info.nProbeTypeLevels
      for iProbe = 1:info.nProbeLevels(iProbeType)
        for iDuration = 1:info.nDurationLevels
        
          switch iProbeType
            case 1 % context
              combinations = [combinations;
                              info.Contexts(iContext),...
                              info.Actions(iContext, iAction),...
                              sprintf("context-%s",info.Contexts(iProbe)), (iDuration * 100)/6,...
                              sprintf("target_%s_%s.%s",info.Contexts(iContext),info.Actions(iContext, iAction),pictFormat),...
                              sprintf("mask_%s_%s.%s",info.Contexts(iContext),info.Actions(iContext, iAction),pictFormat),...
                              sprintf("probe_context-%s_yes-left.%s",info.Contexts(iProbe),pictFormat),
                              
                              ];
              %{
              combinations = [combinations;...
                  sprintf("%s : %s \t %s?  %fms", info.Contexts(iContext),...
                  info.Actions(iContext, iAction),...
                  info.Contexts(iProbe)), (iDuration * 100)/6];
              %}
            case 2 % action
              combinations = [combinations;
                              info.Contexts(iContext),...
                              info.Actions(iContext,iAction),...
                              sprintf("action_%s_%s",info.Contexts(iProbe), info.Actions(iContext, iProbe)),...
                              (iDuration * 100)/6,...
                              sprintf("target_%s_%s.%s",info.Contexts(iContext),info.Actions(iContext, iAction),pictFormat),...
                              sprintf("mask_%s_%s.%s",info.Contexts(iContext),info.Actions(iContext, iAction),pictFormat),...
                              sprintf("probe_action_%s_%s_yes-left.%s",info.Contexts(iProbe),info.Actions(iContext, iAction),pictFormat)
                              ];
              %{
              combinations = [combinations; sprintf("%s : %s \t %s?  %fms",...
                              info.Contexts(iContext), info.Actions(iContext,iAction),...
                              info.Actions(iContext, iProbe)), (iDuration * 100)/6];
              %}
              
          end
        end
      end
    end
  end
end



%% Find filename in STD based on element in combinations' list
pictures = [];
for i=1:length(combinations)
  sContext = combinations(i, 1);
  sAction = combinations(i, 2);
  sProbe = combinations(i, 3);
  
  %target = ['.' filesep "stimuli" filesep 'target_' sContext '_' sAction];
  %probe = ['.' filesep "stimuli" filesep 'probe_' sProbe '_yes-right'];
  
  target = sprintf(".%sstimuli%starget_%s_%s", filesep, filesep, sContext,sAction);
  probe = sprintf(".%sstimuli%sprobe_%s_yes-right", filesep, filesep, sProbe);
  
  pictures = [pictures; target, probe];
end

%% Test: extract full filename based on partial title from "pictures"
for i=1:length(pictures)
  x = dir(sprintf("%s*", pictures(i,1)));
  disp(x.name)
end


%% Test: extract full filename out of stimulus definition file
fid = fopen('stimdef.std');

tline = fgetl(fid);
std_files = [];
while ischar(tline)
  %disp(tline)
  std_files = [std_files; convertCharsToStrings(tline)];
  tline = fgetl(fid);
end
fclose(fid);

disp(tline)