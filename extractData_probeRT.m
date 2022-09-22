function groupProbeRT = extractData_probeRT(path_results)
%function [rt_act_con, rt_ctx_con, rt_act_inc, rt_ctx_inc] =...
%          computeRTstatistics(ExpInfo, key_yes, key_no, make_plots, save_plots)
% Computes "Conditional" Accuracy group statistics, meaning
% 1) Accuracies per action, across participants
% 2) --//--     per context, --//--
%
% Written for BriefAC (AinC)
% Vrabie 2022
make_plots = 1;

%% Collect results from files : ExpInfo-s
% get list of files
path_results = 'results/final/';

probes_action = ["cutting" "grating" "whisking"...
                 "hole-punching" "stamping" "stapling"...
                  "hammering" "painting" "sawing"];
probes_context = ["kitchen"    "office"    "workshop"];

probes = ["cutting" "grating" "whisking"...
          "hole-punching" "stamping" "stapling"...
          "hammering" "painting" "sawing"...
          "kitchen"    "office"    "workshop"];

[groupRTCompat, groupRTIncompat, l_subjects] = extract_groupRT_conditional(path_results, probes);

%% ########################################################################
% Plots [COMPATIBLE]
%% ########################################################################
if make_plots
  fh = figure;
  
  % General parameters
  ylimits = [30 101];
  xlimits = [0.5 length(probes)+0.5];
  x = 1:length(probes); % in ms

  % PLOT : COMPATIBLE VS INCOMPATIBLE (Actions & Context) ===============================
  % Define indices for for condition category
  i1 = [1, 12];         % COMPATIBLE
  i2 = [13, 24];        % INCOMPATIBLE
  
  data1 = groupRTCompat;
  data2 = groupRTIncompat;
  
  [y1, err1] = meanCIgroup(data1);
  [y2, err2] = meanCIgroup(data2);

  y = [y1; y2]';
  err = [err1; err2]';

  b = bar(y);
  hold on
  % From https://stackoverflow.com/a/59257318
  for k = 1:size(y,2)
    % get x positions per group
    xpos = b(k).XData + b(k).XOffset;
    % draw errorbar
    errorbar(xpos, y(:,k), err(:,k), 'LineStyle', 'none', ... 
        'Color', 'k', 'LineWidth', 1);
  end

  xticks(x)
  xticklabels(probes) 
  xlim(xlimits)
  %ylim(ylimits)
  
  lgd = legend('Compatible','Incompatible');
  lgd.Location = 'best';
  stitle = sprintf('RT per Probe (N=%d)', height(groupRTCompat));
  title(stitle);
  xlabel('Probe')
  ylabel('RT [ms]')

  % SAVE PLOTS ============================================================
  if save_plots
     % define resolution figure to be saved in dpi
   res = 420;
   % recalculate figure size to be saved
   set(fh,'PaperPositionMode','manual')
   fh.PaperUnits = 'inches';
   fh.PaperPosition = [0 0 4800 2500]/res;
   print('-dpng','-r300',['plots/group_RT_per-probe_statistics'])
  end
end % if make_plots


%% Create subject info columns (ID and key-yes)
sub_ids = [];
yes_key = [];

for i=1:length(l_subjects)
  split_ = split(l_subjects(i), '_');
  [sub, key] = split_{:};
  split_ = split(sub, '-');
  [~, sub_id] = split_{:};

  if isequal(key, 'left')
    key = "L";
  elseif isequal(key, 'right')
    key = "R";
  else
    key = "";
  end

  sub_ids = [sub_ids, string(sub_id)];
  yes_key = [yes_key, key];
end

%% Colapse over compatibility (i.e. average)
groupProbeRT = groupRTCompat + groupRTIncompat;
groupProbeRT = groupProbeRT ./ 2;

%% Convert array to table
t_groupRTCompat = array2table(groupRTCompat, 'VariableNames',probes);
t_groupRTIncompat = array2table(groupRTIncompat, 'VariableNames',probes);
t_groupProbeRT = array2table(groupProbeRT, 'VariableNames',probes);


%% Add subject IDs and yes-keys as columns
t_groupRTCompat.SUB_ID = sub_ids';
t_groupRTCompat.SUB_ID = sub_ids';
t_groupProbeRT.SUB_ID = sub_ids';

t_groupRTCompat.YesKey = yes_key';
t_groupRTIncompat.YesKey = yes_key';
t_groupProbeRT.YesKey = yes_key';


%% write data as csv file
suffix = split(path_results, filesep);
suffix = suffix{end-1};
prefix = [pwd, filesep, 'results', filesep, 'data_'];
path_outfile = [prefix, suffix, '_probeRT_across-compatibility.csv'];

if isfile(path_outfile)
  warning('Overwriting already existing file at "%s".', path_outfile)
end

writetable(t_groupProbeRT, path_outfile)

%% ------------------------------------------------------------------------
end
% Functions
function table_ = convertColumn2array(table_, column)
  % Separate ResKeys from main tables
  sColumn = table_{:, column};
  % Remove ResKeys columns
  table_.(column) = [];
  % Convert separated ResKeys to array
  if isequal(class(sColumn), 'cell')
    sColumn = cell2mat(sColumn);
  end
  % Add it as new column in table
  table_{:, column} = sColumn;
end

%% ------------------------------------------------------------------------
function table_ = removeEmptyByColumn(table_, column)
  % 1.5) Remove trials with no response 
  for i=height(table_):-1:1
    if isequal(table_{i, column}, {[]})
      table_(i, :) = [];
    end
  end
end

%% ------------------------------------------------------------------------
function [groupRTCompat, groupRTIncompat, l_subjects] = extract_groupRT_conditional(...
  path_results, probes)
  l_files = dir(path_results);
  
  groupRTCompat = [];
  groupRTIncompat = [];
  l_subjects = {};
  
  % iterate over files
  fprintf('Sweeping through files ...\n');
  for i=1:length(l_files)
    path2file = [path_results, l_files(i).name];
    
    % check if of mat-extension
    [~, fName, fExt] = fileparts(l_files(i).name);
    
    switch fExt
      case '.mat'
        % ignore demo-results
        if ~contains(l_files(i).name, 'demo')
          fprintf('\tLoading : %s\n', l_files(i).name);
          clear ExpInfo;
          load(path2file, 'ExpInfo');

          l_subjects = [l_subjects, fName];

          % perform analysis
          % 1) Extract trials for each probe by decoding trials' ASF code
          [trialsAC, trialsCC, trialsAI, trialsCI] = getTrialResponses(ExpInfo);
          
          % 2) Remove trials with no response 
          trialsAC = removeEmptyByColumn(trialsAC, 'RT');
          trialsCC = removeEmptyByColumn(trialsCC, 'RT');
          trialsAI = removeEmptyByColumn(trialsAI, 'RT');
          trialsCI = removeEmptyByColumn(trialsCI, 'RT');
  
          % 3.1) Convert ResKeys to array
          trialsAC = convertColumn2array(trialsAC, 'ResKey');
          trialsCC = convertColumn2array(trialsCC, 'ResKey');
          trialsAI = convertColumn2array(trialsAI, 'ResKey');
          trialsCI = convertColumn2array(trialsCI, 'ResKey');
  
          % 3.2) Convert RT to array
          trialsAC = convertColumn2array(trialsAC, 'RT');
          trialsCC = convertColumn2array(trialsCC, 'RT');
          trialsAI = convertColumn2array(trialsAI, 'RT');
          trialsCI = convertColumn2array(trialsCI, 'RT');
  
          % 4) Concatenate compatible & incompatible arrays respectively
          trialsC = [trialsAC; trialsCC];
          trialsI = [trialsAI; trialsCI];
  
          % 5) Compute mean RT for each individual action & context probe
          % by congruence for each probe [compatible] : trialsC
          RTs_compatible = [];
          RTs_incompatible = [];
          for ip = 1:length(probes)
            % 1) extract RTs by probe
            RTs_compatible(end+1) = mean(trialsC.RT(trialsC.Probe == probes(ip)));
            RTs_incompatible(end+1) = mean(trialsI.RT(trialsI.Probe == probes(ip)));
          end
  
          % Concatenate compatible & incompatible in separate matrices
          groupRTCompat = [groupRTCompat; RTs_compatible];
          groupRTIncompat = [groupRTIncompat; RTs_incompatible];
  
        end
      otherwise
        continue
    end % switch
  end
end