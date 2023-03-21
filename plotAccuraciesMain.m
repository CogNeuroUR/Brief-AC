function plotAccuraciesMain(save_plots)
% Computes RT statistics (mean & std) per condition for each probe type and
% congruency.
%
% Written for BriefAC (AinC)
% Vrabie 2022

%% Collect results from files : ExpInfo-s
% get list of files
%path_results = 'results/final/';
path_results = 'results/tests/';
l_files = dir(path_results);

groupAcc = [];
l_subjects = {};

% iterate over files
fprintf('Sweeping through Main files ...\n');
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
        % 1) Extract trial responses
        t_trials = getExpSummary(ExpInfo);

        % 2) Collect correct & empty responses
        i_correct = 0;
        i_empty = 0;
        [n_trials, ~] = size(t_trials);
        for i=1:n_trials
          response = t_trials.ResKey(i);
          truth = t_trials.TrueKey(i);
          % convert to matrix, if cell
          if isequal(class(response), 'cell')
            response = cell2mat(response);
          end
          if isequal(class(truth), 'cell')
            truth = cell2mat(truth);
          end
          % count empty
          if isequal(response, [])
            i_empty = i_empty + 1;
          end
          % count correct
          if response == truth
              i_correct = i_correct + 1;
          end
        end

        % 3) Dump Accuracy ONLY in the matrix as rows (ONE PER SUBJECT)
        groupAcc = [groupAcc; i_correct*100/n_trials - 50, i_empty*100/n_trials];

      end
    otherwise
      continue
  end % switch

end

%% Define colors
clrs = [];
col_blue = [0, 0.4470, 0.7410];
col_yellow = [0.9290, 0.6940, 0.1250];
col_orange = [0.8500, 0.3250, 0.0980];

for i=1:height(groupAcc)
  if mod(i, 2) % if odd, make yellow, otherwise blue
    clrs = [clrs; col_yellow];
  else
    clrs = [clrs; col_blue];
  end
end

%% PLOT : stacked bars
fh = figure;

x = 1:height(groupAcc);
b = bar(x, groupAcc,'stacked', 'FaceColor','flat');
hold on
bar(NaN, 'FaceColor', col_blue);
bar(NaN, 'FaceColor',col_orange);

b(1).CData = clrs;

title('Accuracy & empty trials (main experiment)');
xlabel('Subject');
ylabel('Accuracy - chance [%]')

%ylim([20, 95])
ylim([-10, 50])

lgd = legend('Left', 'Empty', 'Right');
lgd.Location = 'northeast';

if save_plots
   print('-dpng','-r300',['plots/accuracies_main-experiment'])
end

end

%% ------------------------------------------------------------------------
function t_trial_info = getExpSummary(ExpInfo)
  % Load "info" about factorial structure
  info = getDesignParams();
  
  % Collect trial info
  trials = {};
  for i=1:length(ExpInfo.TrialInfo)
    % extract trial's probe type from last page number
    last_page = ExpInfo.TrialInfo(i).trial.pageNumber(end);
    
    % decode probeType and Probe
    code = ExpInfo.TrialInfo(i).trial.code;
    % Exclude special trials:
    if code > 999; continue; end
    [congruency, probeType, Probe] = decodeProbe(code, info);
  
  
  
    trials(end+1, :) = {ExpInfo.TrialInfo(i).trial.pageDuration(3),...
                        ExpInfo.TrialInfo(i).Response.key,...
                        ExpInfo.TrialInfo(i).trial.correctResponse,...
                        ExpInfo.TrialInfo(i).Response.RT,...
                        congruency, probeType, Probe};   
  
  end
  
  % Convert cells to tables
  varnames = {'PresTime' 'ResKey' 'TrueKey' 'RT', 'Congruency', 'ProbeType', 'Probe'};
  t_trial_info = cell2table(trials, 'VariableNames', varnames);
end
