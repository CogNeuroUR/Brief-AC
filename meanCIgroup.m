function [Ms, CIs] = meanCIgroup(data)
% Computes means and CIs for each condition separately
% ONE CONDITION : ONE COLUMN in data
% N_rows : N_subjects (n_samples)

[n_subs, n_conds] = size(data);

Ms = [];
CIs = [];
for i=1:n_conds
  [M, CI] = simple_ci(data(:, i));
  Ms = [Ms, M];
  CIs = [CIs, CI];
end
end