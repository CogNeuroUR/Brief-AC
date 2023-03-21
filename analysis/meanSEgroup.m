function [Ms, SEs] = meanSEgroup(data)
% Computes means and CIs for each condition separately
% ONE CONDITION : ONE COLUMN in data
% N_rows : N_subjects (n_samples)

Ms = mean(data);
SEs = std(data) / sqrt(length(data));

end