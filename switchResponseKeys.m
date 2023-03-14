function switchResponseKeys(ExpInfo, old_left, old_right, new_left, new_right)
    for iTrial = 1:length(ExpInfo.TrialInfo)
        if ExpInfo.TrialInfo(iTrial).Response.key == old_right
            ExpInfo.TrialInfo(iTrial).Response.key = new_right;
        elseif ExpInfo.TrialInfo(iTrial).Response.key == old_left
            ExpInfo.TrialInfo(iTrial).Response.key = new_left;
        end
    end
end