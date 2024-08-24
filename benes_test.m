clearvars
close all
clc

N=256;
RNG = 1;
N_test = 1e1;
rng(RNG)

tic
for ii = 1:N_test
    net_out = randperm(N);
    switch_mat = BenesNet_IO2S(net_out);
    net_out2 = BenesNet_S2IO(switch_mat)';
    if any(net_out ~= net_out2)
        error('It failed.')
    end
end
toc

fprintf('Test passed.\n')