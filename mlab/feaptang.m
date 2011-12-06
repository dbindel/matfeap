% K = feaptang(feap)
%
% Form and fetch the current FEAP tangent matrix

%@c
function K = feaptang(p)

feapcmd(p, 'tang,,-1');
K = feapgetsparse(p, 'tang');
