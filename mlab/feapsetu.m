% feapsetu(feap, u, id)
%
% Set the displacement vector from FEAP.  The id argument is optional;
% if it is omitted, all active degrees of freedom are returned.

%@c
function feapsetu(p,u, id)

if nargin < 3, [id, bc_id] = map2full(p); end
u1 = feapgetm(p,'u');

if nargin < 2
  nneq        = feapget(p,'nneq');
  f           = feapgetm(p,'f');
  u1(bc_id)   = f(bc_id + nneq);
end

u1(id) = u;
feapsetm(p, 'u', u1);
