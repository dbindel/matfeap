% M = feapmass(feap)
%
% Get the current FEAP mass matrix

%@c
function M = feapmass(p)

feapcmd(p, 'mass');
M = feapgetsparse(p, 'mass');
