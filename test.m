function test
%TEST illustrates how to use multislice.m
%
% Peter Turney
% October 26, 2007
%
% Copyright 2007, National Research Council of Canada
%
% test multislice.m
%
% set random seed for repeatable experiments
%
rand('seed',5678);
%
% set parameters
%
I = [100 110 120]; % input sparse tensor size
J = [10 11 12]; % desired core tensor size
density = 0.1; % percent nonzero
%
data_dir = 'test'; % directory for storing tensor
sparse_file = 'spten.txt'; % file for storing raw data tensor
tucker_file = 'tucker.mat'; % file for storing Tucker tensor
%
% make a sparse random tensor and store it in a file
%
sparse_random_tensor(data_dir,sparse_file,I,density);
%
% call multislice
%
tic;
fit = multislice(data_dir,sparse_file,tucker_file,I,J);
time = toc;
%
% show results
%
fprintf('\n');
fprintf('Multislice:\n');
fprintf('I = [%d %d %d]\n', I(1), I(2), I(3));
fprintf('J = [%d %d %d]\n', J(1), J(2), J(3));
fprintf('density = %f\n', density);
fprintf('fit = %f\n', fit);
fprintf('time = %.1f\n', time);
fprintf('\n');
%