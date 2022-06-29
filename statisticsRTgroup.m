function statisticsRTgroup(ExpInfo, key_yes, key_no, save_plots)
%function [rt_act_con, rt_ctx_con, rt_act_inc, rt_ctx_inc] =...
%          computeRTstatistics(ExpInfo, key_yes, key_no, make_plots, save_plots)
% Computes RT statistics (mean & std) per condition for each probe type and
% congruency.
%
% Written for BriefAC (AinC)
% Vrabie 2022
make_plots = 1;

%% Collect results from files : ExpInfo-s
% get list of files
path_results = 'results/final/';
l_files = dir(path_results);

groupRT = [];
l_subjects = {};

% iterate over files
for i=1:length(l_files)
  path2file = [path_results, l_files(i).name];
  
  % check if of mat-extension
  [fPath, fName, fExt] = fileparts(l_files(i).name);
  
  switch fExt
    case '.mat'
      % ignore demo-results
      if ~contains(l_files(i).name, 'demo')
        fprintf('%s : %s\n', l_files(i).name, fExt);
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

        % Extract RT = f(presentation time) by probe type
        statsAC = getRTstats(trialsAC);
        statsCC = getRTstats(trialsCC);
        statsAI = getRTstats(trialsAI);
        statsCI = getRTstats(trialsCI);
        
        % TODO

        % 3) Compute d-prime  
        dprimeAC = dprime(statsAC);
        dprimeCC = dprime(statsCC);
        dprimeAI = dprime(statsAI);
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


%% Extract trials for each probe by decoding trials' ASF code
[t_trialsActionCongruent, t_trialsContextCongruent,...
 t_trialsActionIncongruent, t_trialsContextIncongruent] = getTrialResponses(ExpInfo);

%% Collect RT statistics
% Extract RT = f(presentation time) by probe type
rt_act_con = getRTstats(t_trialsActionCongruent);
rt_ctx_con = getRTstats(t_trialsContextCongruent);
rt_act_inc = getRTstats(t_trialsActionIncongruent);
rt_ctx_inc = getRTstats(t_trialsContextIncongruent);

%% ########################################################################
% Plots [CONGRUENT]
if make_plots
  fh = figure;
  
  subplot(2,2,1);
  % Plot RT's as a function of presentation time
  screen_freq = (1/60);
  factor = screen_freq*1000;
  ylimits = [500 1500];
  xlimits = [1.8 8.2]*factor;
  x = [rt_ctx_con{:, 1}]*factor; % in ms
  
  % Collect mean RT's for action and context probes
  yAct = [rt_act_con{:, 2}];
  yCon = [rt_ctx_con{:, 2}];
  % Collect RT's standard deviation for action and context probes
  stdAct = [rt_act_con{:, 3}];
  stdCon = [rt_ctx_con{:, 3}];
  
  e1 = errorbar(x,yAct,stdAct);
  hold on
  e2 = errorbar(x,yCon,stdCon);
  
  e1.Marker = "x";
  e2.Marker = "o";
  
  title('RT : Action & Context Probes [CONGRUENT]');
  legend('Actions','Context')
  xlabel('Presentation time [ms]')
  ylabel('RT [ms]')
  xlim(xlimits)
  ylim(ylimits);
  
  % Plot [INCONGRUENT]
  subplot(2,2,2);
  % Plot RT's as a function of presentation time
  screen_freq = (1/60);
  factor = screen_freq*1000;
  x = [rt_act_inc{:, 1}]*factor; % in ms
  
  % Collect mean RT's for action and context probes
  yAct = [rt_act_inc{:, 2}];
  yCon = [rt_ctx_inc{:, 2}];
  % Collect RT's standard deviation for action and context probes
  stdAct = [rt_act_inc{:, 3}];
  stdCon = [rt_ctx_inc{:, 3}];
  
  e1 = errorbar(x,yAct,stdAct);
  hold on
  e2 = errorbar(x,yCon,stdCon);
  
  e1.Marker = "x";
  e2.Marker = "o";
  
  title('RT : Action & Context Probes [INCONGRUENT]');
  legend('Actions','Context')
  xlabel('Presentation time [ms]')
  ylabel('RT [ms]')
  xlim(xlimits)
  ylim(ylimits);
  
  % Plot ACTIONS : congruent vs incongruent
  subplot(2,2,3);
  % Plot RT's as a function of presentation time
  screen_freq = (1/60);
  factor = screen_freq*1000;
  x = [rt_ctx_con{:, 1}]*factor; % in ms
  
  % Collect mean RT's for action and context probes
  yAct = [rt_act_con{:, 2}];
  yCon = [rt_act_inc{:, 2}];
  % Collect RT's standard deviation for action and context probes
  stdAct = [rt_act_con{:, 3}];
  stdCon = [rt_act_inc{:, 3}];
  
  e1 = errorbar(x,yAct,stdAct);
  hold on
  e2 = errorbar(x,yCon,stdCon);
  
  e1.Marker = "x";
  e2.Marker = "o";
  
  title('RT : Actions');
  legend('Congruent','Incongruent')
  xlabel('Presentation time [ms]')
  ylabel('RT [ms]')
  xlim(xlimits)
  ylim(ylimits);

  % Plot CONTEXT : congruent vs incongruent
  subplot(2,2,4);
  % Plot RT's as a function of presentation time
  screen_freq = (1/60);
  factor = screen_freq*1000;
  x = [rt_ctx_con{:, 1}]*factor; % in ms
  
  % Collect mean RT's for action and context probes
  yAct = [rt_ctx_con{:, 2}];
  yCon = [rt_ctx_inc{:, 2}];
  % Collect RT's standard deviation for action and context probes
  stdAct = [rt_act_con{:, 3}];
  stdCon = [rt_ctx_inc{:, 3}];
  
  e1 = errorbar(x,yAct,stdAct);
  hold on
  e2 = errorbar(x,yCon,stdCon);
  
  e1.Marker = "x";
  e2.Marker = "o";
  
  title('RTs : Contexts');
  legend('Congruent','Incongruent')
  xlabel('Presentation time [ms]')
  ylabel('RT [ms]')
  xlim(xlimits)
  ylim(ylimits);

  if save_plots
     % define resolution figure to be saved in dpi
   res = 420;
   % recalculate figure size to be saved
   set(fh,'PaperPositionMode','manual')
   fh.PaperUnits = 'inches';
   fh.PaperPosition = [0 0 5000 2500]/res;
   print('-dpng','-r300',['plots/' ExpInfo.Cfg.name '_RT_statistics'])
  end
end

end



%% ------------------------------------------------------------------------
function stats = getRTstats(t_trials)
  % t_trials : table
  % iterate over unique values in PresTime and compute mean & std for each
  fprintf('Collecting RTs...\n')

  stats = {};
  uniqTimes = unique(t_trials.PresTime);
  
  fprintf('\nTarget duration: mean & std RT\n')
  for i=1:length(uniqTimes)
    values = t_trials.RT(t_trials.PresTime==uniqTimes(i));
    if isequal(class(values), 'cell'); values = cell2mat(values); end
    avg = nanmean(values);
    %stdev = nanstd(values); % SD
    stderr = nanstd(values) / sqrt(length(values)); % SE : standard error
    fprintf('PresTime: %d; Mean RT: %.2fms; SE RT: %.2fms\n',...
            uniqTimes(i), avg, stderr);
    stats(end+1, :) = {uniqTimes(i), avg, stderr};
  end
end