% feapsetm(feap, array_name, array_val)
%
% Set a dynamically allocated FEAP array's entries.  Note that array_val
% can be whatever shape is desired, so long as it has the correct number of
% entries.

%@c
function feapsetm(p, var, val)

sock_send(p.fd, 'serv');
feapsrvp(p);
cmd = sprintf('setm %s', upper(var));
feapdispv(p, cmd);
sock_send(p.fd, cmd);

resp = sock_recv(p.fd);
[s, resp] = strtok(resp);
if strcmp(s, 'Recv')
  [datatype, resp] = strtok(resp);
  [len, resp] = strtok(resp);
  len = str2num(len);
  if len ~= prod(size(val))
    feapdispv(p, sprintf('Expected size %d; bailing', len));
    sock_send(p.fd, 'cancel');
  elseif strcmp(datatype, 'int')
    feapdispv(p, sprintf('Sending %d ints...', len));
    sock_send(p.fd, 'binary')
    sock_sendiarray(p.fd, val);
  elseif strcmp(datatype, 'double')
    feapdispv(p, sprintf('Sending %d doubles...', len));
    sock_send(p.fd, 'binary')
    sock_senddarray(p.fd, val);
  else
    feapdispv(p, 'Did not recognize response, bailing');
    sock_send(p.fd, 'cancel')
  end
end

feapsrvp(p);
sock_send(p.fd, 'start')
feapsync(p);
