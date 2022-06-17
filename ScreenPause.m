function ScreenPause(window, Cfg, tmax)
  % Shows a pause screen and waits for either "Space" key press
  % or for the time to exceed tmax.
  
  % Set the blend funciton for the screen
  Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

  % Get the size of the on screen window in pixels
  % For help see: Screen WindowSize?
  [screenXpixels, screenYpixels] = Screen('WindowSize', window);

  % Get the centre coordinate of the window in pixels
  % For help see: help RectCenter
  [xCenter, yCenter] = RectCenter(Cfg.Screen.rect);

  % Draw text in the middle of the screen in Courier in white
  Screen('TextFont', window, Cfg.Messages.TextFont);

  % Suppress echo to the command line for keypresses
  ListenChar(2);

  spaceKey = KbName('space'); 
  pressed = false; 

  RestrictKeysForKbCheck([spaceKey]);

  % Countdown : Wait tmax
  tStart = GetSecs;
  t_left = tmax;
  %wait = true;
  while true
    % Countdown
    if t_left > 0
      Screen('TextSize', window, Cfg.Messages.SizeTxtBig);
      %DrawFormattedText(window, 'Time for a short break!', 'center',
      %'center', [255 255 255]); % EN
      DrawFormattedText(window, 'Zeit für eine kurze Pause!', 'center', 'center', [255 255 255]); % DE
      
      %tstring = sprintf('Time left : %d seconds.', t_left); % EN
      tstring = sprintf('Verbleibende Zeit : %d Sekunden.', t_left); % DE
      Screen('TextSize', window, Cfg.Messages.SizeTxtMid);
      DrawFormattedText(window, tstring, 'center', screenYpixels * 0.75, [128 128 128]);
      
      %DrawFormattedText(window, 'When ready, press and hold "Space bar" .', 'center',...
      %                  screenYpixels * 0.85, [128 128 128]); % EN
      DrawFormattedText(window, 'Wenn Sie bereit sind, halten Sie die "Leertaste" gedrückt.', 'center',...
                        screenYpixels * 0.85, [128 128 128]); % DE
      
      % Flip to the screen
      Screen('Flip', window);
    
      % decrement
      t_left = t_left - 1;
      WaitSecs(1);
    end
    
    % Check if any unrestricted key (spaceKey here) was pressed
    WaitSecs(0.01); % this time shortens the percieved "tmax"
    [keyIsDown, keyTime, keyCode] = KbCheck;
    
    % Break if SpaceBar was pressed
    if(keyIsDown)
      % Flip to the screen
      Screen('Flip', window);
      break;
    end
         
    % Break if no key was pressed until "the end of time"
    if (GetSecs - tStart) > tmax
      % Flip to the screen
      Screen('Flip', window);
      break; 
    end

  end % while

  WaitSecs(1); % wait for another second, to give participants time to start.

  % reset the keyboard input checking for all keys
  RestrictKeysForKbCheck([]);
  % re-enable echo to the command line for key presses (Ctrl+C if not)
  ListenChar(1)
end