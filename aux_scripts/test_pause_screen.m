%%
% Clear the workspace and the screen
close all;
clearvars;
sca


%%
% Here we call some default settings for setting up Psychtoolbox
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

% Open an on screen window and color it grey
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);


Cfg.Screen.rect = windowRect;
Cfg.Messages.TextFont = 'Verdana';
Cfg.Messages.SizeTxtBig = 60; % 70 for full screen (FHD)
Cfg.Messages.SizeTxtMid = 45; % 50 for full screen (FHD)

PauseScreenNew(window, Cfg,30);           


% Now we have drawn to the screen we wait for a keyboard button press (any
% key) to terminate the demo
%KbStrokeWait;

% Clear the screen
sca;

 %%

%% New



%% Test waitForSpacekey

waitForSpacekey(2)

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PauseScreenNew(window, Cfg, tmax)
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
        %DrawFormattedText(window, 'Time for a short break!', 'center',
        %'center', [255 255 255]); % EN
      Screen('TextSize', window, Cfg.Messages.SizeTxtBig);
      DrawFormattedText(window, 'Zeit für eine kurze Pause!', 'center', 'center', [255 255 255]); % DE
      
      %tstring = sprintf('Time left : %d seconds.', t_left); % EN
      tstring = sprintf('Verbleibende Zeit : %d Sekunden.', t_left); % DE
      Screen('TextSize', window, Cfg.Messages.SizeTxtMid);
      DrawFormattedText(window, tstring, 'center', screenYpixels * 0.75, [128 128 128]);
      
      %DrawFormattedText(window, 'When ready, press and hold "Space bar" .', 'center',...
      %                  screenYpixels * 0.85, [128 128 128]); % EN
      DrawFormattedText(window, 'Wenn Sie bereit sind, halten Sie die "Leertaste" gedrückt.', 'center',...
                        screenYpixels * 0.90, [128 128 128]); % DE
      
      % Flip to the screen
      Screen('Flip', window);
    
      % decrement
      t_left = t_left - 1;
      WaitSecs(1);
    end
    
    % Check if any unrestricted key (spaceKey here) was pressed
    WaitSecs(0.01); % this time shortens the percieved "tmax"
    [keyIsDown, keyTime, keyCode] = KbCheck;
    
    % Break if no key was pressed until "the end of time"
    if(keyIsDown), break; end
         
    % Break if no key was pressed until "the end of time"
    if (GetSecs - tStart) > tmax, break; end

  end

  % reset the keyboard input checking for all keys
  %RestrictKeysForKbCheck; % calling it like that prevents further input check
  RestrictKeysForKbCheck([]);
  % re-enable echo to the command line for key presses (Ctrl+C if not)
  ListenChar(1)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PauseScreen(window, Cfg, tmax)
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
  Screen('TextSize', window, 70);
  Screen('TextFont', window, 'Verdana');
  DrawFormattedText(window, 'Break time!\nTake a your time to refresh.', 'center', 'center', [255 255 255]);

  DrawFormattedText(window, 'When ready, press "Space".', 'center',...
      screenYpixels * 0.75, 0.5 );

  % Flip to the screen
  Screen('Flip', window);

  waitForSpacekey(tmax)
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function waitForSpacekey(tmax)
  % Waits (maximum tmax-seconds) for the "Space" key
  % suppress echo to the command line for keypresses
  ListenChar(2);

  spaceKey = KbName('space');
  pressed = false; 

  RestrictKeysForKbCheck([spaceKey]);

  tStart = GetSecs;
  
  while ~pressed
    WaitSecs(0.1);
    % Check if any unrestricted key (spaceKey here) was pressed
    [keyIsDown, keyTime, keyCode] = KbCheck;
    
    % Break if key was pressed
    if(keyIsDown), pressed=true; break; end
    
    % Break if no key was pressed until "the end of time"
    if (GetSecs - tStart) > tmax, pressed=true; break; end
  end

  % reset the keyboard input checking for all keys
  RestrictKeysForKbCheck;
  % re-enable echo to the command line for key presses (Ctrl+C if not)
  ListenChar(1)
end