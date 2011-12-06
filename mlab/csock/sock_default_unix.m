function s = sock_default_unix
usrvar = 'USER';
mex_id_ = 'o cstring = getenv(i cstring)';
[usrenv] = csockmex(mex_id_, usrvar);
s = ['/tmp/feaps-', usrenv];
