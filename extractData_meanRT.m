function [rtAC, rtAI, rtCC, rtCI] = extractData_meanRT(path_results)
% Extracts mean reaction time (RT) from each subject's data for each
% factorial combination.
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

groupRT = [];
l_subjects = {};
rtAC = [];
rtAI = [];
rtCC = [];
rtCI = [];

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
        if isequal(ExpInfo.Cfg.probe.keyYes, {'left'})
          key_yes = 37;
          key_no = 39;
        else
          key_yes = 39;
          key_no = 37;
        end

        % 3.1) Extract RT = f(presentation time) by probe type
        statsAC = getRTstats(trialsAC);
        statsAI = getRTstats(trialsAI);
        statsCC = getRTstats(trialsCC);
        statsCI = getRTstats(trialsCI);

        % 3.2) Take only means
        meanAC = [statsAC{:,2}];
        meanAI = [statsAI{:,2}];
        meanCC = [statsCC{:,2}];
        meanCI = [statsCI{:,2}];

        % 4) Dump RTs ONLY in the matrix as rows (ONE PER SUBJECT)
        groupRT = [groupRT; meanAC, meanAI, meanCC, meanCI];

        % 5.2) and separately by probe type & compatibility
        rtAC = [rtAC; meanAC];
        rtAI = [rtAI; meanAI];
        rtCC = [rtCC; meanCC];
        rtCI = [rtCI; meanCI];

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
t_groupRT = array2table(groupRT, 'VariableNames',vars);

%% Add subject IDs and yes-keys as columns
t_groupRT.SUB_ID = sub_ids';
t_groupRT.YesKey = yes_key';

%% write data as csv file
prefix = split(path_results, filesep);
prefix = prefix{end-1};
path_outfile = [pwd, filesep, 'results', filesep, 'data_', prefix, '_meanRT.csv'];
% check if file exists
if isfile(path_outfile)
  warning('Overwriting already existing file at "%s".', path_outfile)
end
%writematrix(groupRT, path_outfile)
writetable(t_groupRT, path_outfile)
end