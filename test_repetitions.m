%% 
TRD = fillTRD(4, 72, [0,1], 0)

%%
probeType = unique([TRD(TRD(:).probeType == 'action').probeType], 'rows')