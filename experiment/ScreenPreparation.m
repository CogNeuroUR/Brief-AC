function ScreenPreparation(window, Cfg, tmax)
  % Shows a preparation screen with a countdown and waits for the time to exceed tmax.
  
  % Set the blend funciton for the screen
  Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
  % Draw text in the middle of the screen in Courier in white
  Screen('TextSize', window, Cfg.Messages.SizeTxtMid);
  Screen('TextFont', window, Cfg.Messages.TextFont);

  % Wait tmax
  tStart = GetSecs;
  t_left = tmax;
  wait = true;
  while true
    % Countdown
    if t_left > 0
      %tstring = sprintf('First trial will automatically start in %d seconds.', t_left);
      tstring = sprintf('Erster Versuchsdurchgang wird automatisch in %d Sekunden starten.', t_left);
      DrawFormattedText(window, tstring, 'center', 'center', [128 128 128]);
      % Flip to the screen
      Screen('Flip', window);
      
      % decrement
      t_left = t_left - 1;
      WaitSecs(1);
    end
    % Break if no key was pressed until "the end of time"
    if (GetSecs - tStart) > tmax, wait=false; break; end
  end
end