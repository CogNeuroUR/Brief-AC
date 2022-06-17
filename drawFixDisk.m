function drawFixDisk(window, Cfg)
  % Draws a white cross overlayed on a black disk
  % "Inspired" from http://peterscarfe.com/fixationcrossdemo.html :)
  
  % Default parameters:
  % 1) Colors
  %Cfg.diskColor = [0 0 0]; % black
  %Cfg.crossColor = [255 255 255]; % white
  
  % 2) Sizes (GIVEN IN CONFIG)
  %Cfg.fixCrossDimPix = 30; % size of the cross arms
  %Cfg.fixLineWidthPix = 7.37; % width of cross arms (>7.37 crashes on Ubuntu)
  %Cfg.fixDiskRadius = 35; % radius of disk
  
  % Get the centre coordinate of the window
  [xCenter, yCenter] = RectCenter(Cfg.Screen.rect);

  % Now we set the coordinates (these are all relative to zero we will let
  % the drawing routine center the cross in the center of our monitor for us)
  xCoords = [-Cfg.fixCrossDimPix Cfg.fixCrossDimPix 0 0];
  yCoords = [0 0 -Cfg.fixCrossDimPix Cfg.fixCrossDimPix];
  allCoords = [xCoords; yCoords];

  % Set up alpha-blending for smooth (anti-aliased) lines (seems necessary!)
  Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

  % Draw disk
  %Screen('gluDisk', window, Cfg.diskColor, xCenter, yCenter, Cfg.fixDiskRadius);

  % Draw the fixation cross in white, set it to the center of our screen and
  % set good quality antialiasing
  Screen('DrawLines', window, allCoords,...
    Cfg.fixLineWidthPix, Cfg.crossColor, [xCenter yCenter], 2);
end