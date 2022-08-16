function [M, CI] = simple_ci(data)
% Compute the mean and confidence interval
  c = 0.95;
  
  % Standard error
  SEM = std(data)/sqrt(length(data));
  % T-Score
  interval = [(1 - c)/2, c + (1 - c)/2]; % e.g. [0.025, 0.975] for c = 95%
  df = length(data) - 1;
  ts = tinv(interval, df);
  % Mean
  M = mean(data);
  % Confidence Interval
  CI = M + ts*SEM;
  CI = abs(CI(1) - M);
end