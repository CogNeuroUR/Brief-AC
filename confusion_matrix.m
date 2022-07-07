%% Load ExpInfo
path2file = 'results/final/SUB-01_left.mat';
load(path2file, 'ExpInfo');

%%
probes_action = ["cutting" "grating" "whisking"...
                 "hole-punching" "stamping" "stapling"...
                  "hammering" "painting" "sawing"];
probes_context = ["kitchen"    "office"    "workshop"];

%%
std_fids = read_std();

%% Extract responses per action & per context
[trialsAC, trialsCC, trialsAI, trialsCI] = getTrialResponses(ExpInfo);

%% Remove "NO" probes, i.e. distractor probes.
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

%% 


%% ------------------------------------------------------------------------
% Functions
function table_ = removeRowByKey(table_, key_no)
  % 1.5) Remove trials with "NO" response 
  for i=height(table_):-1:1
    if isequal(table_{i, 'ResKey'}, key_no)
      table_(i, :) = [];
    end
  end
end