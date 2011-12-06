% u = feapgetu(feap, id)
%
% Get the displacement vector from FEAP.  The id argument is optional;
% if it is ommitted, only active degrees of freedom are returned.

%@c
function u = feapgetu(p, id)

if nargin < 2, id = map2full(p); end
u = feapgetm(p, 'u');
u = u(id);
