% D = feapdamp(feap)
%
% Get the current FEAP damping matrix

%@c
function D = feapdamp(p)

feapcmd(p, 'damp');
D = feapgetsparse(p, 'damp');
