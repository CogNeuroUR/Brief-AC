function checkConditionBalance(TRD, lBlock, factorialStructure,...
  CongruencyLevels, ProbeTypeLevels, ProbeLevels, DurationLevels)
  % Check the distribution of trials per condition (i.e. ASF code)
  
  %% Temporary
  factorialStructure = info.factorialStructure;
  CongruencyLevels = info.CongruencyLevels;
  ProbeTypeLevels = info.ProbeTypeLevels;
  ProbeLevels = info.ProbeLevels;
  DurationLevels = info.DurationLevels;

  %% Sweep through the trials and extract codes
  fprintf('\nChecking trial codes ...\n');
  
  
  codes = [];

  for iTrial = 1:length(TRD)
    codes(end+1) = TRD(iTrial).code;
    
    %{
    % TODO : collect labels for the plot
    % Decode factors from code
    factors = ASF_decode(TRD(iTrial).code,factorialStructure);
    c = factors(1);   % congruency
    t = factors(2);   % probe type
    p = factors(3);   % probe
    d = factors(4);   % duration
    
    codes(end+1) = append(CongruencyLevels(c+1), ' ', ProbeTypeLevels(t+1), ' ', ProbeLevels(p+1), ' ', DurationLevels(d+1));

    %}
  end
  fprintf('Code check finished.\n')

  %% Extract unique and occurences
  uniqCodes = unique(codes);
  count = histc(codes, uniqCodes);
  relFreq = count; %/numel(codes); % decomment for ratio

  %% Decode code names
  codeLabels = {};
  for iCode=1:length(uniqCodes)
    code = uniqCodes(iCode);
    % Decode factors from code
    factors = ASF_decode(code, info.factorialStructure);
    c = factors(1);   % congruency
    t = factors(2);   % probe type
    d = factors(3);   % duration
    
    disp(factors);
    string = sprintf('%s %s %d',...
                     info.CongruencyLevels(c+1), ...
                     info.ProbeTypeLevels(t+1), ...
                     info.DurationLevels(d+1));
    codeLabels(end+1) = {string};
  
  end

  %% Plot
  bar(uniqCodes, relFreq);

  xticks([uniqCodes])
  xticklabels(codeLabels)
  xtickangle(60);

  xlabel('Conditions') 
  ylabel('Repetitions per condition')
  title(sprintf('Reps per condition for N=%d blocks (%d trials)', nBlocks, length(TRD)))

  ylim([0, max(relFreq) + 5])

end


function checkConditionBalance2(TRD, lBlock, factorialStructure,...
  CongruencyLevels, ProbeTypeLevels, ProbeLevels, DurationLevels)
  % Check the distribution of trials per condition (i.e. ASF code)
  
  %% Temporary
  factorialStructure = info.factorialStructure;
  CongruencyLevels = info.CongruencyLevels;
  ProbeTypeLevels = info.ProbeTypeLevels;
  ProbeLevels = info.ProbeLevels;
  DurationLevels = info.DurationLevels;

  %% Sweep through the trials and extract codes
  fprintf('\nChecking trial codes ...\n');
  
  simplifiedFactorialStructure = [info.nCongruencyLevels,...
                                  info.nProbeTypeLevels,...
                                  info.nDurationLevels];
  
  codes = [];

  for iTrial = 1:length(TRD)
    % ignore special trial codes
    if TRD(iTrial).code < 1000
      % Decode factors from code
      factors = ASF_decode(TRD(iTrial).code, info.factorialStructure);
      %factors = ASF_decode(TRD(iTrial).code, simplifiedFactorialStructure);
      c = factors(1);   % congruency
      t = factors(2);   % probe type
      d = factors(3);
      
      if length(factors) == 4
        p = factors(3);   % probe
        d = factors(4);   % duration
      end
      %codes(end+1) = TRD(iTrial).code;
  
      % collect simplified code
      codes(end+1) = ASF_encode([c, t, d], simplifiedFactorialStructure);
    end
  end
  fprintf('Code check finished.\n')

  %% Extract unique and occurences
  uniqCodes = unique(codes);
  count = histc(codes, uniqCodes);
  relFreq = count; %/numel(codes); % decomment for ratio

  %% Decode code names
  codeLabels = {};
  for iCode=1:length(uniqCodes)
    code = uniqCodes(iCode);
    % Decode factors from code
    factors = ASF_decode(code, simplifiedFactorialStructure);
    c = factors(1);   % congruency
    t = factors(2);   % probe type
    d = factors(3);   % duration
    
    disp(factors);
    string = sprintf('%s %s %d',...
                     info.CongruencyLevels(c+1), ...
                     info.ProbeTypeLevels(t+1), ...
                     info.DurationLevels(d+1));
    codeLabels(end+1) = {string};
  
  end

  %% Plot
  bar(uniqCodes, relFreq);

  xticks([uniqCodes])
  xticklabels(codeLabels)
  xtickangle(60);

  xlabel('Conditions') 
  ylabel('Repetitions per condition')
  title(sprintf('Reps per condition for N=%d blocks (%d trials)', nBlocks, length(TRD)))

  ylim([0, max(relFreq) + 5])

end