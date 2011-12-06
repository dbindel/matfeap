% feaps_tcp(server, port)
%
% Tell MATFEAP to use a TCP socket to connect to FEAP.  feaps_tcp([]) turns off
% MATFEAP UNIX connection mode.  Either the server or the port can be
% omitted; the default server is 127.0.0.1, and the default port is 3490.

%@c
function feaps_tcp(server, port)

global matfeap_globals
matfeap_globals.command  = [];
matfeap_globals.sockname = [];
matfeap_globals.server   = [];
matfeap_globals.port     = [];

if nargin < 1
  matfeap_globals.server = '127.0.0.1';
  matfeap_globals.port   = 3490;
elseif nargin == 1
  if isempty(server)
    fprintf('Turning off FEAP TCP mode\n');
    return;
  elseif isnumeric(server)
    matfeap_globals.server = '127.0.0.1';
    matfeap_globals.port   = server;
  else
    matfeap_globals.server = server;
    matfeap_globals.port   = 3490;
  end
else
  matfeap_globals.server = server;
  matfeap_globals.port   = port;
end

fprintf('Using FEAP in TCP mode: %s:%d\n', ...
        matfeap_globals.server, matfeap_globals.port);

% @T --------------------------------------------------------------------
% \subsection{Setting up UNIX socket communication}
%
% The [[feaps_unix]] function tells MATFEAP to manage communication
% over a UNIX-domain socket.  This option is only available with the C
% interface.  UNIX-domain sockets are identified by filesystem locations,
% typically placed under [[/tmp]].  For MATFEAP, we use the default
% name {\tt /tmp/feaps-{\it USER}}, where {\it USER} is the user name in
% the current environment.  Because MATLAB doesn't have direct access to
% the environment, we fetch the default socket name through the wrapper
% function [[sock_default_unix]].

