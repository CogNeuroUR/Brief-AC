function runFastAC(subjectID, runNum, expName)
%example call:
%runFastAC(1, 1, 'FastAC')

%clear all;
addpath(genpath('/usr/share/psychtoolbox-3/'))
addpath(genpath('/home/ov/asf/code'));

%setenv('PSYCH_EXPERIMENTAL_NETWMTS', '1')

% switch internal naming scheme from the operating system specific scheme
KbName('UnifyKeyNames')

Cfg = [];
Cfg.environment = 'BEHAV_LAB';
Cfg.userSuppliedTrialFunction = @ASF_showTrial_BriefAC;
Cfg.responseTerminatesTrial = 1; % finish trial after giving response

%==========================================================================
% FACTORIAL DESIGN
%==========================================================================
% ContextLevels = ["kitchen", "office", "workshop"];
% ActionLevels = ["cutting", "grating", "whisking";...
%                 "hole-punching", "stamping", "stapling";...
%                 "hammering", "painting", "sawing"];
ContextLevels = ["KÜCHE", "BÜRO", "WERKSTATT"];
ActionLevels = ["SCHNEIDEN", "REIBEN", "VERRÜHREN";...
                "LOCHEN", "STEMPELN", "HEFTEN";...
                "HÄMMERN", "STREICHEN", "SÄGEN"];
% ContextLevels = ["KUECHE", "BUERO", "WERKSTATT"];
% ActionLevels = ["SCHNEIDEN", "REIBEN", "VERRUEHREN";...
%                 "LOCHEN", "STEMPELN", "HEFTEN";...
%                 "HAEMMERN", "STREICHEN", "SAEGEN"];
ProbeLevels = [ContextLevels; ActionLevels];

Cfg.DurationLevels = [2:1:6 8];
Cfg.factorProbeTypes = ["context", "action"]';
Cfg.factorProbes = reshape(ProbeLevels, 1, []);
Cfg.factorialStructure = [length(Cfg.factorProbeTypes) length(Cfg.factorProbes) length(Cfg.DurationLevels)];

%==========================================================================
% FIXATION CROSS PARAMETERS
%==========================================================================
Cfg.diskColor = [64 64 64]; % dim gray [105 105 105]; % light gray  [0 0 0]; % black
Cfg.crossColor = [255 255 255]; % white
Cfg.fixCrossDimPix = 28*.5; %28*.75; % size of the cross arms
Cfg.fixLineWidthPix = 4; %7.37; % width of cross arms (>7.37 crashes on Ubuntu)
Cfg.fixDiskRadius =33*.5;  %33*.75; % radius of disk

%==========================================================================
% Special Trials' codes
%==========================================================================
Cfg.startTrialCode = 1000;
Cfg.endTrialCode = 1002;
Cfg.prepTrialCode = 1003;

Cfg.pauseTrialCode = 1001;
Cfg.pauseDurationMax = 30; % IN SECONDS!

%==========================================================================
% REPORT SCREEN PARAMETERS
%==========================================================================
params_exp = split(expName, '_');
keyYes = params_exp(end);
disp(keyYes);
if ~ismember(keyYes, {'left', 'right'})
  error('Given key name (last element in "expName") is neither "left" or "right"!')
end

%Cfg.probe.message = 'Type your description:';
Cfg.probe.textColor = [175 175 175]; % light gray [255 255 255];
Cfg.probe.bgColor = [0 0 0]; % black
Cfg.probe.useKbCheck=0;
Cfg.probe.maxNumChar=52; % ~2 x albhabet
Cfg.probe.vLineSpacing = 2;
Cfg.probe.keyYes = keyYes;
% NOTE: rest of parameters are defined after "switch Cfg.environment"
%==========================================================================

switch Cfg.environment
  case 'BEHAV_LAB'
    Screen('Preference','TextEncodingLocale', '.1252')
    %Screen('Preference','TextEncodingLocale', 'English_United Kingdom.1252');
    Cfg.Screen.color = [0, 0, 0]; %Black BACKGROUND;
    Cfg.responseDevice = 'KEYBOARD';
    Cfg.enabledKeys = [KbName('LeftArrow'),...
                       KbName('RightArrow'),...
                       KbName('space')]; % LEFT & RIGHT ARROWS + SPACE
    Cfg.useTrialOnsetTimes = 0;
    %Cfg.Screen.rect = [1, 1, 640, 400]; % tiny
    %Cfg.Screen.rect = [1, 1, 1280, 800]; % part
    Cfg.Screen.rect = [0, 0, 1920, 1080]; % full screen
    Cfg.stimDefName = 'stimdef.std';
    Cfg.Fixation = [];
    Cfg.Fixation.fixType = 1;
  
  case 'OV_TP'
    % Tested on Ubuntu 20.04
    Cfg.Screen.color = [0, 0, 0]; %Black BACKGROUND;
    Cfg.responseDevice = 'KEYBOARD';
    Cfg.enabledKeys = [KbName('LeftArrow'), KbName('RightArrow'),...
                       KbName('Return'), KbName('Space')];
    Cfg.useTrialOnsetTimes = 0;
    %Cfg.Screen.rect = [1, 1, 512, 320]; % tiny
    %Cfg.Screen.rect = [1, 1, 640, 400]; % part
    %Cfg.Screen.rect = [1, 1, 1280, 800]; % part
    Cfg.Screen.rect = [0, 0, 1920, 1080]; % full screen
    %Cfg.Screen.rect = [0, 0, 2560, 1440]; % second screen
    Cfg.stimDefName = 'stimdef.std';
    Cfg.Fixation = [];
    Cfg.Fixation.fixType = 1;

  case 'OV_DELL'
    % Tested on Ubuntu 20.04
    Cfg.Screen.color = [0, 0, 0]; %Black BACKGROUND;
    Cfg.responseDevice = 'KEYBOARD';
    Cfg.enabledKeys = [KbName('LeftArrow'), KbName('RightArrow'),...
                       KbName('Return'), KbName('Space')];
    Cfg.enabledKeys = [114, 115, 66]; % LEFT & RIGHT ARROW
    Cfg.useTrialOnsetTimes = 0;
    %Cfg.Screen.rect = [1, 1, 512, 320]; % tiny
    %Cfg.Screen.rect = [1, 1, 640, 400]; % part
    Cfg.Screen.rect = [1, 1, 1920, 1080]; % part
    %Cfg.Screen.rect = [0, 0, 3849, 2169]; % full screen
    Cfg.stimDefName = 'stimdef.std';
    Cfg.Fixation = [];
    Cfg.Fixation.fixType = 1;

end

%==========================================================================
% Rest of REPORT SCREEN PARAMETERS
%==========================================================================
[xCenter, yCenter] = RectCenter(Cfg.Screen.rect);
widthRect = RectWidth(Cfg.Screen.rect);
heightRect = RectHeight(Cfg.Screen.rect);
Cfg.probe.x = widthRect/3.5;
Cfg.probe.y = heightRect/3.5;
%==========================================================================
% OTHER APPEARANCE PARAMETERS
%==========================================================================
Hratio2fhd = (Cfg.Screen.rect(4) - Cfg.Screen.rect(2)) / 1080;
Cfg.Messages.SizeTxtBig = round(60 * Hratio2fhd); % 70 for full screen (FHD)
Cfg.Messages.SizeTxtMid = round(45 * Hratio2fhd); % 50 for full screen (FHD)
Cfg.Messages.TextFont = 'Verdana';

%==========================================================================

%ExpInfo = ASF(Cfg.stimDefName, sprintf('SUB%02d_%02d_%s.trd', subjectID, runNum, expName), sprintf('SUB%02d_%02d_%s', subjectID, runNum, expName), Cfg)
ExpInfo = ASF(Cfg.stimDefName, sprintf('%s.trd', expName), sprintf('result_%s', expName), Cfg)
    