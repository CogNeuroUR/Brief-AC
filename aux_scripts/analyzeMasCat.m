]\\\%load SUB99_01_MasCat.mat%color%
%load SUB101_00_MasCat.mat%grayscale; normalized intensities% JVS
load SUB101_01_MasCat.mat%grayscale; normalized intensities% JVS
%load SUB103_01_MasCat.mat%grayscale; normalized intensities% AM

acc=[];
nTrials = length(ExpInfo.TrialInfo);
for iTrial = 1: nTrials
    
    ID(iTrial)=ExpInfo.TrialInfo(iTrial).trial.code;
    cResp(iTrial)=ExpInfo.TrialInfo(iTrial).trial.correctResponse;
    %temp!
%     if cResp(iTrial)==3
%         cResp(iTrial)=2;
%     end
    %if ExpInfo.TrialInfo(iTrial).Response.key 
    %resp(iTrial)=ExpInfo.TrialInfo(iTrial).Response.key;
    if isempty(ExpInfo.TrialInfo(iTrial).Response.key==1)
        t = 1
        resp(iTrial)=nan;
        rt(iTrial)=nan;
    else
        resp(iTrial)=ExpInfo.TrialInfo(iTrial).Response.key;
        rt(iTrial)=ExpInfo.TrialInfo(iTrial).Response.RT;

    end
    
    if resp(iTrial)==cResp(iTrial)
        acc(iTrial)=1;
    else
       acc(iTrial)=0;
    end


end

[out] = ASF_decode(ID, [2, 5, 12]); %nCategories, 6 picDurations, 4 exemplars

for iPicDur = 1:5
    for iCat = 1:2
        thisInd = find(out(:,2)==iPicDur-1&out(:,1)==iCat-1);
        RT(iPicDur, iCat)=nanmean(rt(thisInd));
        ACC(iPicDur, iCat)=nanmean(acc(thisInd));
    end
end

figure
picDur = (1000/60)*[1:1:5];
h1=plot(picDur, ACC(:,1));
hold on;
h2=plot(picDur, ACC(:,2));
set(h1, 'marker', 'o', 'markersize', 12', 'color', 'k', 'markerfacecolor', 'w', 'linewidth', 1.5);
set(h2, 'marker', 'o', 'markersize', 12', 'color', 'r', 'markerfacecolor', 'w', 'linewidth', 1.5);
hold on;


hleg=legend([h1, h2], 'communication', 'destruction');
set(hleg, 'Location', 'southeast', 'Fontsize', 12, 'box', 'off')
set(gca, 'fontsize', 12);
set(gca, 'xtick', round(picDur));
hxlab = xlabel('presentation time [msec]');
hylab = ylabel('accuracy');


