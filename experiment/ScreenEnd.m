function ScreenEnd(window, Cfg)
  % Shows a pause screen and waits for either "Space" key press
  % or for the time to exceed tmax.
  vLineSpacing = 2;
  
  % Set the blend funciton for the screen
  Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

  % Get the size of the on screen window in pixels
  % For help see: Screen WindowSize?
  [screenXpixels, screenYpixels] = Screen('WindowSize', window);

  % Get the centre coordinate of the window in pixels
  % For help see: help RectCenter
  [xCenter, yCenter] = RectCenter(Cfg.Screen.rect);

  % Draw text in the middle of the screen in Courier in white
  Screen('TextSize', window, Cfg.Messages.SizeTxtBig);
  Screen('TextFont', window, Cfg.Messages.TextFont);
  
  %text_end = sprintf('Experiment has ended!\n'); % EN
  text_end = sprintf('Das Experiment ist beendet!\n'); % DE 
  %text_thank = sprintf('\n\nThanks for your participation!'); % EN
  text_thank = sprintf('\n\n\nVielen Dank für Ihre Teilnahme!'); % DE
  

  % Countdown : Wait t_left
  tmax = 5;
  t_left = tmax; % seconds
  tStart = GetSecs;
  while true
    % Countdown
    if t_left > 0
      Screen('TextSize', window, Cfg.Messages.SizeTxtBig);
      DrawFormattedText(window, text_end, 'center', 'center', [255 255 255]);
      DrawFormattedText(window, text_thank, 'center', 'center', [255 255 255]);

      Screen('TextSize', window, Cfg.Messages.SizeTxtMid);
      %tstring = sprintf('The window will automatically close in %d seconds.', t_left); % EN
      tstring = sprintf('Das Fenster wird nach %d Sekunden automatisch geschlossen.', t_left); % DE
      DrawFormattedText(window, tstring, 'center', screenYpixels * 0.75, [128 128 128]);

      % Flip to the screen
      Screen('Flip', window);
    
      % decrement
      t_left = t_left - 1;
      WaitSecs(1);
    end
  
  % Break if no key was pressed until "the end of time"
  if (GetSecs - tStart) > tmax, disp('break'); break; end
  end
end