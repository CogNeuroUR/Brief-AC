%% Load ExpInfo
load('results/final/SUB-09_left.mat')
%load('results/final/SUB-08_right.mat')

%% Get factorial structures
info = getFactorialStructure();
disp(info.factorialStructure)

%% Collect trial codes
codes = [];
codes_s = [];
for i=1:length(ExpInfo.TrialInfo)
  code = ExpInfo.TrialInfo(i).trial.code;
  if code < 1000
    codes(end+1) = code;

    factors = ASF_decode(code, info.factorialStructure);
    c = factors(1);   % congruency
    t = factors(2);   % probe type
    p = factors(3);   % probe
    d = factors(4);   % duration

    % encode simplified
    codes_s(end+1) = ASF_encode([c, t, d], info.factorialStructureSimplified);
  end
end

%%
summaryTrialSorting(codes_s)

%% Check for repetitions by trial code
% Jan : https://de.mathworks.com/matlabcentral/answers/382011-how-to-count-the-number-of-consecutive-identical-elements-in-both-the-directions-in-a-binary-vecto#answer_304607
d = [true, diff(codes_s) ~= 0, true];  % TRUE if values change
n = diff(find(d));               % Number of repetitions
Y = repelem(n, n);

%% Function based on Jan's code:
function summaryTrialSorting(codes)
  % Given the trial codes, check for repetitions (up to, say, 10)
  d = [true, diff(codes) ~= 0, true];  % TRUE if values change
  n = diff(find(d));               % Number of repetitions
  Y = repelem(n, n);

  % Count number of repetitions for each repetition level
  % 1) find unique values in Y
  rep_levels = unique(Y);
  % 2) for each unique, count instances and divide by unique
  binc = 1:5;
  counts = hist(Y,binc);
  result = [binc; counts];

  fprintf('Repetition Level |    Counts\n')
  fprintf('--------------------------\n')
  for i=2:length(result)
    fprintf('\t%d\t |\t%d\n', result(1, i), result(2, i)/result(1, i))
  end
end