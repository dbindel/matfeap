% array_val = feapgetm(feap, array_name)
%
% Get a dynamically allocated FEAP array by name.  array_val will be
% a column vector -- use reshape to change it into a matrix if
% appropriate.

%@c
function val = feapgetm(p, var)

if nargin < 2,   error('Missing required argument');      end
if ~ischar(var), error('Variable name must be a string'); end

sock_send(p.fd, 'serv');
feapsrvp(p);
cmd = sprintf('getm %s', upper(var));
feapdispv(p, cmd);
sock_send(p.fd, cmd);

resp = sock_recv(p.fd);
[s, resp] = strtok(resp);
val = [];
if strcmp(s, 'Send')
  [datatype, resp] = strtok(resp);  % Data type (int | double)
  [len,      resp] = strtok(resp);  % Number of entries
  len = str2num(len);
  if strcmp(datatype, 'int')
    feapdispv(p, sprintf('Receive %d ints...', len));
    sock_send(p.fd, 'binary')
    val = sock_recviarray(p.fd, len);
  elseif strcmp(datatype, 'double')
    feapdispv(p, sprintf('Receive %d doubles...', len));
    sock_send(p.fd, 'binary')
    val = sock_recvdarray(p.fd, len);
  else
    feapdispv(p, 'Did not recognize response, bailing');
    sock_send(p.fd, 'cancel')
  end
end

feapsrvp(p);
sock_send(p.fd, 'start')
feapsync(p);
