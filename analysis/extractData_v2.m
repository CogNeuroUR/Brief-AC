function data = extractData_v2()
% Extract each participant's data and stack it in a table.
%
% Written for BriefAC-v2 (AinC)
% Vrabie 2023

%% Collect results from files : ExpInfo-s
% get list of files
path_results = 'data/raw/'; % here
l_files = dir(path_results);

data = {};
data_demo = {};

% iterate over files
fprintf('Sweeping through files ...\n');
for i=1:length(l_files)
    path2file = [l_files(i).folder filesep l_files(i).name];
    
    % check if of mat-extension
    [fPath, fName, fExt] = fileparts(l_files(i).name);
    
    switch fExt
        case '.mat'
            fprintf('\tLoading : %s\n', l_files(i).name);
            clear ExpInfo;
            load(path2file, 'ExpInfo');
            % Main data
            if ~contains(l_files(i).name, 'demo')
                % Extract data & concatenate
                data = [data; getTrialResponses_v2(ExpInfo)];
            end
            % Demo
            if contains(l_files(i).name, 'demo')
                temp = getTrialResponses_v2(ExpInfo);
                % Extract subID from mat file's name
                % (no such info in ExpInfo, since same demos across subjects)
                finfo = split(l_files(i).name, '_'); % SUB-XX_keyYes -> [SUB-XX, keyYes]
                subID = split(finfo{1}, '-'); % [SUB] [XX]
                subID = subID{2};
                temp(:, 1) = repmat({subID}, length(temp(:,1)), 1);
                data_demo = [data_demo; temp];
            end
    end
end

%% Convert cells to tables
varnames = {'subID', 'keyYes', 'trialNr', 'picID', 'Context', 'Action',...
            'Compatibility', 'PT', 'ProbeType', 'Probe', 'CorrectResponse',...
            'Response', 'RT'};

tData = cell2table(data, 'VariableNames', varnames);
tData_demo = cell2table(data_demo, 'VariableNames', varnames);

%% Save to csv
writetable(tData, 'data/processed/trials_BriefAC-v2.csv')
writetable(tData_demo, 'data/processed/trials_BriefAC-v2_demo.csv')

end