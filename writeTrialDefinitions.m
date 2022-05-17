function writeTrialDefinitions(TRD, factorialStructure, fileName)
% Write TRD function
  if isempty(fileName)
      fid = 1;
  else
      %THIS OPENS A TEXT FILE FOR WRITING
      fid = fopen(fileName, 'w');
      fprintf(1, 'Creating file %s ...', fileName);
  end

  %WRITE DESIGN INFO
  fprintf(fid, '%4d', factorialStructure);
  
  
  nTrials = length(TRD);
  for iTrial = 1:nTrials
      nPages = length(TRD(iTrial).pictures);
      
      %STORE TRIALDEFINITION IN FILE
      fprintf(fid, '\n'); %New line for new trial
      fprintf(fid, '%4d', TRD(iTrial).code);
      fprintf(fid, '\t%4d', TRD(iTrial).tOnset);
      for iPage = 1:nPages
          %TWO ENTRIES PER PAGE: 1) Picture, 2) Duration
          fprintf(fid, '\t%4d %4d', TRD(iTrial).pictures(iPage), TRD(iTrial).durations(iPage));
      end
      fprintf(fid, '\t%4d', TRD(iTrial).startRTonPage);
      fprintf(fid, '\t%4d', TRD(iTrial).endRTonPage);
      fprintf(fid, '\t%4d', TRD(iTrial).correctResponse);
  end
  if fid > 1
      fclose(fid);
  end

  fprintf(1, '\nDONE\n'); %JUST FOR THE COMMAND WINDOW
end