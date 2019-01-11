function sort_index(data_dir,sparse_file,mode_slice_dir,mode)
%SORT_INDEX sorts a sparse tensor index file along the given mode
%
% Peter Turney
% October 20, 2007
%
% Copyright 2007, National Research Council of Canada
%
%% sort the index
%
fprintf('SORT_INDEX is running ...\n');
%
% file names
%
input_file = [data_dir, '/', sparse_file];
sub_dir = [data_dir, '/', mode_slice_dir];
sorted_file = [sub_dir, '/', 'sorted.txt'];
%
% call Unix 'sort' command
%
% -n = numerical sorting
% -k = key to sort on
% -s = stable sorting
% -S = memory for sorting buffer
% -o = output file
%
% - the 'sort' command is a standard part of Unix and Linux
% - if you are running Windows, you can get 'sort' by
% installing Cygwin
% - the sort buffer is set here to 1 GiB; you can set it
% to some other value, based on how much RAM you have
%
command = sprintf('sort -n -s -S 1G -k %d,%d -o %s %s', ...
mode, mode, sorted_file, input_file);
%
fprintf(' calling Unix sort for mode %d\n', mode);
unix(command);
%
fprintf('SORT_INDEX is done\n');
%