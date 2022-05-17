function createStimDefs

stim_folder = 'stimuli';

pathToStim = [pwd filesep stim_folder filesep];

fNameList = dir([pathToStim '*.png']);
nStim = length(fNameList);

sName = ['stimdef.std'];


fid = fopen(sName,'w');
for i = 1: nStim
    [pathstr, thisName, ext] = fileparts(fNameList(i).name);
    fprintf(fid, './%s/%s.png\n', stim_folder, thisName);
end
fclose(fid);