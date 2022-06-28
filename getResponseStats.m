function stats = getResponseStats(tTrials, key_yes, key_no)
  % Extract responses as a function of presentation time by probe type
  % Iterate over unique values in PresTime and compute mean & std for each
  % Extracted information:
  % = presentation time
  % = samples
  % = hit (correct response)
  % = hit rate (hits / total_responses)
  % = false alarms (hit "yes" when NO; hit "no" when YES)
  % = false alarm rate (false_alarms / total_responses)
  % = correct rejections

  fprintf('Computing RT-statistics ...\n')

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
    empty_response = 0;
    corr_rejections = 0;
    f_alarms = 0;
    
    for j=1:length(ResKeys)
      n_samples = n_samples + 1;
      
      switch ResKeys(j)
        case key_yes % "yes" : correct response
          if ResKeys(j) == TrueKeys(j)
            hits = hits + 1;
          else % key_no
            misses = misses + 1;
          end
        
        case key_no % "no" : correct response
          if ResKeys(j) == TrueKeys(j)
            corr_rejections = corr_rejections + 1;
          elseif ResKeys(j) == key_yes % false alarm
            f_alarms = f_alarms + 1;
          end
          
        case 0 % No response given : consider miss
          empty_response = empty_response + 1;
      end % switch

      %misses = misses + empty_response;
    end

    if empty_response ~= 0
      fprintf('\tCounted missing responses: %d.\n', empty_response)
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
    stats(end+1, :) = {uniqTimes(i),n_samples,...
                       hits, hit_rate,...
                       f_alarms, f_alarm_rate, corr_rejections};
    % TODO : f_alarms, and f_alarm_rate are missing!
                       %norminv(hit_rate) - norminv(f_alarm_rate)};
  end
end