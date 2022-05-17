% Clear the workspace and the screen
close all;
clear;
sca


% First perhaps change the scale factor to 1.25 or back to 1, then
addpath(genpath('/usr/share/psychtoolbox-3/'))
PsychDebugWindowConfiguration;

screens = Screen('Screens');
screenNumber = max(screens);
% Define black, white and grey
black = BlackIndex(screenNumber);
white = WhiteIndex(screenNumber);
grey = white / 2;

% Open an on screen window and color it grey
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);

% Set the blend funciton for the screen
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

[window, rect] = PsychImaging('OpenWindow', 0, 0.5);
Screen('TextSize', window, 70);
Screen('TextFont', window, 'Verdana');

Screen('TextSize', window, 70);
Screen('TextFont', window, 'Verdana');
text_ = sprintf('Experiment has ended!\n Thanks for your participation!');
DrawFormattedText(window, text_, 'center', 'center', white);

Screen('TextSize', window, 50);
DrawFormattedText(window, 'The window will automatically close in 5 seconds.', 'center',...
    screenYpixels * 0.75, [128 128 128]);
Screen('Flip', window);

% Wait a second before closing the screen
WaitSecs(5);

% Now we have drawn to the screen we wait for a keyboard button press (any
% key) to terminate the demo
%KbStrokeWait;

% Clear the screen
sca;