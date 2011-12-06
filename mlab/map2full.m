% [full_id, bc_id, reduced_id, id] = map2full(feap)
%
% Get mapping from full to reduced dof set for current FEAP deck.
%
% Output:
%   full_id    -- index of free variables in full dof vector
%   bc_id      -- index of displacement BC variables
%   reduced_id -- index of free variables in reduced dof set 
%                 (a permutation)
%   id         -- first part of FEAP index array

%@c
function [full_id, bc_id, reduced_id, id] = map2full(p)

% Get mesh parameters
nneq  = feapget(p, 'nneq');  % Number of unreduced dof
numnp = feapget(p, 'numnp'); % Number of dof
ndf   = feapget(p, 'ndf');   % Maximum dof per node

% Get the index map
id = feapgetm(p, 'id');
id = reshape(id(1:nneq), ndf, numnp);

% Find the index set for free vars in full and reduced vectors
full_id    = find(id >  0);
bc_id      = find(id <= 0);
reduced_id = id(full_id);
