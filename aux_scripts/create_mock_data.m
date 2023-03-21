%% Load an ExpInfo
load('results/final/SUB-01_left.mat')

%% Make all given responses equal to the correct response
% Iterate over trials
for i=1:length(ExpInfo.TrialInfo)
  % extract trial's probe type from last page number
  ExpInfo.TrialInfo(i).Response.key = ExpInfo.TrialInfo(i).trial.correctResponse;

  % check if Response is equal to correct one
  if ~isequal(ExpInfo.TrialInfo(i).trial.correctResponse,...
              ExpInfo.TrialInfo(i).Response.key)
    error('Trial %d has different response than true one!', i);
  end
end

%% Save mock participant
save('results/mock_data.mat', 'ExpInfo');

%% ########################################################################
% RANDOM MOCK DATA
%% Make all given responses equal to the correct response
keys = [37, 39];
% Iterate over trials
for i=1:length(ExpInfo.TrialInfo)
  % extract trial's probe type from last page number
  ExpInfo.TrialInfo(i).Response.key = keys(randsample(2, 1));
end

%% Save mock participant
save('results/mock/mock_random_data.mat', 'ExpInfo');