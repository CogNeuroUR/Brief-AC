function info = getFactorialStructure()
%--------------------------------------------------------------------------
% DESIGN & FACTORIAL PARAMETERS
%--------------------------------------------------------------------------
info.CongruenceLevels = ["compatible", "incompatible"];
info.nCongruenceLevels = length(info.CongruenceLevels);

info.ContextLevels = ["kitchen", "office", "workshop"];
info.nContextLevels = length(info.ContextLevels);

info.ActionLevels = ["cutting", "grating", "whisking";...
                     "hole-punching", "stamping", "stapling";...
                     "hammering", "painting", "sawing"];
info.nActionLevels = length(info.ActionLevels);

info.ProbeTypeLevels = ["context", "action"]';
info.nProbeTypeLevels = length(info.ProbeTypeLevels);

info.ProbeLevels = [reshape(info.ActionLevels', [1 9]), info.ContextLevels];
info.nProbeLevels = length(info.ProbeLevels);

info.PresTimeLevels = [2:1:6 8]; % nr x 16.6ms
info.nPresTimeLevels = length(info.PresTimeLevels);

info.CorrectResponses = ["yes", "no"];
info.nCorrectResponses = length(info.CorrectResponses);

% FACTORIAL STRUCTURE : IVs (probeTypes, Probes, Durations)
info.factorialStructure = [info.nCongruenceLevels, info.nPresTimeLevels,...
                           info.nProbeLevels, info.nCorrectResponses];
info.factorialStructureSimplified = [...
    info.nCongruenceLevels, info.nProbeTypeLevels, info.nPresTimeLevels];

% STIMULUS LEVEL FACTORS
info.ViewLevels = ["frontal", "lateral"];
info.nViewLevels = length(info.ViewLevels);

info.ActorLevels = ["a1", "a2"];
info.nActorLevels = length(info.ActorLevels);

info.ContextExemplarLevels = ["1", "2"];
info.nContextExemplarLevels = length(info.ContextExemplarLevels);

end