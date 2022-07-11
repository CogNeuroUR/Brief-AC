%% Load ExpInfo
path2file = 'results/final/SUB-01_left.mat';
load(path2file, 'ExpInfo');

%%
probes_action = ["cutting" "grating" "whisking"...
                 "hole-punching" "stamping" "stapling"...
                  "hammering" "painting" "sawing"];
probes_context = ["kitchen"    "office"    "workshop"];

%%
%std_fids = read_std();

%% Extract responses per action & per context
[trialsAC, trialsCC, trialsAI, trialsCI] = getTrialResponses(ExpInfo);

%% Remove "NO" RESPONSES to probes
if isequal(ExpInfo.Cfg.probe.keyYes, {'left'})
  key_yes = 37;
  key_no = 39;
else
  key_yes = 39;
  key_no = 37;
end

trialsAC = removeRowByKey(trialsAC, key_no);
trialsCC = removeRowByKey(trialsCC, key_no);
trialsAI = removeRowByKey(trialsAI, key_no);
trialsCI = removeRowByKey(trialsCI, key_no);

%% Build the "YES" matrix: ACTIONS
% Targets : rows
% Probes  : columns

Trials = trialsAC;

% Initialize empty matrix : (n_targets; n_probes) {n_targets = n_probes}
n_probes = length(probes_action);
% TODO : assert

c_mat = zeros(n_probes, n_probes);

% Iterate over targets
for i=1:n_probes
  target = probes_action(i);
  rows = Trials(Trials.Target_Action == target, :);

  % Iterate over probes
  for j=1:n_probes
    % Count "yes"-s and dump into matrix
    probe = probes_action(j);
    fprintf('%s : %s\n', target, probe)

    rows_probe = rows(rows.Probe == probe, :);
    rows_probe_yes = rows_probe(rows_probe.ResKey == key_yes, :);
    c_mat(i, j) = height(rows_probe_yes);
  end
end

%% Normalize count matrix WITHIN CONTEXT
% Extract cells within a context and sum them together

% Divide each cell by the sum


%% ------------------------------------------------------------------------
% Functions
function table_ = removeRowByKey(table_, res_key)
  % 1.5) Remove trials with responses with "res_key"
  for i=height(table_):-1:1
    if isequal(table_{i, 'ResKey'}, res_key)
      table_(i, :) = [];
    end
  end
end