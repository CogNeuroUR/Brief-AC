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

%Cfg.Screen.rect = windowRect;
Cfg.Screen.rect = [0, 0, 1920, 1080]; % full screen

% Colors
Cfg.report.textColor = [175 175 175]; % light gray

tstring = 'KÜCHE, BÜRO UND WERKSTATT : VERRÜHRQQ EN, STEMPELN UND HÄMMERN';

%==========================================================================
% Rest of REPORT SCREEN PARAMETERS
%==========================================================================
[xCenter, yCenter] = RectCenter(Cfg.Screen.rect);
widthRect = RectWidth(Cfg.Screen.rect);
heightRect = RectHeight(Cfg.Screen.rect);
Cfg.report.x = widthRect/3.5;
Cfg.report.y= heightRect/3.5;
%==========================================================================
% OTHER APPEARANCE PARAMETERS
%==========================================================================
Hratio2fhd = (Cfg.Screen.rect(4) - Cfg.Screen.rect(2)) / 1080;
Cfg.Messages.SizeTxtBig = round(60 * Hratio2fhd); % 70 for full screen (FHD)
Cfg.Messages.SizeTxtMid = round(45 * Hratio2fhd); % 50 for full screen (FHD)
Cfg.Messages.TextFont = 'Arial';

%==========================================================================
drawProbeText(window, Cfg, tstring)

% Flip to the screen
Screen('Flip', window);

% Wait for a key press
KbStrokeWait;

% Clear the screen
sca;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Draw text function
function drawProbeText(window, Cfg, tstring)
  % Draws a (text) probe on screen
  
  % Default parameters:
  % 1) Size
  Screen('TextSize', window, Cfg.Messages.SizeTxtBig);
  
  % 2) Font
  Screen('TextFont', window, Cfg.Messages.TextFont);
  
  % Get the centre coordinate of the window
  xCenter = Cfg.report.x;
  yCenter = Cfg.report.y;

  % Set up alpha-blending for smooth (anti-aliased) lines (seems necessary!)
  Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

  % Draw text
  DrawFormattedText(window, tstring, 'center', 'center', Cfg.report.textColor); 

end
