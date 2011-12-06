% R = feapresid(feap, u, id)
%
% Get the residual corresponding to a particular input vector.
% Both the u (displacement vector) and id (variable index) arguments
% can be ommitted:
%
%   R = feapresid(p);        % Get the current residual
%   R = feapresid(p,u);     % Set FEAP's active displacements to u first
%   R = feapresid(p,u,id);  % Set displacements (possibly not active) first

%@c
function R = feapresid(p, u, id)

if nargin == 2
  feapsetu(p,u);
elseif nargin == 3
  feapsetu(p,u, id);
end

sock_send(p.fd,'serv');
feapsrvp(p);
feapdispv(p, 'clear_isformed');
sock_send(p.fd, 'clear_isformed');
feapsrvp(p);
sock_send(p.fd, 'start');
feapsync(p);

feapcmd(p,'form');
R = feapgetm(p,'dr');
R = R(1:feapget(p,'neq'));
