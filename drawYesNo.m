function drawYesNo(window, screenXpixels, screenYpixels, key, keyYes, keyNo)
    tcolor = [64, 64, 64];
    % Vertical & horizontal shift of the feedback rectangle edges from the
    % "YES" & "NO" word bounds
    
    %{
        shift = 30; % in pixels

    % Draw YES & NO answers
    [~, ~, ~, wordbounds_no] = DrawFormattedText(window,...
    'NO', screenXpixels * 0.2,...
      screenYpixels * 0.90, tcolor);
    [~, ~, ~, wordbounds_yes] = DrawFormattedText(window,...
    'YES', screenXpixels * 0.7,...
      screenYpixels * 0.90, tcolor);
    wordbounds_no = [wordbounds_no(1) - shift,... % left
                     wordbounds_no(2) - shift,... % top
                     wordbounds_no(3) + shift,... % right
                     wordbounds_no(4) + shift];   % bottom
    wordbounds_yes = [wordbounds_yes(1) - shift,... % left
                      wordbounds_yes(2) - shift,... % top
                      wordbounds_yes(3) + shift,... % right
                      wordbounds_yes(4) + shift];   % bottom
    %Screen('Flip', window)
    %}
    if key == keyYes
        % draw yes
        [~, ~, ~, wordbounds_yes] = DrawFormattedText(window,...
            'YES', 'center',...
            'center', tcolor);
    elseif key == keyNo
        % draw no
        [~, ~, ~, wordbounds_no] = DrawFormattedText(window,...
            'NO', 'center',...
            'center', tcolor);
    end
    
end