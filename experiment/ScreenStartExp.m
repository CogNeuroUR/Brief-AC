function ScreenStartExp(window, Cfg, tmax)
  % Shows a pause screen and waits for either "Space" key press
  % or for the time to exceed tmax.
  
  % Set the blend funciton for the screen
  Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

  % Get the size of the on screen window in pixels
  % For help see: Screen WindowSize?
  [screenXpixels, screenYpixels] = Screen('WindowSize', window);

  % Get the centre coordinate of the window in pixels
  heightRect = RectHeight(Cfg.Screen.rect);


  % Draw text in the middle of the screen in Courier in white
  Screen('TextSize', window, Cfg.Messages.SizeTxtBig);
  Screen('TextFont', window, Cfg.Messages.TextFont);

  Screen('TextStyle', window, 1); % bold
  %DrawFormattedText(window, 'Welcome!', 'center', round(heightRect/3), [255 255 255]); % EN
  DrawFormattedText(window, 'Willkommen!', 'center', round(heightRect/3.5), [255 255 255]); % DE

  Screen('TextSize', window, Cfg.Messages.SizeTxtMid);
  DrawFormattedText(window, 'Mögliche Antworten:', 'center', round(heightRect/2.3), [255 255 255]);

  Screen('TextStyle', window, 0); % normal
  if isequal(Cfg.probe.Yes, 'left')
    % EN
    %DrawFormattedText(window, 'YES : Left Arrow', 'center', screenYpixels * 0.5, [255 255 255]); 
    %DrawFormattedText(window, 'NO : Right Arrow', 'center', screenYpixels * 0.6, [255 255 255]);
    % DE
    DrawFormattedText(window, 'JA : "Linker Pfeil"', 'center', screenYpixels * 0.5, [255 255 255]);
    DrawFormattedText(window, 'NEIN : "Rechter Pfeil"', 'center', screenYpixels * 0.57, [255 255 255]);
  else
    % EN
    %DrawFormattedText(window, 'YES : Right Arrow', 'center', screenYpixels * 0.5, [255 255 255]); 
    %DrawFormattedText(window, 'NO : Left Arrow', 'center', screenYpixels * 0.6, [255 255 255]);
    % DE
    DrawFormattedText(window, 'JA : Rechter Pfeil', 'center', screenYpixels * 0.5, [255 255 255]);
    DrawFormattedText(window, 'NEIN : Linker Pfeil', 'center', screenYpixels * 0.57, [255 255 255]);
  end

  Screen('TextStyle', window, 0); % italic
  % EN
  %DrawFormattedText(window, 'To start experiment, press "Space"!', 'center',...
  %                  screenYpixels * 0.80, [128 128 128]);
  % DE
  DrawFormattedText(window, 'Um das Experiment zu starten, drücken Sie die "Leertaste"!', 'center',...
                    screenYpixels * 0.80, [128 128 128]);
  
  % Flip to the screen
  Screen('Flip', window);

  waitForSpacekey(tmax)
end