function [congruency, probeType, Probe, duration] = decodeProbe_full(code,...
                                                      factorialStructure,...
                                                      CongruencyLevels,...
                                                      ProbeTypeLevels,...
                                                      ProbeLevels,...
                                                      DurationLevels)
    % Decode factors from code
    factors = ASF_decode(code, factorialStructure);
    c = factors(1);   % congruency
    t = factors(2);   % probe type
    d = factors(3);   % duration

    if length(factors) == 4
      p = factors(3);   % probe
      d = factors(4);   % duration
      % Check Probe : from code vs from TRD
    end
    
    congruency = CongruencyLevels(c+1);
    probeType = ProbeTypeLevels(t+1);
    Probe = ProbeLevels(p+1);
    duration = DurationLevels(d+1);
end