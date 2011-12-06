function sock_senddarray(fd, x)
len = prod(size(x));
mex_id_ = 'matsock_senddarray(i int, i double[], i int)';
csockmex(mex_id_, fd, x, len);

