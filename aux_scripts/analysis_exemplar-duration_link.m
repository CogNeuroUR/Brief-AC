%% 
ds = [2:1:6 8];
es = [1:6];

%%
N=3;

assert(length(ds) == length(es))

for i=1:N
  % shuffle the mapping
  map_durations = randperm(length(ds));
  map_exemplars = randperm(length(es));

  % remap
  new_ds = ds(map_durations).';
  new_es = es(map_exemplars).';

  % print
  for j=1:length(new_ds)
    fprintf('%d : %d\n', new_ds(j), new_es(j));
  end
  fprintf('\n');
end

%%
N=3;

for i=1:N
  [, new_es] = random_remap(ds, es);
  % print
  fprintf('Duration : Exemplar\n');
  for j=1:length(new_ds)
    fprintf('%d : %d\n', ds(j), new_es(j));
  end
  fprintf('\n');
end
 
%% random remapping function
function [new_array1, new_array2] = random_remap(array1, array2)
% randomly reorders two arrays
  assert(length(array1) == length(array1))
  
  new_array1 = array1(randperm(length(array1)));
  new_array2 = array2(randperm(length(array2)));
end
