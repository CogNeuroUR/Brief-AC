function t_stats = dprime(t_stats)
  % 1) Extract rates
  % 2) Replace zeros and ones (to prevent infinities)
  %   Zeros -> 1/(2N); N : max nr. of observation in a group
  %   Ones  -> 1 - 1/(2N)
  % 3) Compute d-prime
  for i=1:height(t_stats)
    % Convert proportions of 0 and 1 to 1/(2N) and 1-1/(2N)
    % See Macmillan & Creelman (2005), Page 8.
    if t_stats.H(i) == 1
      t_stats.H(i) = 1 - 1/(2*(t_stats.Hits(i) + t_stats.Misses(i)));
    elseif t_stats.H(i) == 0
      t_stats.H(i) = 1/(2*(t_stats.Hits(i) + t_stats.Misses(i)));
    end

    if t_stats.F(i) == 0
      t_stats.F(i) = 1/(2*(t_stats.FalseAlarms(i) + t_stats.CorrectRejections(i)));
    elseif t_stats.F(i) == 1
      t_stats.F(i) = 1 - 1/(2*(t_stats.FalseAlarms(i) + t_stats.CorrectRejections(i)));
    end

    % Compute d-prime
    t_stats.dprime(i) = norminv(t_stats.H(i)) - norminv(t_stats.F(i));

    % Compute perfect score (max d-prime) w/ assumptions:
    % = Hits: 1 - 1/(2N) = 1 - 1/[2*(Hits + Misses)];
    % = FalseAlarms: 1/2N = 1/2*(FalseAlarms + CorrectRejections)
    H_perfect = 1 - 1/(2*(t_stats.Hits(i) + t_stats.Misses(i)));
    F_perfect = 1/(2*(t_stats.FalseAlarms(i) + t_stats.CorrectRejections(i)));
    t_stats.perfectDprime(i) = norminv(H_perfect) - norminv(F_perfect);
  end
end