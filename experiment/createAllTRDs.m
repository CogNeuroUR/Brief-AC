%% Define paramters
nBlocks = 4;
lBlock = 144;
writeTRD = 1;
lResKeys = [[0, 1]; [1, 0]];

N_subjects = 6;

%% Run 'fillTRD' in a loop and oscillate response keys

for iSubject=1:N_subjects
  if mod(iSubject, 2) == 0
    disp('right');
    [TRD, info] = fillTRD(iSubject, nBlocks, lBlock, lResKeys(1, :), writeTRD);
    save(sprintf('SUB-%02d_right.mat', iSubject), 'TRD');
  else
    disp('left');
    [TRD, info] = fillTRD(iSubject, nBlocks, lBlock, lResKeys(2, :), writeTRD);
    save(sprintf('SUB-%02d_left.mat', iSubject), 'TRD');
  end
end