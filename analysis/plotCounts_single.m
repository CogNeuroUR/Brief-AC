function plotCounts_single(save_plots)
%function [rt_act_con, rt_ctx_con, rt_act_inc, rt_ctx_inc] =...
%          computeRTstatistics(ExpInfo, key_yes, key_no, make_plots, save_plots)
% Computes RT group statistics (mean & std) per condition for each probe type and
% congruency.
%
% Written for BriefAC (AinC)
% Vrabie 2023
%%
make_plots = 1;
save_plots = 1;
path_expinfo = 'data/SUB-01_right.mat';

%% Load results from file : ExpInfo
% get list of files
clear ExpInfo;
load(path_expinfo, 'ExpInfo');

info = getDesignParams();

% perform analysis
% 1) Extract trials for each probe by decoding trials' ASF code
tTrials = getTrialResponsesAll(ExpInfo);

%%
find([tTrials.Congruence] == info.CongruenceLevels(iComp) & ...
    [tTrials.ProbeType] == info.ProbeTypeLevels(iPType) & ...
    [tTrials.Probe]          == info.ProbeLevels(iP))

%% Extract Counts per condition
% Question:
%   What to do with empty / no responses?
%       a) Consider as wrong?
%       b) Ignore?
c = 0;
for iComp = 1:info.nCongruenceLevels
    for iPT = 1:info.nPresTimeLevels
        for iPType = 1:info.nProbeTypeLevels
            %for iP = 1:info.nProbeLevels
                %for iCtxt = 1:info.nContextLevels
                    %for iAct = 1:info.nActionLevels
                        c = c + 1;
                        disp(c)
                        subset = tTrials(find(...
                            [tTrials.Congruence]     == info.CongruenceLevels(iComp)&...
                            [tTrials.PresTime]       == info.PresTimeLevels(iPT)&...
                            [tTrials.ProbeType]      == info.ProbeTypeLevels(iPType)));%&...
                            %[tTrials.Probe]          == info.ProbeLevels(iP)&...
                            %[tTrials.Target_Context] == info.ContextLevels(iCtxt)&...
                            %[tTrials.Target_Action]  == info.ActionLevels(iAct)));
                        %disp(height(subset))
                        counts(c).Congruence = info.CongruenceLevels(iComp);
                        counts(c).PT = info.PresTimeLevels(iPT);
                        counts(c).ProbeType = info.ProbeTypeLevels(iPType);
                        counts(c).k = sum([subset.TrueKey] == [subset.ResKey]);
                        % OPTION A: consider wrong
                        %counts(c).kMax = length(subset);
                        % OPTION B: Ignore (subtract nr of empty cells)
                        counts(c).kMax = length(subset) - sum([subset.ResKey] == 0);
                        counts(c).p = counts(c).k / counts(c).kMax;
                    %end
                %end
            %end
        end    
    end
end


%% ########################################################################
% Plots [COMPATIBLE]
%% ########################################################################
if make_plots
  fh = figure;

  % General parameters
  mark_ctx = "s";
  mark_act = "o";
  color_compatible = "#00BF95";
  color_incompatible = "#BF002A";

  lgd_location = 'northwest';

  xfactor = 1000/60;
  ylimits = [0, 1];
  x = info.PresTimeLevels*xfactor; % in ms
  xlimits = [x(1) - 20, x(end) + 20];
  %xlabels = {'33.3', '50.0', '66.6', '83.3', '100.0', '133.3', 'Overall'};

  % PLOT : ACTION (Compatible vs Incompatible) =============================
  subplot(1,2,1);

  data1 = [counts([counts.Congruence] == "compatible" & [counts.ProbeType] == "action").p];
  data2 = [counts([counts.Congruence] == "incompatible" & [counts.ProbeType] == "action").p];
  
  %e1 = errorbar(x-1.5, y1, err1);
  e1 = plot(x, data1, '-o', 'Color', color_compatible);
  hold on
  %e2 = errorbar(x+1.5, y2, err2);
  e2 = plot(x, data2, '-o', 'Color', color_incompatible);
  yline(0.5, '--');
  hold off

%   e1.Marker = mark_act;
%   e2.Marker = mark_ctx;

%   e1.Color = color_compatible;
%   e2.Color = color_incompatible;
%   e1.MarkerFaceColor = color_compatible;
%   e2.MarkerFaceColor = color_incompatible;

  set(e1, 'LineWidth', 0.8)
  set(e2, 'LineWidth', 0.8)

  set(gca, 'Box', 'off') % removes upper and right axis

  xticks(x)
  xticklabels(round(x, 1)) 
  xlim(xlimits)
  ylim(ylimits)
  
  lgd = legend('Compatible','Incompatible');
  lgd.Location = lgd_location;
  lgd.Color = 'none';
  
  stitle = sprintf('Action (N=%d)', height(data1));
  title(stitle);
  xlabel('Presentation Time [ms]')
  ylabel('Sensitivity (d'')')


  % PLOT : CONTEXT (Compatible vs Incompatible) =============================
  subplot(1,2,2);
  % Define indices for for condition category
  
  data1 = [counts([counts.Congruence] == "compatible" & [counts.ProbeType] == "context").p];
  data2 = [counts([counts.Congruence] == "incompatible" & [counts.ProbeType] == "context").p];
  
  
  %e1 = errorbar(x-1.5, y1, err1);
  e1 = plot(x, data1, '-o', 'Color', color_compatible);
  hold on
  %e2 = errorbar(x+1.5, y2, err2);
  e2 = plot(x, data2, '-o', 'Color', color_incompatible);
  yline(0.5, '--');
  hold off

  set(e1, 'LineWidth', 0.8)
  set(e2, 'LineWidth', 0.8)

  set(gca, 'Box', 'off') % removes upper and right axis

  xticks(x)
  xticklabels(round(x, 1)) 
  xlim(xlimits)
  ylim(ylimits)
  
  lgd = legend('Compatible','Incompatible');
  lgd.Location = lgd_location;
  lgd.Color = 'none';
  
  stitle = sprintf('Scene (N=%d)', height(data1));
  title(stitle);
  xlabel('Presentation Time [ms]')
  ylabel('Sensitivity (d'')')

  % SAVE PLOTS ============================================================
  if save_plots
    % define resolution figure to be saved in dpi
    res = 420;
    % recalculate figure size to be saved
    set(fh,'PaperPositionMode','manual')
    fh.PaperUnits = 'inches';
    fh.PaperPosition = [0 0 5000 1700]/res;
    [p, f] = fileparts(path_expinfo);
    print('-dpng','-r300',['plots/counts_single_', f])
    %exportgraphics(fh, 'plots/ppilotDprime_context.eps')
  end
end % if make_plots
end

function trials = convert2mat(trials)
    for i=1:height(trials)
        %trials.ResKey(i) = cell2mat(trials.ResKey(i));
        trials.ResKey(i) = trials.ResKey{i};
    end
end