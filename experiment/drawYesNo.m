function drawYesNo(window, screenXpixels, screenYpixels, key, keyYes, keyNo)
    tcolor = [64, 64, 64];
    if key == keyYes
        % draw yes
        [~, ~, ~, wordbounds_yes] = DrawFormattedText(window,...
            'JA', 'center',...
            'center', tcolor);
    elseif key == keyNo
        % draw no
        [~, ~, ~, wordbounds_no] = DrawFormattedText(window,...
            'NEIN', 'center',...
            'center', tcolor);
    end
    
end