%% Load ExpInfo
fname = 'result_TEST_1_1_right.mat';
ExpInfo = load(['results' filesep fname]);

%% Extract TrialInfo
TrialInfo = ExpInfo.ExpInfo.TrialInfo;
