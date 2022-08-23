function [groupDprime, l_subjects] = extractData_meanDprime(path_results)
% Extracts mean sensitivity (d-prime) from each subject's data for each
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

        % perform analysis
        % 1) Extract trials for each probe by decoding trials' ASF code
        [trialsAC, trialsCC, trialsAI, trialsCI] = getTrialResponses(ExpInfo);

        % 2) Extract statistics: hits, false alarms and their rates
        % by PROBE TYPE & CONGRUENCY
        if isequal(ExpInfo.Cfg.probe.keyYes, {'left'})
          key_yes = 37;
          key_no = 39;
        else
          key_yes = 39;
          key_no = 37;
        end
        l_subjects = [l_subjects, fName];

        statsAC = getResponseStats(trialsAC, key_yes, key_no);
        statsAI = getResponseStats(trialsAI, key_yes, key_no);
        statsCC = getResponseStats(trialsCC, key_yes, key_no);
        statsCI = getResponseStats(trialsCI, key_yes, key_no);
        
        % 3) Compute d-prime  
        dprimeAC = dprime(statsAC);
        dprimeAI = dprime(statsAI);
        dprimeCC = dprime(statsCC);
        dprimeCI = dprime(statsCI);

        % 4) Dump into matrix
        groupDprime = [groupDprime;...
                       dprimeAC.dprime(:)', dprimeAI.dprime(:)',...
                       dprimeCC.dprime(:)', dprimeCI.dprime(:)'];


      end
    otherwise
      continue
  end % switch

end

% write data as csv file
path_outfile = [pwd, filesep, 'data_meanDprime.csv'];
% check if file exists
if isfile(path_outfile)
  warning('Overwriting already existing file at "%s".', path_outfile)
end
writematrix(groupDprime, path_outfile)
end