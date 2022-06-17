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