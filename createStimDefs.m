function createStimDefs(system)

stim_folder = 'stimuli';

pathToStim = [pwd filesep stim_folder filesep];

fNameList = dir([pathToStim '*.png']);
nStim = length(fNameList);

sName = ['stimdef.std'];

if isequal(system, 'windows')
  separator = "\";
else
  separator = '/';
end

fid = fopen(sName,'w');
for i = 1: nStim
    [pathstr, thisName, ext] = fileparts(fNameList(i).name);
    fprintf(fid, '.%s%s%s%s.png\n', separator, stim_folder, separator, thisName);  % for Windows
end
fclose(fid);
