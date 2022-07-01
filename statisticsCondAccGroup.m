function groupAcc = statisticsCondAccGroup(save_plots)
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
l_files = dir(path_results);

groupAcc = [];
l_subjects = {};

probes_action = ["cutting" "grating" "whisking"...
                 "hole-punching" "stamping" "stapling"...
                  "hammering" "painting" "sawing"];
probes_context = ["kitchen"    "office"    "workshop"];

probes = ["cutting" "grating" "whisking"...
          "hole-punching" "stamping" "stapling"...
          "hammering" "painting" "sawing"...
          "kitchen"    "office"    "workshop"];


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

        % 4) Concatenate congruent & incongruent tables respectively
        trialsC = [trialsAC; trialsCC];
        trialsI = [trialsAI; trialsCI];


        % 5) Compute accuracies for each individual action & context probe
        % by congruence
        % for each probe [congruent] : trialsC
        accs_congruent = [];
        for i = 1:length(probes)
          % 1) find all given responses & trueKeys
          ResKeys = trialsC.ResKey(trialsC.Probe == probes(i));
          TrueKeys = trialsC.TrueKey(trialsC.Probe == probes(i));

          % 2) compute accuracy
          n_correct = sum(ResKeys == TrueKeys);
          
          acc = 100 * n_correct/length(ResKeys); % in percent
          
          % 3) dump
          accs_congruent = [accs_congruent, acc];
        end

        % for each probe [incongruent] : trialsI
        accs_incongruent = [];
        for i = 1:length(probes)
          % 1) find all given responses & trueKeys
          ResKeys = trialsI.ResKey(trialsI.Probe == probes(i));
          TrueKeys = trialsI.TrueKey(trialsI.Probe == probes(i));

          if isequal(class(ResKeys), 'cell')
            ResKeys = cell2mat(ResKeys);
          end
          
          % 2) compute accuracy
          n_correct = sum(ResKeys == TrueKeys);
          acc = 100 * n_correct/length(ResKeys); % in percent
          
          % 3) dump
          accs_incongruent = [accs_incongruent, acc];
        end

        % Concatenate congruent & incongruent -> 24-long vector
        groupAcc = [groupAcc; accs_congruent, accs_incongruent];
        
        
      end
    otherwise
      continue
  end % switch

end

%% ########################################################################
% Plots [CONGRUENT]
%% ########################################################################
if make_plots
  fh = figure;
  
  % General parameters
  ylimits = [30 109];
  xlimits = [0.5 length(probes)+0.5];
  x = 1:length(probes); % in ms

  % PLOT : CONGRUENT VS INCONGRUENT (Actions & Context) ===============================
  % Define indices for for condition category
  i1 = [1, 12];         % ACTION Probe & CONGRUENT
  i2 = [13, 24];        % CONTEXT Probe & CONGRUENT
  
  data1 = [groupAcc(:,i1(1):i1(2))];
  data2 = [groupAcc(:,i2(1):i2(2))];
  
  y1 = mean(data1);
  y2 = mean(data2);
  
  err1 = std(data1) / sqrt(length(data1));
  err2 = std(data2) / sqrt(length(data2));
  
  e1 = errorbar(x, y1, err1);
  hold on
  e2 = errorbar(x, y2, err2);
  
  e1.Marker = "x";
  e2.Marker = "o";

  xticks(x)
  xticklabels(probes) 
  xlim(xlimits)
  ylim(ylimits)
  
  lgd = legend('Congruent','Incongruent');
  lgd.Location = 'best';
  stitle = sprintf('Accuracies per Probe (N=%d)', height(groupAcc));
  title(stitle);
  xlabel('Probe')
  ylabel('Accuracy [%]')

  % SAVE PLOTS ============================================================
  if save_plots
     % define resolution figure to be saved in dpi
   res = 420;
   % recalculate figure size to be saved
   set(fh,'PaperPositionMode','manual')
   fh.PaperUnits = 'inches';
   fh.PaperPosition = [0 0 4800 2500]/res;
   print('-dpng','-r300',['plots/group_accuracy_per-probe_statistics'])
  end
end % if make_plots
end

%% ------------------------------------------------------------------------
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

function table_ = removeEmptyByColumn(table_, column)
  % 1.5) Remove trials with no response 
  for i=height(table_):-1:1
    if isequal(table_{i, column}, {[]})
      table_(i, :) = [];
    end
  end
end