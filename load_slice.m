function slice = load_slice(data_dir,mode_dir,i)
%LOAD_SLICE loads a sparse slice file
%
% Peter Turney
% October 20, 2007
%
% Copyright 2007, National Research Council of Canada
%
% file name
%
slice_file = sprintf('%s/%s/slice%d.mat', data_dir, mode_dir, i);
%
% load the file
%
data = load(slice_file);
%
% return the slice
%
slice = data.slice;
%