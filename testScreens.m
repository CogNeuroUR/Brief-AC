%% Clear the workspace and the screen
close all;
clearvars;
sca


%% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

%Screen('Preference','TextEncodingLocale', '.1252')
% Get the screen numbers
screens = Screen('Screens');


% Select the external screen if it is present, else revert to the native
% screen
screenNumber = max(screens);

% Define black, white and grey
black = BlackIndex(screenNumber);  

white = WhiteIndex(screenNumber);
grey = white / 2;

Cfg.Messages.TextFont = 'Verdana';
Cfg.Messages.SizeTxtBig = 60; % 70 for full screen (FHD)
Cfg.Messages.SizeTxtMid = 45; % 50 for full screen (FHD)

Cfg.Screen.rect = [1, 1, 1920, 1080]; % part
%Cfg.Screen.rect = [0, 0, 3849, 2169]; % full screen
windowRect = Cfg.Screen.rect;

Cfg.probe.keyYes = {'left'};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Start screen
tmax = 30;

% Open an on screen window and color it grey
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black, windowRect);

ScreenStartExp(window, Cfg, tmax)
sca;

%% Preparation Screen
tmax = 10;

% Open an on screen window and color it grey
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black, windowRect);
 
ScreenPreparation(window, Cfg, tmax)
sca;

%% Pause Screen
tmax = 10;

% Open an on screen window and color it grey
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black, windowRect);

ScreenPause(window, Cfg, tmax)
sca;

%% End screen
% Open an on screen window and color it grey
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black, windowRect);

ScreenEnd(window, Cfg)
sca;