%% Test fixation function
% "Inspired" from http://peterscarfe.com/fixationcrossdemo.html

sca;
close all;
clearvars;

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if avaliable
screenNumber = max(screens);

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;

% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);

Cfg.Screen.rect = windowRect;

% Colors
diskColor = [0 0 0];

drawFixDisk(window, Cfg);


% Flip to the screen
Screen('Flip', window);

% Wait for a key press
KbStrokeWait;

% Clear the screen
sca;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Disk fixation
function drawFixDisk(window, Cfg)
  % Draws a white cross overlayed on a black disk
  
  % Default parameters:
  % 1) Colors
  diskColor = [0 0 0]; % black
  crossColor = [255 255 255]; % white
  % 2) Sizes
  fixCrossDimPix = 40; % size of the cross arms
  lineWidthPix = 7.37; % width of cross arms (>7.37 crashes on Ubuntu)
  diskRadius = 45; % radius of disk
  
  % Get the centre coordinate of the window
  [xCenter, yCenter] = RectCenter(Cfg.Screen.rect);

  % Now we set the coordinates (these are all relative to zero we will let
  % the drawing routine center the cross in the center of our monitor for us)
  xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
  yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
  allCoords = [xCoords; yCoords];

  % Set up alpha-blending for smooth (anti-aliased) lines (seems necessary!)
  Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

  % Draw disk
  Screen('gluDisk', window, diskColor, xCenter, yCenter, diskRadius);

  % Draw the fixation cross in white, set it to the center of our screen and
  % set good quality antialiasing
  Screen('DrawLines', window, allCoords,...
    lineWidthPix, crossColor, [xCenter yCenter], 2);
end