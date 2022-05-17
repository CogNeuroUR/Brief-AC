function createMasks_acrossPics
% Function to create masks, by scrambling tiles across pictures
% NOTE: It requires that all images have the same size

pathToStim = [pwd, '\stimuli\'];
fNameList = dir([pathToStim 'target*.bmp']);
nStim = length(fNameList);
%sName = 'stimdef.txt';

% Get images sizes
test_img = imread([pathToStim fNameList(1).name]);
[global_height, global_width, global_n_channels] = size(test_img);

% Check if already have masked
for i = 1 : nStim
    if strfind(fNameList(i).name, 'masked') == 1
        fNameList(i) = [];
    end
end

%fid = fopen(sName,'a');
thisPic=[];
for i = 1 : nStim
    img=imread([pathToStim fNameList(i).name]);
    thisPic=[thisPic,img];
end

thisPicMasked = rearrangeTiles(thisPic);
save thisPicMasked
thisPicMasked_rand=rearrangeTiles(thisPicMasked);
save thisPicMasked_rand
thisPicMasked_rand_again=rearrangeTiles(thisPicMasked_rand);
save thisPicMasked_rand_again
thisPicMasked_rand_again2=rearrangeTiles(thisPicMasked_rand_again);
imagesc(thisPicMasked_rand_again2)

for y=1:nStim
    [pathstr, thisName, ext] = fileparts(fNameList(y).name);
    sName = [pathToStim sprintf('%s_masked.bmp', thisName)];
    %fprintf(int2str(size(thisPicMasked_rand_again2)));
    a=scrambledsingle(thisPicMasked_rand_again2(:,global_width*(y-1)+1:global_width*y,:));
    imwrite(a, sName);
end
