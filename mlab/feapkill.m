% feapkill(feap)
%
% Force quit on FEAP process.

%@c
function feapkill(p)

sock_close(p.fd);
