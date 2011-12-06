% val = feapgetsparse(feap, vname)
%
% Get a sparse matrix value out of FEAP.  Valid array names are
% 'tang', 'utan', 'lmas', 'mass', 'cmas', 'umas', 'damp', 'cdam', 'udam'

%@c
function val = feapgetsparse(p, var)

if nargin < 2,   error('Wrong number of arguments'); end
if ~ischar(var), error('Variable name must be a string'); end
if length(var) < 1, error('Variable name must be at least one char'); end

sock_send(p.fd, 'serv');
feapsrvp(p);
cmd = sprintf('sparse binary %s', lower(var));
feapdispv(p, cmd);
sock_send(p.fd, cmd);

resp = sock_recv(p.fd);
[s, resp] = strtok(resp);
val = [];
if strcmp(s, 'nnz')
  [len, resp] = strtok(resp);
  len = str2num(len);
  feapdispv(p, sprintf('Receive %d matrix entries...', len));
  val = sock_recvdarray(p.fd, 3*len);
  val = reshape(val, 3, len);
  val = sparse(val(1,:), val(2,:), val(3,:));
end

feapsrvp(p);
sock_send(p.fd, 'start')
feapsync(p);
