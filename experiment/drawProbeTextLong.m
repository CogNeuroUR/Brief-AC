function drawProbeTextLong(window, Cfg, tstring)
  % Draws a complex (text) probe on screen (as in Hafri et al. 2013)
  % 
  % Did you see
  % "office"?
  %
  % [Yes]   [No]
  
  % Default parameters:
  % 1) Size
  %Screen('TextSize', window, Cfg.Messages.SizeTxtBig);
  Screen('TextSize', window, Cfg.Messages.SizeTxtMid);
  
  % 2) Font
  Screen('TextFont', window, Cfg.Messages.TextFont);
  
  % Get the centre coordinate of the window
  %xCenter = Cfg.probe.x;
  %yCenter = Cfg.probe.y;
  [xCenter, yCenter] = RectCenter(Cfg.Screen.rect);

  % Set up alpha-blending for smooth (anti-aliased) lines (seems necessary!)
  Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

  % Draw question's prefix
  question = 'Did you see';
  DrawFormattedText(window, question, 'center', yCenter-100, Cfg.probe.textColor);
  % Draw suffix
  suffix = ['"' tstring '"?'];
  DrawFormattedText(window, suffix, 'center', 'center', Cfg.probe.textColor);

  % Draw response keys
  DrawFormattedText(window, 'Yes', round(Cfg.Screen.rect(3)/3), round(2*Cfg.Screen.rect(4)/3), Cfg.probe.textColor);
  DrawFormattedText(window, 'No', round(2*Cfg.Screen.rect(3)/3), round(2*Cfg.Screen.rect(4)/3), Cfg.probe.textColor);
  % Flip to the screen
  %Screen('Flip', window);
end