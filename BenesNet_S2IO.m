function net_out = BenesNet_S2IO(switch_mat)
% SETTINGS:
% 1. The function finds output of a Benes network, given its switch states.
% 2. Switches are 2-by-2, and have only two states:
%           swap (coded as 1) and straight (coded as 0).
% 3. This code works for Benes network that have each switch routes its
% input into top and bottom sub-networks. The input of the first layer
% switches is (1,2), (3,4),..., and the output of the last layer switches
% is set in a similar order.
% 4. The network input is assumed to be 1:N, where N is a power of 2.
% 5. The network output is a permutation of the network input.
% 6. There are 2N_log-1 layers; each layer has N/2 switches, where
%   N_log = log2(N).
%
% NOTES:
% 1. This is writen for functionality, not for optimal speed/memory performance.
% 2. The idea is to construct two transformation matrices for each layer of
% switches: one matrix is for output of swithes, and the other is for input
% of switches of the next layer.
%
% Input:
%   switch_mat  : matrix of size N/2 x (2N_log-1)
% Output:
%   net_out     : permutation of 1:N

%---------MAIN-------------------------------------------------------------

%%%%% Sanitize
N = size(switch_mat,1)*2;
N_log = round(log2(N));

if abs(log2(N)-N_log)>1e-6 || abs(size(switch_mat,2) + 1 - 2*N_log)>1e-6
    error('switch_mat does not have a valid size.')
end

if ~isempty(setdiff(switch_mat + 0, [0 1]))
    error('Values of switch_mat must be 0/1.')
end

%%%%% Main algo
straight_matrix = eye(2);
swap_matrix = 1-eye(2);

net_in = (1:N)';
ii = 0:N_log-2;
ii = [ii ii(end:-1:1)];

for nn=1:2*N_log - 1
    % first matrix, for output of switches
    diag_swap = switch_mat(:,nn);
    A_swap = kron(diag(diag_swap), swap_matrix);
    diag_straight = 1 - switch_mat(:,nn);
    A_straight = kron(diag(diag_straight), straight_matrix);
    A = A_swap + A_straight;
    net_in = A * net_in;
    
    % second matrix, for input of the next layer
    if nn == 2*N_log -1
        % no need to construct second matrix for the last layer
        break
    end
    subnet_size = N/2^ii(nn);
    perm_mat = zeros(subnet_size);
    perm_vector = [1:2:subnet_size, 2:2:subnet_size];
    ind_1 = sub2ind([subnet_size, subnet_size], 1:subnet_size, perm_vector);
    perm_mat(ind_1) = 1;
    transform_mat = kron(eye(2^ii(nn)), perm_mat);
    if nn > N_log -1
        transform_mat = transform_mat.';
    end
    net_in = transform_mat * net_in;
end

net_out = net_in;

end