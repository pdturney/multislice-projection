function fit = multislice(data_dir,sparse_file,tucker_file,I,J)
%MULTISLICE is a low RAM Tucker decomposition
%
% Peter Turney
% October 26, 2007
%
% Copyright 2007, National Research Council of Canada
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program. If not, see <http://www.gnu.org/licenses/>.
%
%% set parameters
%
fprintf('MULTISLICE is running ...\n');
%
maxloops = 50; % maximum number of iterations
eigopts.disp = 0; % suppress messages from eigs()
minfitchange = 1e-4; % minimum change in fit of tensor
%
%% make slices of input data file
%
fprintf(' preparing slices\n');
%
mode1_dir = 'slice1';
mode2_dir = 'slice2';
mode3_dir = 'slice3';
%
slice(data_dir,sparse_file,mode1_dir,1,I);
slice(data_dir,sparse_file,mode2_dir,2,I);
slice(data_dir,sparse_file,mode3_dir,3,I);
%
%% pseudo HO-SVD initialization
%
% initialize B
%
M2 = zeros(I(2),I(2));
for i = 1:I(3)
  X3_slice = load_slice(data_dir,mode3_dir,i);
  M2 = M2 + (X3_slice' * X3_slice);
end
for i = 1:I(1)
  X1_slice = load_slice(data_dir,mode1_dir,i);
  M2 = M2 + (X1_slice * X1_slice');
end
[B,D] = eigs(M2*M2',J(2),'lm',eigopts);
%
% initialize C
%
M3 = zeros(I(3),I(3));
for i = 1:I(1)
  X1_slice = load_slice(data_dir,mode1_dir,i);
  M3 = M3 + (X1_slice' * X1_slice);
end
for i = 1:I(2)
  X2_slice = load_slice(data_dir,mode2_dir,i);
  M3 = M3 + (X2_slice' * X2_slice);
end
[C,D] = eigs(M3*M3',J(3),'lm',eigopts);
%
%% main loop
%
old_fit = 0;
%
fprintf(' entering main loop of MULTISLICE\n');
%
for loop_num = 1:maxloops
  %
  % update A
  %
  M1 = zeros(I(1),I(1));
  for i = 1:I(2)
    X2_slice = load_slice(data_dir,mode2_dir,i);
    M1 = M1 + ((X2_slice * C) * (C' * X2_slice'));
  end
  for i = 1:I(3)
    X3_slice = load_slice(data_dir,mode3_dir,i);
    M1 = M1 + ((X3_slice * B) * (B' * X3_slice'));
  end
  [A,D] = eigs(M1*M1',J(1),'lm',eigopts);
  %
  % update B
  %
  M2 = zeros(I(2),I(2));
  for i = 1:I(3)
    X3_slice = load_slice(data_dir,mode3_dir,i);
    M2 = M2 + ((X3_slice' * A) * (A' * X3_slice));
  end
  for i = 1:I(1)
    X1_slice = load_slice(data_dir,mode1_dir,i);
    M2 = M2 + ((X1_slice * C) * (C' * X1_slice'));
  end
  [B,D] = eigs(M2*M2',J(2),'lm',eigopts);
  %
  % update C
  %
  M3 = zeros(I(3),I(3));
  for i = 1:I(1)
    X1_slice = load_slice(data_dir,mode1_dir,i);
    M3 = M3 + ((X1_slice' * B) * (B' * X1_slice));
  end
  for i = 1:I(2)
    X2_slice = load_slice(data_dir,mode2_dir,i);
    M3 = M3 + ((X2_slice' * A) * (A' * X2_slice));
  end
  [C,D] = eigs(M3*M3',J(3),'lm',eigopts);
  %
  % build the core
  %
  G = zeros(I(1)*J(2)*J(3),1);
  G = reshape(G,[I(1) J(2) J(3)]);
  for i = 1:I(1)
    X1_slice = load_slice(data_dir,mode1_dir,i);
    G(i,:,:) = B' * X1_slice * C;
  end
  G = reshape(G,[I(1) (J(2)*J(3))]);
  G = A' * G;
  G = reshape(G,[J(1) J(2) J(3)]);
  %
  % measure fit
  %
  normX = 0;
  sqerr = 0;
  for i = 1:I(1)
    X1_slice = load_slice(data_dir,mode1_dir,i);
    X1_approx = reshape(G,[J(1) (J(2)*J(3))]);
    X1_approx = A(i,:) * X1_approx;
    X1_approx = reshape(X1_approx,[J(2) J(3)]);
    X1_approx = B * X1_approx * C';
    sqerr = sqerr + norm(X1_slice-X1_approx,'fro')ˆ2;
    normX = normX + norm(X1_slice,'fro')ˆ2;
  end
  fit = 1 - sqrt(sqerr) / sqrt(normX);
  %
  fprintf(' loop %d: fit = %f\n', loop_num, fit);
  %
  % stop if fit is not increasing fast enough
  %
  if ((fit - old_fit) < minfitchange)
    break;
  end
  %
  old_fit = fit;
  %
end
%
fprintf(' total loops = %d\n', loop_num);
%
%% save tensor
%
output_file = [data_dir, '/', tucker_file];
save(output_file,'G','A','B','C');
%
fprintf(' tucker tensor is in %s\n',tucker_file);
%
fprintf('MULTISLICE is done\n');
%
