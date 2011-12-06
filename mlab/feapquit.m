% feapquit(feap)
%
% Gracefully exit from FEAP.

%@c
function feapquit(p)

sock_send(p.fd, 'quit');
feapsync(p);
sock_send(p.fd, 'n');
feapsync(p,1);
sock_close(p.fd);
