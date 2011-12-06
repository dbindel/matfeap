function s = sock_recv(fd)
mex_id_ = 'matsock_recv(i int, o cstring[x], i int)';
[s] = csockmex(mex_id_, fd, 1024, 1024);

