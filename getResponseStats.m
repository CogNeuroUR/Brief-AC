function t_stats = getResponseStats(tTrials, key_yes, key_no)
  % Extract responses as a function of presentation time by probe type
  % Iterate over unique values in PresTime and compute mean & std for each
  %
  % Extracted information:
  % = presentation time
  % = samples
  % = hits : "yes when YES"
  % = misses : "no when YES"
  % = hit rate : hits / (hits + misses)
  % = false alarms : "yes when NO"
  % = correct rejections : "no when NO"
  % = false alarm rate : false_alarms / (false alarms + correct rejections)
  %
  % Vrabie 2022

  %fprintf('Computing statistics ...\n')

  stats = {};
  uniqTimes = unique(tTrials.PresTime);

  for i=1:length(uniqTimes)
    % collect given response and true response
    ResKeys = tTrials.ResKey(tTrials.PresTime==uniqTimes(i));
    TrueKeys = tTrials.TrueKey(tTrials.PresTime==uniqTimes(i));
    % check if there are the same nr. of responses as expected ones
    assert(length(ResKeys) == length(TrueKeys));
    
    % convert to matrix, if cell
    if isequal(class(ResKeys), 'cell')
      ResKeys = cell2mat(ResKeys);
    end
    if isequal(class(TrueKeys), 'cell')
      TrueKeys = cell2mat(TrueKeys);
    end
    
    % extract hits and false alarms
    n_samples = 0;
    hits = 0;
    misses = 0;
    n_empty = 0;
    corr_rejections = 0;
    f_alarms = 0;
    
    for j=1:length(ResKeys)
      n_samples = n_samples + 1;
      
      switch ResKeys(j)
        case key_yes % Targets ("yes" : correct response)
          if key_yes == TrueKeys(j) % Hit
            hits = hits + 1;
          else % False alarm : "yes" when NO
            %misses = misses + 1;
            f_alarms = f_alarms + 1;
          end
        
        case key_no % Distractors ("no" : correct response)
          if key_no == TrueKeys(j)  % correct rejection
            corr_rejections = corr_rejections + 1;
          else % Miss : "no" when YES
            %f_alarms = f_alarms + 1;
            misses = misses + 1;
          end
          
        case 0 % No response given
          n_empty = n_empty + 1;
      end % switch

    end
    
    % Subtract empty trials
    n_samples = n_samples - n_empty;
    if n_empty ~= 0
      fprintf('\tCounted missing responses: %d.\n', n_empty)
    end

    % compute hit- and false alarm rates
    if hits ~= 0
      hit_rate = hits / (hits + misses);
    else
      hit_rate = 0;
    end
    if f_alarms ~= 0
      f_alarm_rate = f_alarms / (f_alarms + corr_rejections);
    else
      f_alarm_rate = 0;
    end
    
    % concatenate
    stats(end+1, :) = {uniqTimes(i), n_samples,...
                       hits, hit_rate, misses,...
                       f_alarms, f_alarm_rate, corr_rejections};

    % Convert to table
    varnames = {'PresTime' 'N_samples' 'Hits' 'H' 'Misses' 'FalseAlarms' 'F' 'CorrectRejections'};
    t_stats = cell2table(stats, 'VariableNames', varnames);
  end
end