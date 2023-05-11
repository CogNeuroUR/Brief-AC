function createStimDefs(system)

%stim_folder = 'stimuli';
stim_folder = 'stimuli_demo';

pathToStim = [pwd filesep stim_folder filesep];

format = 'JPG'; %'png';
fNameList = dir([pathToStim '*.' format]);
nStim = length(fNameList);

%sName = ['stimdef.std'];
sName = ['stimdef_demo.std'];

if isequal(system, 'windows')
  separator = "\";
else
  separator = '/';
end

fid = fopen(sName,'w');
for i = 1: nStim
    [pathstr, thisName, ext] = fileparts(fNameList(i).name);
    fprintf(fid, '.%s%s%s%s.%s\n', separator, stim_folder, separator, thisName, format);  % for Windows
end
fclose(fid);
