% [xx, uu] = feapgetx(feap, u)
%
% Get the node positions (xx) and their displacements (uu).
% Uses the reduced displacement vector u, or the reduced displacement
% vector from FEAP if u is not provided.

%@c
function [xx, uu] = feapgetx(p,u)

% Get mesh parameters
nnp  = feapget(p,'numnp'); % Number of nodal points
nneq = feapget(p,'nneq');  % Number of unreduced dof
neq  = feapget(p,'neq');   % Number of dof
ndm  = feapget(p,'ndm');   % Number of spatial dimensions
ndf  = feapget(p,'ndf');   % Maximum dof per node

% Get node coordinates from FEAP
xx = feapgetm(p,'x');
xx = reshape(xx, ndm, length(xx)/ndm);

if nargout > 1

  % Extract u if not provided
  if nargin < 1, u = feapgetu(p); end

  % Find out how to map reduced to full dof set
  id   = feapgetm(p,'id');
  id   = reshape(id(1:nneq), ndf, nnp);
  idnz = find(id > 0);

  % Get full dof set
  uu       = zeros(ndf, nnp);
  uu(idnz) = u(id(idnz));

end
