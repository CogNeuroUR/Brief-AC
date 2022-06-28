function summaryExpInfo_detailed(ExpInfo)
% Computes RT statistics (mean & std) per condition for each probe type and
% congruency.
%
% Written for BriefAC (AinC)
% Vrabie 2022

%% Extract trials for each probe by decoding trials' ASF code
[t_trialsActionCongruent, t_trialsContextCongruent,...
 t_trialsActionIncongruent, t_trialsContextIncongruent] = getTrialResponses(ExpInfo);

%% Extract accuracies per PT for each probe type
acc_ActCon = accuracy_detailed(t_trialsActionCongruent);
acc_ActInc = accuracy_detailed(t_trialsActionIncongruent);
acc_CtxCon = accuracy_detailed(t_trialsContextCongruent);
acc_CtxInc = accuracy_detailed(t_trialsContextIncongruent);

%% Prepare strings
l_pts = [2:6 8];
str_PT = 'PresTime (ms) |';
str_Acc_AC = 'Accuracy (%%)  |';
str_Acc_AI = str_Acc_AC;
str_Acc_CC = str_Acc_AC;
str_Acc_CI = str_Acc_AC;
str_Empty_AC = 'Empty respons |';
str_Empty_AI = str_Empty_AC;
str_Empty_CC = str_Empty_AC;
str_Empty_CI = str_Empty_AC;

for iPT=1:6
  %disp(iPT);
  %str_PT = [str_PT, '\t', sprintf('%.1f', acc_ActCon.PresTime(iPT))];
  str_PT = [str_PT, '\t', sprintf('%.1f', l_pts(iPT))];
  str_Acc_AC = [str_Acc_AC, '\t', sprintf('%.1f', acc_ActCon.Accuracy(iPT)*100)];
  str_Acc_AI = [str_Acc_AI, '\t', sprintf('%.1f', acc_ActInc.Accuracy(iPT)*100)];
  str_Acc_CC = [str_Acc_CC, '\t', sprintf('%.1f', acc_CtxCon.Accuracy(iPT)*100)];
  str_Acc_CI = [str_Acc_CI, '\t', sprintf('%.1f', acc_CtxInc.Accuracy(iPT)*100)];
   
  str_Empty_AC = [str_Empty_AC, '\t', sprintf('%.1f', acc_ActCon.N_empty(iPT))];
  str_Empty_AI = [str_Empty_AI, '\t', sprintf('%.1f', acc_ActInc.N_empty(iPT))];
  str_Empty_CC = [str_Empty_CC, '\t', sprintf('%.1f', acc_CtxCon.N_empty(iPT))];
  str_Empty_CI = [str_Empty_CI, '\t', sprintf('%.1f', acc_CtxInc.N_empty(iPT))];
end

str_PT = [str_PT, '\n'];
str_Acc_AC = [str_Acc_AC, '\n'];
str_Acc_AI = [str_Acc_AI, '\n'];
str_Acc_CC = [str_Acc_CC, '\n'];
str_Acc_CI = [str_Acc_CI, '\n'];
str_Empty_AC = [str_Empty_AC, '\n'];
str_Empty_AI = [str_Empty_AI, '\n'];
str_Empty_CC = [str_Empty_CC, '\n'];
str_Empty_CI = [str_Empty_CI, '\n'];

%% Print to cmd
fprintf('\n');
fprintf('==============================================================\n')
fprintf('\t\tAction Probe : Congruent\n')
fprintf('==============================================================\n')
fprintf(str_PT);
fprintf('--------------------------------------------------------------\n')
fprintf(str_Acc_AC);
fprintf('--------------------------------------------------------------\n')
fprintf(str_Empty_AC);
fprintf('==============================================================\n')
fprintf('\t\tAction Probe : Incongruent\n')
fprintf('==============================================================\n')
fprintf(str_PT);
fprintf('--------------------------------------------------------------\n')
fprintf(str_Acc_AI);
fprintf('--------------------------------------------------------------\n')
fprintf(str_Empty_AI);
fprintf('==============================================================\n')
fprintf('\t\tContextProbe : Congruent\n')
fprintf('==============================================================\n')
fprintf(str_PT);
fprintf('--------------------------------------------------------------\n')
fprintf(str_Acc_CC);
fprintf('--------------------------------------------------------------\n')
fprintf(str_Empty_CC);
fprintf('==============================================================\n')
fprintf('\t\tContextProbe Probe : Incongruent\n')
fprintf('==============================================================\n')
fprintf(str_PT);
fprintf('--------------------------------------------------------------\n')
fprintf(str_Acc_CI);
fprintf('--------------------------------------------------------------\n')
fprintf(str_Empty_CI);
fprintf('==============================================================\n')
fprintf('\n');
end

%% ------------------------------------------------------------------------
function t_stats = accuracy_detailed(tTrials)
  % Extract responses as a function of presentation time by probe type
  % Iterate over unique values in PresTime and compute mean & std for each
  % Extracted information:
  % = presentation time (ms)
  % = samples
  % = nr correct answers
  % = nr wrong answers
  % = nr empty responses
  % = n_correct / n_samples

  fprintf('Computing accuracy per condition ...\n')

  stats = {};
  uniqTimes = unique(tTrials.PresTime);
  
  for i=1:length(uniqTimes)
    % collect given response and true response
    ResKeys = tTrials.ResKey(tTrials.PresTime==uniqTimes(i));
    TrueKeys = tTrials.TrueKey(tTrials.PresTime==uniqTimes(i));
    % check if there are the same nr. of responses as expected ones
    assert(length(ResKeys) == length(TrueKeys));
    
    % extract hits and false alarms
    n_samples = 0;
    n_correct = 0;
    n_wrong = 0;
    n_empty = 0;
    
    for j=1:length(ResKeys)
      response = ResKeys(j);
      if iscell(response)
        response = cell2mat(response);
      end

      n_samples = n_samples + 1;
      
      if response == TrueKeys(j)
        n_correct = n_correct + 1;
      elseif isequal(response, []) % [] := empty, i.e. no response given
        n_empty = n_empty + 1;
      else 
        n_wrong = n_wrong + 1;
      end

    end
    
    % concatenate
    stats(end+1, :) = {uniqTimes(i) * 1000/60, n_samples,...
                       n_correct, n_wrong, n_empty, n_correct/n_samples};
  end

  %% Convert cells to tables
  varnames = {'PresTime' 'N_samples' 'N_correct' 'N_wrong' 'N_empty' 'Accuracy'};
  t_stats = cell2table(stats, 'VariableNames', varnames);
end
