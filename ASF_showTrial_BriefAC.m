function TrialInfo = ASF_showTrial_BriefAC(atrial, windowPtr, Stimuli, Cfg)
%
%derived from ASF_showTrialSample (initially written by: jens schwarzbach)
%shows a dot at position dotPosX, and dotPosY, which is extracted from two
%userdefined columns in the trd
%Thus make sure that you have a proper trd and Cfg.userDefinedSTMcolumns = 2;
%%TO USE IT AS A STARTING POINT FOR YOUR PLUGIN-DEVELOPMENTS
% OV 22

% VBLTimestamp system time (in seconds) when the actual flip has happened
% StimulusOnsetTime An estimate of Stimulus-onset time
% FlipTimestamp is a timestamp taken at the end of Flip's execution
VBLTimestamp = 0; StimulusOnsetTime = 0; FlipTimestamp = 0; Missed = 0;
Beampos = 0;

StartRTMeasurement = 0; EndRTMeasurement = 0;
timing = [0, VBLTimestamp, StimulusOnsetTime, FlipTimestamp, Missed, Beampos];
nPages = length(atrial.pageNumber);
timing(nPages, end) = 0;
this_response = [];

%ON PAGES WITH WITH RESPONSE COLLECTION MAKE SURE THE CODE RETURNS IN TIME
%BEFORE THE NEXT VERTICAL BLANK. FOR EXAMPLE IF THE RESPONSE WINDOW IS 1000
%ms TOLERANCE MAKES THE RESPONSE COLLECTION CODE RETURN AFTER 1000ms-0.3
%FRAMES, I.E. AFTER 995 ms AT 60Hz
toleranceSec = Cfg.Screen.monitorFlipInterval*0.3; 

%HOWEVER, THIS MUST NOT BE LONGER THAN ONE FRAME
%DURATION. EXPERIMENTING WITH ONE QUARTER OF A FRAME
responseGiven = 0;
this_response.key = [];
this_response.RT = [];
this_response.msg = [];


%--------------------------------------------------------------------------
%TRIAL PRESENTATION HAS SEVERAL PHASES
% 1) WAIT FOR THE RIGHT TIME TO START TRIAL PRESENTATION. THIS MAY BE 
%    IMMEDIATELY OR USER DEFINED (E.G. IN fMRI EXPERIMENTS)
%
% 2) LOOP THROUGH PAGE PRESENTATIONS WITHOUT RESPONSE COLLECTION
%
% 3) LOOP THROUGH PAGE PRESENTATIONS WHILE CHECKING FOR USER INPUT/RESPONSES
%
% 4) LOOP THROUGH PAGE PRESENTATIONS WITHOUT RESPONSE COLLECTION 
%    (AFTER RESPONSE HAS BEEN GIVEN)
%
% 5) FEEDBACK
%--------------------------------------------------------------------------

%IF YOU WANT TO DO ANY OFFLINE STIMULUS RENDERING (I.E. BEFORE THE TRIAL
%STARTS), PUT THAT CODE HERE

%LOG DATE AND TIME OF TRIAL
strDate = datestr(now); %store when trial was presented

%--------------------------------------------------------------------------
% PHASE 1) WAIT FOR THE RIGHT TIME TO START TRIAL PRESENTATION. THIS MAY BE
% IMMEDIATELY OR USER DEFINED (E.G. IN fMRI EXPERIMENTS)
%--------------------------------------------------------------------------

% %JS METHOD: LOOP
% %IF EXTERNAL TIMING REQUESTED (e.g. fMRI JITTERING)
% if Cfg.useTrialOnsetTimes
%     while((GetSecs- Cfg.experimentStart) < atrial.tOnset)
%     end
% end
% %LOG TIME OF TRIAL ONSET WITH RESPECT TO START OF THE EXPERIMENT
% %USEFUL FOR DATA ANALYSIS IN fMRI
% tStart = GetSecs - Cfg.experimentStart;

%SUGGESTED METHOD: TIMED WAIT
%IF EXTERNAL TIMING REQUESTED (e.g. fMRI JITTERING)
if Cfg.useTrialOnsetTimes
    wakeupTime = WaitSecs('UntilTime', Cfg.experimentStart + atrial.tOnset);
else
    wakeupTime = GetSecs;
end
%LOG TIME OF TRIAL ONSET WITH RESPECT TO START OF THE EXPERIMENT
%USEFUL FOR DATA ANALYSIS IN fMRI
tStart = wakeupTime - Cfg.experimentStart;


if Cfg.Eyetracking.doDriftCorrection
    EyelinkDoDriftCorrect(Cfg.el);
end

%--------------------------------------------------------------------------
%END OF PHASE 1
%--------------------------------------------------------------------------

%MESSAGE TO EYELINK
Cfg = ASF_sendMessageToEyelink(Cfg, 'TRIALSTART');

%--------------------------------------------------------------------------
% PHASE 2) LOOP THROUGH PAGE PRESENTATIONS WITHOUT RESPONSE COLLECTION
%--------------------------------------------------------------------------
%CYCLE THROUGH PAGES FOR THIS TRIAL
atrial.nPages = length(atrial.pageNumber);
for i = 1:atrial.startRTonPage-1
    if (i > atrial.nPages)
        break;
    else
        %PUT THE APPROPRIATE TEXTURE ON THE BACK BUFFER
        Screen('DrawTexture', windowPtr, Stimuli.tex(atrial.pageNumber(i)));
        % Draw fixation disk
        if (i > 1) && (i < 5) % TODO : replace with "end"
          drawFixDisk(windowPtr, Cfg)
        end
        
        
        

        
        %PRESERVE BACK BUFFER IF THIS TEXTURE IS TO BE SHOWN
        %AGAIN AT THE NEXT FLIP
        bPreserveBackBuffer = atrial.pageDuration(i) > 1;
        
        %FLIP THE CONTENT OF THIS PAGE TO THE DISPLAY AND PRESERVE IT IN THE
        %BACKBUFFER IN CASE THE SAME IMAGE IS TO BE FLIPPED AGAIN TO THE SCREEN
        [VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] =...
            ASF_xFlip(windowPtr, Stimuli.tex(atrial.pageNumber(i)),...
            Cfg, bPreserveBackBuffer);
        
        %SET TRIGGER (PARALLEL PORT AND EYELINK)
        ASF_setTrigger(Cfg, atrial.pageNumber(i));
        
        
        %LOG WHEN THIS PAGE APPEARED
        timing(i, 1:6) = [atrial.pageDuration(i), VBLTimestamp,...
            StimulusOnsetTime FlipTimestamp Missed Beampos];
       
          
          
        %WAIT OUT STIMULUS DURATION IN FRAMES. WE USE PAGE FLIPPING RATHER 
        %THAN A TIMER WHENEVER POSSIBLE BECAUSE GRAPHICS BOARDS PROVIDE 
        %EXCELLENT TIMING; THIS IS THE REASON WHY WE MAY WANT TO KEEP A 
        %STIMULUS IN THE BACKBUFFER (NONDESTRUCTIVE PAGE FLIPPING)
        %NOT ALL GRAPHICS CARDS CAN DO THIS. FOR CARDS WITHOUT AUXILIARY
        %BACKBUFFERS WE COPY THE TEXTURE EXPLICITLY ON THE BACKBUFFER AFTER
        %IT HAS BEEN DESTROYED BY FLIPPING
        nFlips = atrial.pageDuration(i) - 1; %WE ALREADY FLIPPED ONCE
        for FlipNumber = 1:nFlips
            %PRESERVE BACK BUFFER IF THIS TEXTURE IS TO BE SHOWN
            %AGAIN AT THE NEXT FLIP
            bPreserveBackBuffer = FlipNumber < nFlips;
            
            %FLIP THE CONTENT OF THIS PAGE TO THE DISPLAY AND PRESERVE IT 
            %IN THE BACKBUFFER IN CASE THE SAME IMAGE IS TO BE FLIPPED
            %AGAIN TO THE SCREEN
            ASF_xFlip(windowPtr, Stimuli.tex(atrial.pageNumber(i)),...
                Cfg, bPreserveBackBuffer);
        end
    end
end
%--------------------------------------------------------------------------
%END OF PHASE 2
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% PHASE 3) LOOP THROUGH PAGE PRESENTATIONS WHILE CHECKING FOR USER 
%          INPUT/RESPONSES
%--------------------------------------------------------------------------
%SPECIAL TREATMENT FOR THE DISPLAY PAGES ON WHICH WE ALLOW REACTIONS

for i = atrial.startRTonPage:atrial.endRTonPage
    %string = '';
    %terminatorChar = 0;
    
    if (i > atrial.nPages)
        break;
    else
        %PUT THE APPROPRIATE TEXTURE ON THE BACK BUFFER
        Screen('DrawTexture', windowPtr, Stimuli.tex(atrial.pageNumber(i)));
        
        % Draw probe text (only on the last page)

        % TODO : drawProbeText() doesn't seem to work (at least visibly
        % there is no text visible on screen.
        % Draw probe text

        if (i == 5)
          [~, Probe] = decodeProbe(atrial.code, Cfg.factorialStructure, ...
                                          Cfg.factorProbeTypes, Cfg.factorProbes);
          tstring = upper(Probe);
          drawProbeText(windowPtr, Cfg, convertStringsToChars(tstring));
          %DrawFormattedText(windowPtr, convertStringsToChars(tstring), Cfg.report.x, Cfg.report.y+20, [255 255 255]);  
        end

        %DO NOT PUT THIS PAGE AGAIN ON THE BACKBUFFER, WE WILL WAIT IT OUT
        %USING THE TIMER NOT FLIPPING
        bPreserveBackBuffer = 0;
        
        %FLIP THE CONTENT OF THIS PAGE TO THE DISPLAY AND PRESERVE IT 
        %IN THE BACKBUFFER IN CASE THE SAME IMAGE IS TO BE FLIPPED
        %AGAIN TO THE SCREEN
        [VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] =...
            ASF_xFlip(windowPtr, Stimuli.tex(atrial.pageNumber(i)),...
            Cfg, bPreserveBackBuffer);
        
        %SET TRIGGER
        ASF_setTrigger(Cfg, atrial.pageNumber(i));
        
        if i == atrial.startRTonPage
            StartRTMeasurement = VBLTimestamp;
        end
        
        %STORE TIME OF PAGE FLIPPING FOR DIAGNOSTIC PURPOSES
        timing(i, 1:6) = [atrial.pageDuration(i), VBLTimestamp,...
            StimulusOnsetTime, FlipTimestamp, Missed, Beampos];
        
        pageDuration_in_sec =...
            atrial.pageDuration(i)*Cfg.Screen.monitorFlipInterval;
         
        
        [x, y, buttons, t0, t1] =...
            ASF_waitForResponse(Cfg, pageDuration_in_sec - toleranceSec);
        
        if any(buttons)
          % ShowCursor
          responseGiven = 1;
          %A BUTTON HAS BEEN PRESSED BEFORE TIMEOUT
          if Cfg.responseTerminatesTrial
            %ANY CODE THAT YOU FEEL APPROPRIATE FOR SIGNALING THAT
            %PARTICIPANT HAS PRESSED A BUTTON BEFORE THE TRIAL ENDED
            %Snd('Play','Quack')
          else
            %WAIT OUT THE REMAINDER OF THE STIMULUS DURATION WITH 
            %MARGIN OF toleranceSec
            wakeupTime = WaitSecs('UntilTime',...
                StimulusOnsetTime + pageDuration_in_sec - toleranceSec);
          end
          %FIND WHICH BUTTON IT WAS
          this_response.key = find(buttons);
          %COMPUTE RESPONSE TIME
          this_response.RT = (t1 - StartRTMeasurement)*1000; 
        end
      
        % Start screen
        if atrial.code == Cfg.startTrialCode
          WaitToStartScreen(windowPtr, Cfg, Cfg.pauseDurationMax);
        end
          
        % Pause screen
        if atrial.code == Cfg.pauseTrialCode
          PauseScreen(windowPtr, Cfg, Cfg.pauseDurationMax);
        end
        
        % End screen
        if atrial.code == Cfg.endTrialCode
          EndScreen(windowPtr, Cfg, Cfg.pauseDurationMax);
        end
        

%         if any(buttons)
%             % ShowCursor
%             responseGiven = 1;
%             %A BUTTON HAS BEEN PRESSED BEFORE TIMEOUT
%             if Cfg.responseTerminatesTrial
%                 %ANY CODE THAT YOU FEEL APPROPRIATE FOR SIGNALING THAT
%                 %PARTICIPANT HAS PRESSED A BUTTON BEFORE THE TRIAL ENDED
%                 %Snd('Play','Quack')
%             else
%                 %WAIT OUT THE REMAINDER OF THE STIMULUS DURATION WITH 
%                 %MARGIN OF toleranceSec
%                 wakeupTime = WaitSecs('UntilTime',...
%                     StimulusOnsetTime + pageDuration_in_sec - toleranceSec);
%             end
%             %FIND WHICH BUTTON IT WAS
%             this_response.key = find(buttons);
%             %this_response.msg = string;
%             %COMPUTE RESPONSE TIME
%             this_response.RT = (t1 - StartRTMeasurement)*1000; 
%        end
    end
end
%--------------------------------------------------------------------------
%END OF PHASE 3
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% PHASE 4) LOOP THROUGH PAGE PRESENTATIONS WITHOUT RESPONSE COLLECTION
% (AFTER RESPONSE HAS BEEN GIVEN) SAME AS PHASE 2
%--------------------------------------------------------------------------
%OTHER PICS
for i = atrial.endRTonPage+1:nPages
    if (i > atrial.nPages)
        break;
    else
        %PUT THE APPROPRIATE TEXTURE ON THE BACK BUFFER
        Screen('DrawTexture', windowPtr, Stimuli.tex(atrial.pageNumber(i)));
        
        %PRESERVE BACK BUFFER IF THIS TEXTURE IS TO BE SHOWN
        %AGAIN AT THE NEXT FLIP
        bPreserveBackBuffer = atrial.pageDuration(i) > 1;
        
        %FLIP THE CONTENT OF THIS PAGE TO THE DISPLAY AND PRESERVE IT 
        %IN THE BACKBUFFER IN CASE THE SAME IMAGE IS TO BE FLIPPED
        %AGAIN TO THE SCREEN
        [VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] =...
            ASF_xFlip(windowPtr, Stimuli.tex(atrial.pageNumber(i)),...
            Cfg, bPreserveBackBuffer);
        
        %SET TRIGGER (PARALLEL PORT AND EYELINK)
        ASF_setTrigger(Cfg, atrial.pageNumber(i));
        
        
        %LOG WHEN THIS PAGE APPEARED
        timing(i, 1:6) = [atrial.pageDuration(i), VBLTimestamp,...
            StimulusOnsetTime FlipTimestamp Missed Beampos];
        
        %WAIT OUT STIMULUS DURATION IN FRAMES.
        nFlips = atrial.pageDuration(i) - 1; %WE ALREADY FLIPPED ONCE
        for FlipNumber = 1:nFlips
            %PRESERVE BACK BUFFER IF THIS TEXTURE IS TO BE SHOWN
            %AGAIN AT THE NEXT FLIP
            bPreserveBackBuffer = FlipNumber < nFlips;
            
            %FLIP THE CONTENT OF THIS PAGE TO THE DISPLAY AND PRESERVE IT 
            %IN THE BACKBUFFER IN CASE THE SAME IMAGE IS TO BE FLIPPED
            %AGAIN TO THE SCREEN
            ASF_xFlip(windowPtr, Stimuli.tex(atrial.pageNumber(i)),...
                Cfg, bPreserveBackBuffer);
        end
    end
end

%--------------------------------------------------------------------------
%END OF PHASE 4
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% PHASE 5) FEEDBACK
%--------------------------------------------------------------------------
%IF YOU WANT TO FORCE A RESPONSE
if Cfg.waitUntilResponseAfterTrial && ~responseGiven
    [x, y, buttons, t0, t1] = ASF_waitForResponse(Cfg, 10);

    
    if any(buttons)
        %A BUTTON HAS BEEN PRESSED BEFORE TIMEOUT
        %responseGiven = 1; %#ok<NASGU>
        %FIND OUT WHICH BUTTON IT WAS
        this_response.key = find(buttons);
        this_response.msg = string;
        %COMPUTE RESPONSE TIME
        this_response.RT = (t1 - StartRTMeasurement)*1000;
    end
end

%TRIAL BY TRIAL FEEDBACK
if Cfg.feedbackTrialCorrect || Cfg.feedbackTrialError
    ASF_trialFeeback(...
        this_response.key == atrial.CorrectResponse, Cfg, windowPtr);
end

%--------------------------------------------------------------------------
%END OF PHASE 5
%--------------------------------------------------------------------------


%PACK INFORMATION ABOUT THIS TRIAL INTO STRUCTURE TrialInfo (THE RETURN 
%ARGUMENT). PLEASE MAKE SURE THAT TrialInfo CONTAINS THE FIELDS:
%   trial
%   datestr
%   tStart
%   Response
%   timing
%   StartRTMeasurement
%   EndRTMeasurement
%OTHERWISE DIAGNOSTIC PROCEDURES OR ROUTINES FOR DATA ANALYSIS MAIGHT FAIL
TrialInfo.trial = atrial;  %REQUESTED PAGE NUMBERS AND DURATIONS
TrialInfo.datestr = strDate; %STORE WHEN THIS HAPPENED
TrialInfo.tStart = tStart; %TIME OF TRIAL-START
TrialInfo.Response = this_response; %KEY AND RT
TrialInfo.timing = timing; %TIMING OF PAGES
TrialInfo.StartRTMeasurement = StartRTMeasurement; %TIMESTAMP START RT
TrialInfo.EndRTMeasurement = EndRTMeasurement; %TIMESTAMP END RT
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Probe decoding function
function [probeType, Probe] = decodeProbe(trialCode, factorialStructure, ...
                                          ProbeTypeLevels, ProbeLevels)
  % (ASF_)Decodes the probe type and the probe, given the trial code and the
  % factorial structure with its underlying factors.
  % Custom to "BriefAC" behavioral experiment (ActionsInContext).
  % OV 11.05.22
  %
  % Designed to be used in "ASF_showTrial" function.
  
  % Decode factors from code
  factors = ASF_decode(trialCode,factorialStructure);
  t = factors(1);   % probe type
  p = factors(2);   % probe
  %d = factors(3);   % duration
  
  probeType = ProbeTypeLevels(t+1);
  Probe = ProbeLevels(p+1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function drawFix(windowPtr, Cfg, fixColor, width)
  %OVERLAY FIXATION POINT

  length = 20;
  fromH =  Cfg.Screen.centerX + Cfg.Fixation.offsetX;
  toH = fromH;
  fromV =  Cfg.Screen.centerY + Cfg.Fixation.offsetY - length;
  toV =  Cfg.Screen.centerY + Cfg.Fixation.offsetY + length;

  Screen('DrawLine', windowPtr, fixColor, fromH, fromV, toH, toV, width);

  fromH =  Cfg.Screen.centerX + Cfg.Fixation.offsetX - length;
  toH = Cfg.Screen.centerX + Cfg.Fixation.offsetX + length;
  fromV =  Cfg.Screen.centerY + Cfg.Fixation.offsetY;
  toV =  Cfg.Screen.centerY + Cfg.Fixation.offsetY;
  Screen('DrawLine', windowPtr, fixColor, fromH, fromV, toH, toV, width);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
  Screen('gluDisk', window, Cfg.diskColor, xCenter, yCenter, Cfg.fixDiskRadius);

  % Draw the fixation cross in white, set it to the center of our screen and
  % set good quality antialiasing
  Screen('DrawLines', window, allCoords,...
    Cfg.fixLineWidthPix, Cfg.crossColor, [xCenter yCenter], 2);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function drawProbeText(window, Cfg, tstring)
  % Draws a (text) probe on screen
  
  % Default parameters:
  % 1) Size
  Screen('TextSize', window, Cfg.Messages.SizeTxtBig);
  %Screen('TextSize', window, Cfg.Messages.SizeTxtMid);
  
  % 2) Font
  Screen('TextFont', window, Cfg.Messages.TextFont);
  
  % Get the centre coordinate of the window
  xCenter = Cfg.report.x;
  yCenter = Cfg.report.y;

  % Set up alpha-blending for smooth (anti-aliased) lines (seems necessary!)
  Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

  % Draw text
  DrawFormattedText(window, tstring, 'center', 'center', Cfg.report.textColor); 
  % Flip to the screen
  %Screen('Flip', window);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function drawCenteredTexture(windowPtr, aTexture, cx, cy, screenDimX, screenDimY, textureDimX, textureDimY)
  %drawCenteredTexture (windowPtr, aTexture, -100, -100, 1024, 768, 720, 405)
  %here is how to draw a texture relative to the screen center

  px = cx + screenDimX/2;
  py = cy + screenDimY/2;


  ulx = px - textureDimX/2;
  uly = py - textureDimY/2;
  lrx = px + textureDimX/2;
  lry = py + textureDimY/2;

  destinationRect = [ulx, uly, lrx, lry];
  Screen('DrawTexture', windowPtr, aTexture, [], destinationRect);
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
  Screen('TextSize', window, Cfg.Messages.SizeTxtBig);
  Screen('TextFont', window, Cfg.Messages.TextFont);
  DrawFormattedText(window, 'Time for a short break!', 'center', 'center', [255 255 255]);

  Screen('TextSize', window, Cfg.Messages.SizeTxtMid);
  DrawFormattedText(window, 'When ready, press "Space".', 'center',...
      screenYpixels * 0.75, [128 128 128]);

  % Flip to the screen
  Screen('Flip', window);

  waitForSpacekey(tmax)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function EndScreen(window, Cfg, tmax)
  % Shows a pause screen and waits for either "Space" key press
  % or for the time to exceed tmax.
  vLineSpacing = 2;
  
  % Set the blend funciton for the screen
  Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

  % Get the size of the on screen window in pixels
  % For help see: Screen WindowSize?
  [screenXpixels, screenYpixels] = Screen('WindowSize', window);

  % Get the centre coordinate of the window in pixels
  % For help see: help RectCenter
  [xCenter, yCenter] = RectCenter(Cfg.Screen.rect);

  % Draw text in the middle of the screen in Courier in white
  Screen('TextSize', window, Cfg.Messages.SizeTxtBig);
  Screen('TextFont', window, Cfg.Messages.TextFont);
  text_ = sprintf('Experiment has ended!\n');
  DrawFormattedText(window, text_, 'center', 'center', [255 255 255]);
  text_ = sprintf('\n\nThanks for your participation!');
  DrawFormattedText(window, text_, 'center', 'center', [255 255 255]);
  
  Screen('TextSize', window, Cfg.Messages.SizeTxtMid);
  DrawFormattedText(window, 'The window will automatically close in 5 seconds.', 'center',...
      screenYpixels * 0.75, [128 128 128]);
    
  % Flip to the screen
  Screen('Flip', window);
  
  % Wait a second before closing the screen
  WaitSecs(5);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function WaitToStartScreen(window, Cfg, tmax)
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
  Screen('TextSize', window, Cfg.Messages.SizeTxtMid);
  Screen('TextFont', window, Cfg.Messages.TextFont);
  DrawFormattedText(window, 'Welcome!', 'center', round(heightRect/3), [255 255 255]);
  
  DrawFormattedText(window, 'YES : Left Arrow', 'center', screenYpixels * 0.5, [255 255 255]);
  DrawFormattedText(window, 'NO : Right Arrow', 'center', screenYpixels * 0.6, [255 255 255]);

  DrawFormattedText(window, 'To start experiment, press "Space"!', 'center',...
                    screenYpixels * 0.80, [128 128 128]);
  %DrawFormattedText(window, sprintf('(will automatically start in %d seconds)', tmax), 'center',...
  %                  screenYpixels * 0.78, [128 128 128]);
  
  % Flip to the screen
  Screen('Flip', window);

  waitForSpacekey(tmax)
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function waitForSpacekey(tmax)
  % Waits (maximum tmax-seconds) for the "Space" key
  
  % Suppress echo to the command line for keypresses
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
  %RestrictKeysForKbCheck; % calling it like that prevents further input check
  RestrictKeysForKbCheck([]);
  % re-enable echo to the command line for key presses (Ctrl+C if not)
  ListenChar(1)
end