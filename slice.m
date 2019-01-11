function slice(data_dir,sparse_file,mode_slice_dir,mode,I)
%SLICE chops a tensor into slices along the given mode
%
% Peter Turney
% October 20, 2007
%
% Copyright 2007, National Research Council of Canada
%
%% initialize
%
% set the secondary modes
%
if (mode == 1)
  r_mode = 2;
  c_mode = 3;
elseif (mode == 2)
  r_mode = 1;
  c_mode = 3;
else
  r_mode = 1;
  c_mode = 2;
end
%
% get sizes
%
Ns = I(mode); % number of slices
Nr = I(r_mode); % number of rows in each slice
Nc = I(c_mode); % number of columns in each slice
%
%% sort the index
%
fprintf('SLICE is running ...\n');
%
% file names
%
sub_dir = [data_dir, '/', mode_slice_dir];
sorted_file = [sub_dir, '/', 'sorted.txt'];
%
% make sure the directories exist
%
if (isdir(data_dir) == 0)
  mkdir(data_dir);
end
if (isdir(sub_dir) == 0)
  mkdir(sub_dir);
end
%
% sort
%
sort_index(data_dir,sparse_file,mode_slice_dir,mode);
%
%% count nonzeros in each slice
%
fprintf(' counting nonzeros in each slice for mode %d\n',mode);
%
% vector for storing nonzero count
%
nonzeros = zeros(Ns,1);
%
% read sorted file in blocks
%
% - read in blocks because file may be too big to fit in RAM
% - textscan will create one cell for each field
% - each cell will contain a column vector of the values in
% the given field
% - the number of elements in each column vector is the number
% of lines that were read
%
desired_lines = 100000;
actual_lines = desired_lines;
%
sorted_file_id = fopen(sorted_file, 'r');
while (actual_lines > 0)
  block = textscan(sorted_file_id,'%d %d %d %*f',desired_lines);
  mode_subs = block{mode};
  actual_lines = size(mode_subs,1);
  for i = 1:actual_lines
    nonzeros(mode_subs(i)) = nonzeros(mode_subs(i)) + 1;
  end
end
fclose(sorted_file_id);
%
%% make slices
%
fprintf(' saving slices for mode %d\n',mode);
%
sorted_file_id = fopen(sorted_file, 'r');
for i = 1:Ns
  slice_file = sprintf('%s/slice%d.mat', sub_dir, i);
  nonz = nonzeros(i);
  block = textscan(sorted_file_id,'%d %d %d %f',nonz);
  slice_rows = double(block{r_mode});
  slice_cols = double(block{c_mode});
  slice_vals = block{4};
  slice = sparse(slice_rows,slice_cols,slice_vals,Nr,Nc,nonz);
  save(slice_file,'slice');
end
fclose(sorted_file_id);
%
fprintf('SLICE is done\n');
%