function val = sock_recviarray(fd, len)
mex_id_ = 'matsock_recviarray(i int, o int[x], i int)';
[val] = csockmex(mex_id_, fd, len, len);

