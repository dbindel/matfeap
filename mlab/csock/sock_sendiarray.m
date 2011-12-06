function sock_sendiarray(fd, x)
len = prod(size(x));
mex_id_ = 'matsock_sendiarray(i int, i int[], i int)';
csockmex(mex_id_, fd, x, len);

