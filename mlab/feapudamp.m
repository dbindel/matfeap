% D = feapudamp(feap)
%
% Get the current FEAP unsymmetric damping matrix

%@c
function D = feapudamp(p)

feapcmd(p, 'damp,unsy');
D = feapgetsparse(p, 'damp');
