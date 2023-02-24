%% 19.09.22 | After meeting w/ AL
% IDEA
% Check if the trial corrResp in the TRD-file are equal to those from the
% ExpInfo

%% Read YES-NO answers [SINGLE SUBJECT]
% path_trd = 'SUB-96_right.trd';
path_trd = 'results/final/SUB-04_right.trd';
trialdefs = read_correctResponse(path_trd)';
% Remove first line (which contains the first and last factor)
trialdefs = trialdefs(2:end);

% Get Yes-key from filename
parts = split(path_trd, '_');
parts = split(parts(2), '.');
if isequal(parts{1}, "left")
    yesKey = 37;
    noKey = 39;
elseif isequal(parts{1}, "right")
    yesKey = 39;
    noKey = 37;
end
[trialdefs(:).YES] = deal(yesKey);
[trialdefs(:).NO] = deal(noKey);
N_subjects = 1;

%% Read YES-NO answers [ALL SUBJECTS]
% path_trd = 'SUB-96_right.trd';
path_results = 'results/final/';
l_files = dir(path_results);

trialdefs = [];
N_subjects = 0;

% iterate over files
fprintf('Sweeping through files ...\n');
for i=1:length(l_files)
  path2file = [path_results, l_files(i).name];
  
  % check if of mat-extension
  [~, fName, fExt] = fileparts(l_files(i).name);
  
  switch fExt
    case '.trd'
      % ignore demo-results
      if ~contains(l_files(i).name, 'demo')
        fprintf('\tLoading : %s\n', l_files(i).name);
        % Get Yes-key from filename
        parts = split(l_files(i).name, '_');
        parts = split(parts(2), '.');
        if isequal(parts{1}, "left")
            yesKey = 37;
            noKey = 39;
        elseif isequal(parts{1}, "right")
            yesKey = 39;
            noKey = 37;
        else
            break
        end
        temp = read_correctResponse(path2file)';
        temp = temp(2:end);
        [temp(:).YES] = deal(yesKey);
        [temp(:).NO] = deal(noKey);
        trialdefs = [trialdefs; temp];
        N_subjects = N_subjects + 1;
      end
  end
end

%% Decode trial codes and add as columns to trialdefs
% Get factorial info
[~, info] = makeTRDTemplate(1);

for i=1:height(trialdefs)
  % Skip special trials (code > 999)
  if trialdefs(i).code < 1000
    [congruency, probeType, Probe, duration] = decodeProbe_full(...
                                                 trialdefs(i).code,...
                                                 info.factorialStructure,...
                                                 info.CongruencyLevels,...
                                                 info.ProbeTypeLevels,...
                                                 info.ProbeLevels,...
                                                 info.DurationLevels);
    trialdefs(i).congruency = congruency;
    trialdefs(i).probeType = probeType;
    trialdefs(i).Probe = Probe;
    trialdefs(i).duration = duration;
  end
end

%% Count correct-YES trials for each condition
counts = [];

countYes = [];
countNo = [];

ix = 0;
for iCongruency=1:length(info.CongruencyLevels)
  for iProbeType=1:length(info.ProbeTypeLevels)
    for iDuration=1:length(info.DurationLevels)
      % Get indices to the subset corresponding to the current condition
      subset = trialdefs(...
          [trialdefs(:).congruency] == info.CongruencyLevels(iCongruency) &...
          [trialdefs(:).probeType] == info.ProbeTypeLevels(iProbeType) & ...
          [trialdefs(:).duration] == info.DurationLevels(iDuration));
      % Get correct responses (YES & NO)
      idxsYes = [subset(:).corrResp] == [subset(:).YES];
      idxsNo = [subset(:).corrResp] == [subset(:).NO];
      
      % Verbose
      fprintf('%d) %s | %s | %d | Yes/No: %d/%d\n',ix,...
        info.CongruencyLevels(iCongruency),...
        info.ProbeTypeLevels(iProbeType), ...
        info.DurationLevels(iDuration),...
        height(subset(idxsYes)),...
        height(subset(idxsNo)))
      
      counts(end+1) = height(subset);
      countYes(end+1) = height(subset(idxsYes));
      countNo(end+1) = height(subset(idxsNo));
      ix = ix + 1;
    end
  end
end

%% Plot
fh = figure;

probes = ["CC", "AC", "CI", "AI"];
times = [2:6 8];
vars = {};

for iP=1:length(probes)
  for iT=1:length(times)
    vars = [vars; sprintf('%s_%d', probes(iP), times(iT))];
  end
end

x = 1:length(vars);
y1 = countYes./countNo;
y2 = countNo./countYes;

e1 = plot(x-0.05, y1, 'Marker', 'o', 'Color', 'b');
hold on
%e2 = plot(x+0.05, y2, 'Marker', 'x', 'Color', 'r');
yline(1, '--')
xline(6.5)
xline(2*6.5-0.5)
xline(3*6.5 - 1)
hold off

%e1.Marker = "x";
%e2.Marker = "o";

xticks(x)
xticklabels(vars)

ylim([0, 2])

xlabel('Conditions')
ylabel('Ratio trials')

lgd = legend('YES/NO');
lgd.Location = 'northeast';
lgd.Color = 'none';

stitle = sprintf('Ratio: YES vs NO correct responses (TRD files; N=%d)', N_subjects);
%stitle = sprintf('Correct: Yes vs No  (N=%d)', height(groupDprime));
title(stitle);

%% SAVE PLOTS ============================================================
save_plots = 1;
if save_plots
   % define resolution figure to be saved in dpi
 res = 420;
 % recalculate figure size to be saved
 set(fh,'PaperPositionMode','manual')
 fh.PaperUnits = 'inches';
 fh.PaperPosition = [0 0 5000 2500]/res;
 print('-dpng','-r300',['plots/sanity_correctResponsesTRD_N21'])
end

%% Load ExpInfo
path_expinfo = 'results/final/SUB-03_left.mat';
load(path_expinfo)

codes_exp = [];

for i=1:length(ExpInfo.TrialInfo)
  codes_exp(end+1) = ExpInfo.TrialInfo(i).trial.code;
end
codes_exp = codes_exp';

%% Check whether equal
if isequal(correctResponses, codes_exp)
  verdict = 1;
end

%% Test for all files
files = dir('results/final');

fprintf('Sweeping through files ...\n')
for f=1:length(files)
  % check if of mat-extension
  [~, fName, fExt] = fileparts(files(f).name);
  
  if isequal(fExt, '.mat')
    % ignore demo-results
    if contains(files(f).name, 'demo'); continue; end
    % verbose
    fprintf('\t%s\n', fName)
    
    % Load from ExpInfo
    clear ExpInfo
    load([files(f).folder filesep files(f).name])
    codes_exp = [];
    for i=1:length(ExpInfo.TrialInfo)
      codes_exp(end+1) = ExpInfo.TrialInfo(i).trial.code;
    end
    codes_exp = codes_exp';

    % Load from TRD
    correctResponses = read_trd_codes([files(f).folder, filesep, fName, '.trd'])';
    % Remove first line
    correctResponses = correctResponses(2:end);
  end

  % Check equality: raise error, if not equal
  if ~isequal(correctResponses, codes_exp)
    error('Code lists (TRD & ExpInfo) are not equal!')
  end
end
fprintf('Done!\n')


%% FUNCTIONS
function trialdefs = read_correctResponse(fname)
%READ IN TRIAL DEFINITIONS, ONE BY ONE
% From ASF_readTrialDefs.m (JS)
  fid = fopen(fname, 'r');
  counter = 0;
  corrResp = [];
  while 1
    counter = counter + 1;
    aline = fgetl(fid);
    if ~ischar(aline), break, end
    if isempty(aline), break, end %now deals with trailing empty lines in a trd
    %fprintf(1, '%s\n', aline)
    aline = str2num(aline); %#ok<ST2NM>
    trialdefs(counter).code = aline(1); %#ok<AGROW>
    trialdefs(counter).corrResp = aline(end);
  end % while
  fclose(fid);
end