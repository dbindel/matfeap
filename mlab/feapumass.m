% M = feapumass(feap)
%
% Get the current FEAP unsymmetric mass matrix

%@c
function M = feapumass(p)

feapcmd(p, 'mass,unsy');
M = feapgetsparse(p, 'umas');
