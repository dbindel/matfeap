function feapjsock;

% @T -----------------------------------
% \section{Interface to the Java socket helper}
%
% The Java socket helper class is a thin layer that lets us use
% Java stream descriptors and binary I/O routines.  We use it to
% establish socket connections, send an recieve lines of data,
% etc.
% 
% The socket routines are
% \begin{itemize}
% \item [[sock_new(hostname,port)]] - start a socket connection
% \item [[sock_new(command)]] - start a pipe connection
% \item [[sock_close(js)]] - close a socket
% \item [[sock_recv(js)]] - read a line of data
% \item [[sock_send(js)]] - send a line of data
% \item [[sock_readdarray(js, len)]] - read [[len]] 64-bit doubles
%   into an array
% \item [[sock_readiarray(js, len)]] - read [[len]] 32-bit integers
%   into an array
% \item [[sock_senddarray(js, array)]] - send an array of 64-bit doubles
% \item [[sock_sendiarray(js, array)]] - send an array of 32-bit integers
% \end{itemize}

%@o sock_new.m
function p = sock_new(hostname, port)

if nargin == 2
  p.helper = FeapClientHelper(hostname, int32(port));
else
  p.helper = FeapClientHelper(hostname);
end
%@o

%@o sock_close.m
function sock_close(p)
p.helper.close();
%@o

%@o sock_recv.m
function s = sock_recv(p)
s = char(p.helper.readln());
%@o

%@o sock_send.m
function sock_send(p, msg)
p.helper.send(msg);
%@o

%@o sock_recvdarray.m
function val = sock_recvdarray(p, len)
val = p.helper.getDarray(int32(len));
%@o

%@o sock_recviarray.m
function val = sock_recviarray(p, len)
val = p.helper.getIarray(int32(len));
%@o

%@o sock_senddarray.m
function sock_senddarray(p, x)
p.helper.setDarray(x);
%@o

%@o sock_sendiarray.m
function sock_sendiarray(p, x)
p.helper.setIarray(x);
%@o
