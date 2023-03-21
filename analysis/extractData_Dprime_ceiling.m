function [dmaxAC, dmaxAI, dmaxCC, dmaxCI] = extractData_Dprime_ceiling(path_results)
% Extracts mean sensitivity (d-prime) from each subject's data for each
% factorial combination.dmaxCC
% 
% Factorial combinations:
% Compatibility x ProbeType x Presentation Time = 2 x 2 x 6 = 24
% 
% Shape of data: (N_subjects, N_conditions) = (N_subjects, 24)
% [6 x compatible Action, 6 x incompatible Action, 6 x compatible Context,
% 6 x incompatible Context]
%
% Vrabie 2022

%% Sweep through files
l_files = dir(path_results);

dmaxAC = [];
dmaxAI = [];
dmaxCC = [];
dmaxCI = [];
groupDprime = [];
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

        % 1) Extract trials for each probe by decoding trials' ASF code
        [trialsAC, trialsCC, trialsAI, trialsCI] = getTrialResponses(ExpInfo);

        % 2) Get YesKey for this participant (either left or right % arrow)
        key_yes = ExpInfo.Cfg.Probe.keyYes;
        key_no = ExpInfo.Cfg.Probe.keyNo;

        % 3) Extract statistics: hits, false alarms and their rates
        % by PROBE TYPE & CONGRUENCY
        statsAC = getResponseStats(trialsAC, key_yes, key_no);
        statsAI = getResponseStats(trialsAI, key_yes, key_no);
        statsCC = getResponseStats(trialsCC, key_yes, key_no);
        statsCI = getResponseStats(trialsCI, key_yes, key_no);
        
        % 4) Compute d-prime  
        dpAC = dprime_ceiling(statsAC);
        dpAI = dprime_ceiling(statsAI);
        dpCC = dprime_ceiling(statsCC);
        dpCI = dprime_ceiling(statsCI);

        % 5.1) Dump all into FULL matrix
        groupDprime = [groupDprime; dpAC', dpAI', dpCC', dpCI'];

        % 5.2) and separately by probe type & compatibility
        dmaxAC = [dmaxAC; dpAC'];
        dmaxAI = [dmaxAI; dpAI'];
        dmaxCC = [dmaxCC; dpCC'];
        dmaxCI = [dmaxCI; dpCI'];
      end
    otherwise
      continue
  end % switch

end

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

%% Convert array to table
probes = ["AC", "AI", "CC", "CI"];
times = [2:6 8];
vars = {};

for iP=1:length(probes)
  for iT=1:length(times)
    vars = [vars; sprintf('%s_%d', probes(iP), times(iT))];
  end
end
t_groupDprime = array2table(groupDprime, 'VariableNames',vars);

%% Add subject IDs and yes-keys as columns
t_groupDprime.SUB_ID = sub_ids';
t_groupDprime.YesKey = yes_key';

%% write data as csv file
prefix = split(path_results, filesep);
prefix = prefix{end-1};
path_outfile = [pwd, filesep, 'results', filesep, 'data_', prefix, '_Dprime_ceiling.csv'];
% check if file exists
if isfile(path_outfile)
  warning('Overwriting already existing file at "%s".', path_outfile)
end
%writematrix(groupDprime, path_outfile)
writetable(t_groupDprime, path_outfile)
end