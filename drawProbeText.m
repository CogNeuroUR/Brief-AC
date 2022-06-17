function drawProbeText(window, Cfg, tstring)
  % Draws a (text) probe on screen
  
  % Default parameters:
  % 1) Size
  %Screen('TextSize', window, Cfg.Messages.SizeTxtBig);
  Screen('TextSize', window, Cfg.Messages.SizeTxtMid);
  
  % 2) Font
  Screen('TextFont', window, Cfg.Messages.TextFont);
  
  % Get the centre coordinate of the window
  %xCenter = Cfg.probe.x;
  %yCenter = Cfg.probe.y;

  % Set up alpha-blending for smooth (anti-aliased) lines (seems necessary!)
  Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

  % Draw text
  DrawFormattedText(window, tstring, 'center', 'center', Cfg.probe.textColor); 
  % Flip to the screen
  %Screen('Flip', window);
end