function fd = sock_new(hostname,port)

if nargin == 2
  mex_id_ = 'o int = matsock_new_tcp(i cstring, i int)';
[fd] = csockmex(mex_id_, hostname, port);
elseif nargin == 1
  mex_id_ = 'o int = matsock_new_unix(i cstring)';
[fd] = csockmex(mex_id_, hostname);
else
  error('Incorrect number of arguments to sock_new');
end

