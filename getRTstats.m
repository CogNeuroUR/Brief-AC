function stats = getRTstats(t_trials)
  % INPUT
  %   t_trials : table
  % OUTPUT
  %   stats : cell array with 3 columns (PT, mean(RT), SE(RT)) with one
  %           row for each unique PT
  
  % iterates over unique values in PresTime and compute mean & std for each
  %fprintf('Collecting RTs...\n')

  stats = {};
  uniqTimes = unique(t_trials.PresTime);
  
  %fprintf('\nTarget duration: mean & std RT\n')
  for i=1:length(uniqTimes)
    values = t_trials.RT(t_trials.PresTime==uniqTimes(i));
    % convert ot matrix, if cell:
    if isequal(class(values), 'cell'); values = cell2mat(values); end
    avg = nanmean(values);
    stderr = nanstd(values) / sqrt(length(values)); % SE : standard error
    
    % Verbose
    %fprintf('PresTime: %d; Mean RT: %.2fms; SE RT: %.2fms\n',...
    %        uniqTimes(i), avg, stderr);
    
    % Dump
    stats(end+1, :) = {uniqTimes(i), avg, stderr};
  end
end