function [congruence, probeType, Probe] = decodeProbe(code, info)
    % Decode factors from code
    factors = ASF_decode(code, info.factorialStructure);
    c = factors(1);   % congruence
    d = factors(2);   % duration
    p = factors(3);   % probe
    r = factors(4);   % correct response
    % probe type
    if p > 8
        t = 0;
    else
        t = 1;
    end

    congruence = info.CongruenceLevels(c+1);
    PT = info.PresTimeLevels(d+1);      % * 1/60 * 1000;
    probeType = info.ProbeTypeLevels(t+1);
    Probe = info.ProbeLevels(p+1);
    CorrectResponse = info.CorrectResponses(r+1);
    
end