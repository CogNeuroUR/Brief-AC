function TRD = shuffleConditionalBlockWise(TRD, lBlock)
  nTrials = length(TRD);
  % check if lBlocks is multiple of nTrials
  if mod(nTrials, lBlock) ~= 0
    error('lBlocks is not a multiple of nTrials!');
  else
    nBlocks = nTrials / lBlock;
  end
  
  for iBlock=nBlocks:-1:1
    % find indices of trials within this block
    indices = (iBlock-1)*lBlock + 1 : (iBlock)*lBlock;
    Block = TRD(indices);
    codes = [Block.code];
 
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    % Schwarzbach 2021 - ASF course
    % Ensure that no condition is ever repeated 
    % (i.e., the code of trial n is different from the code of trial n+1)
    doRepeat = 1;
    iter = 0;
    fprintf(1, 'BLOCK%d ITERATION: %06d', iBlock, iter);
    while doRepeat
      iter = iter + 1;
      if mod(iter, 50) == 0
          fprintf(1, '\b\b\b\b\b\b%06d', iter);
      end
      
      % We don't want conditions to repeat themselves at all, so we 
      % use a brute-force algorithm, in which we randomize the conditions 
      % and then check that no two equal conditions are next to each other. 
      % Otherwise, we run another iteration
      
      % First randomize
      randCondIdx = randperm(length(Block));
      shuffledCodes = codes(randCondIdx)';
      % Check the difference between randomized codes (0's indicate that
      % similar codes are adjacent; thus, 2 adjacent zeros would be bad for
      % us)
      diffVec = [diff(shuffledCodes); NaN]; %0 indicates one repetition (streak of 2)
      diffVec2 = [diff(diffVec); NaN]; %0 indicates two repetitions  (streak of 3)
      diffVec3 = [diff(diffVec2); NaN]; %0 indicates three repetitions (streak of 4)
      
      if ~any(diffVec==2)
        fprintf(1, '\n');
        doRepeat = 0;
      end
    end
    % Take the successfully shuffled permutation and permute the
    % TrialDefinitions before outputting them
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Block = Block(randCondIdx);

    % In the end assign the updated block
    TRD(indices) = Block;
  end
end