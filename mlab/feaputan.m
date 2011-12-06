% K = feaputan(feap)
%
% Form and fetch the FEAP current unsymmetric tangent matrix

%@c
function K = feaputan(p)

feapcmd(p, 'utan,,-1');
K = feapgetsparse(p, 'utan');
