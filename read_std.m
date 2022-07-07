function std_files = read_std()
  % Read std-file
  fid = fopen('stimdef.std');
  
  tline = fgetl(fid);
  std_files = [];
  while ischar(tline)
    std_files = [std_files; convertCharsToStrings(tline)];
    tline = fgetl(fid);
  end
  fclose(fid);
end