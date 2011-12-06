% val = feapget(feap, vname)
%
% Get a scalar value out of a FEAP common block entry
% Ex:
%  neq = feapget(p, 'neq');

%@c
function val = feapget(p, var)

if nargin < 2,   error('Missing required argument');      end
if ~ischar(var), error('Variable name must be a string'); end

sock_send(p.fd, 'serv');
feapsrvp(p);
cmd = sprintf('get %s', lower(var));
feapdispv(p, cmd);
sock_send(p.fd, cmd);

val = [];
resp = sock_recv(p.fd);
if ~strcmp(resp, 'FEAPSRV> ')
  val = sscanf(resp, '%g');
  feapdispv(p, resp);
  feapsrvp(p);
end
sock_send(p.fd, 'start');
feapsync(p);
