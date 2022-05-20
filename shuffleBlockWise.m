function TRD = shuffleBlockWise(TRD, lBlock, column)
  nTrials = length(TRD);
  % check if lBlocks is multiple of nTrials
  if mod(nTrials, lBlock) ~= 0
    error('lBlocks is not a multiple of nTrials!');
  else
    nBlocks = nTrials / lBlock;
  end

  % sanity check : fields
  if ~isequal(column, 'all')
    if ~ismember(fields(TRD), column)
      error('Given "column" was not found in the list of fields!');
    end
  end
  
  for iBlock=nBlocks:-1:1
    % find indices of trials within this block
    indices = (iBlock-1)*lBlock + 1 : (iBlock)*lBlock;
    Block = TRD(indices);
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 
    % place here the assignment (for) loop and used 'Block' in place of 'TRD'
    idx = randperm(length(Block));
    
    if isequal(column, 'all')
      % shuffle rows for all fields
      [Block(:)] = Block(idx);
    else % shuffle rows only for given field/column
      % iterate back over blocks
      [Block(:).(column)] = Block(idx).(column);
    end

    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    % In the end assign the updated block
    TRD(indices) = Block;
  end
end