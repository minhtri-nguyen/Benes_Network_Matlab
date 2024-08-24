function switch_mat = BenesNet_IO2S(net_out)
% SETTINGS:
% 1. The function finds switch states of a Benes network, given its output.
% 2. Switches are 2-by-2, and have only two states:
%           swap (coded as 1) and straight (coded as 0).
% 3. This code works for Benes networks that have each switch routes its
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
% 2. The routing algorithm is based on graph coloring.
%
% Input:
%   net_out     : permutation of 1:N
% Output:
%   switch_mat  : matrix of size N/2 x (2N_log-1)

%---------MAIN-------------------------------------------------------------

%%%%% Sanitize, and constants (DO NOT CHANGE)
COLOR_TOP = 1;
COLOR_DOWN = -1;

N = numel(net_out);
N_log = round(log2(N));
if abs(log2(N)-N_log)>1e-6
    error('Number of in/out is not a power of 2.')
end

if ~isempty(setdiff(net_out, 1:N))
    error('Network output is not a permutation of 1:N.')
end

net_out = net_out(:);

%%%%% Run the main algo
switch_mat = sub_routing(net_out);

%---------SUPPORTING FUNCTIONS---------------------------------------------

    function switch_mat = sub_routing(subnet_out)
        Nsub = numel(subnet_out);
        if Nsub == 2
            switch_mat = (subnet_out(1) > subnet_out(2)) + 0;
            return
        end
        Nsub_log = round(log2(Nsub));
        switch_mat = zeros(Nsub/2, 2*Nsub_log -1);
        
        % create adjacency matrix for the graph
        A_in = kron(eye(Nsub/2), 1 - eye(2));    % edges of inputs
        
        A_out = zeros(Nsub);
        A_out(sub2ind([Nsub,Nsub], subnet_out(1:2:end), subnet_out(2:2:end))) = 1;
        A_out = A_out + A_out.';
        
        A = A_in + A_out;
        
        % perform graph 2-coloring
        c_in = graph_2_coloring(A);
        c_out = c_in(subnet_out);
        if any(c_in(1:2:end) == c_in(2:2:end)) || ...
                any(c_out(1:2:end) == c_out(2:2:end))
            error('Something is not right.')
        end
        
        % find switch states (of first and last layer)
        s_in = (c_in(1:2:end) < c_in(2:2:end)) + 0;
        s_out = (c_out(1:2:end) < c_out(2:2:end)) + 0;
        switch_mat(:,1) = s_in;
        switch_mat(:,end) = s_out;
        
        % perform recursion
        [~, top_tmp] = sort(subnet_out(c_out > 0), 'ascend');
        [~, subnet_out_inner_top] = sort(top_tmp, 'ascend');
        [~, bot_tmp] = sort(subnet_out(c_out < 0), 'ascend');
        [~, subnet_out_inner_bot] = sort(bot_tmp, 'ascend');
        switch_mat(1:Nsub/4,2:end-1) = sub_routing(subnet_out_inner_top);
        switch_mat(Nsub/4+1:end,2:end-1) = sub_routing(subnet_out_inner_bot);
    end

    function c = graph_2_coloring(A_mat)
        % A_mat     : N x N adjacency matrix
        % c         : [N x 1] colors (top or dow) of vertices
        s = size(A_mat,1);
        if s == 2
            c = [COLOR_TOP COLOR_DOWN];
            return
        end
        
        %%% begin coloring
        c = [COLOR_TOP; zeros(s-1,1)];
        current_node = 1;
        current_color = COLOR_TOP;
        iter_ = 0;
        while(1)
            x = find (A_mat(:,current_node) > 0, 1, 'first');
            if ~isempty(x) && c(x) ==0
                % if not colored
                A_mat(x,current_node) = 0; % remove edge, so that it does not loop
                A_mat(current_node,x) = 0;
                current_color = - current_color;
                c(x) = current_color;
                current_node = x;
            else
                % if colored, jump to the next circle
                current_node = find(c == 0, 1, 'first');
                if isempty(current_node)
                    break
                end
                c(current_node) = current_color;
            end
            
            iter_ = iter_ + 1;
            if iter_ > s
                error('The loop runs for unexpectedly many iterations.')
            end
        end
    end
end
