function drawProbeText(window, Cfg, tstring)
  % Draw text
  DrawFormattedText(window, tstring, 'center', 'center', Cfg.probe.textColor); 
  % Flip to the screen
  %Screen('Flip', window);
end