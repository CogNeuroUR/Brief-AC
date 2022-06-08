function checkConditionBalance2(TRD, lBlock, factorialStructure,...
  CongruencyLevels, ProbeTypeLevels, ProbeLevels, DurationLevels)
  % Check the distribution of trials per condition (i.e. ASF code)
  
  %% Temporary
  factorialStructure = info.factorialStructure;
  CongruencyLevels = info.CongruencyLevels;
  ProbeTypeLevels = info.ProbeTypeLevels;
  ProbeLevels = info.ProbeLevels;
  DurationLevels = info.DurationLevels;
  nBlocks = 5;


  %% Sweep through the trials and extract codes
  fprintf('\nChecking trial codes ...\n');
  
  simplifiedFactorialStructure = [info.nCongruencyLevels,...
                                  info.nProbeTypeLevels,...
                                  info.nDurationLevels];
  
  codes = [];
  codes_simple = [];

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
      %codes_simple(end+1) = ASF_encode([c, t, d], simplifiedFactorialStructure);
      codes(end+1) = ASF_encode([c, t, d], simplifiedFactorialStructure);

    else
      fprintf('Rejected trial %d with code %d\n', iTrial, TRD(iTrial).code)
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
    %factors = ASF_decode(code, simplifiedFactorialStructure);
    factors = ASF_decode(code, factorialStructure);
    c = factors(1);   % congruency
    t = factors(2);   % probe type
    d = factors(3);   % duration
   
    if length(factors) == 4
      p = factors(3);   % probe
      d = factors(4);   % duration
    end
    
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