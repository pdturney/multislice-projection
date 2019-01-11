function sparse_random_tensor(data_dir,sparse_file,I,density)
%SPARSE_RANDOM_TENSOR makes a sparse uniformly distributed random tensor
%
% Peter Turney
% October 20, 2007
%
% Copyright 2007, National Research Council of Canada
%
% assume a third-order tensor is desired
%
%% initialize
%
fprintf('SPARSE_RANDOM_TENSOR is running ...\n');
%
% make sure the directory exists
%
if (isdir(data_dir) == 0)
  mkdir(data_dir);
end
%
file_name = [data_dir, '/', sparse_file];
%
fprintf(' generating tensor of size %d x %d x %d with density %f\n', ...
  I(1), I(2), I(3), density);
%
%% main loop
%
file_id = fopen(file_name, 'w');
fprintf(' slice: ');
for i1 = 1:I(1)
  fprintf('%d ',i1); % show progress
  if ((mod(i1,10) == 0) && (i1 ~= I(1)))
    fprintf('\n '); % time for new line
  end
  for i2 = 1:I(2)
    for i3 = 1:I(3)
      if (rand < density)
        fprintf(file_id,'%d %d %d %f\n',i1,i2,i3,rand);
      end
    end
  end
end
fprintf('\n');
fclose(file_id);
%
fprintf('SPARSE_RANDOM_TENSOR is done\n');
%