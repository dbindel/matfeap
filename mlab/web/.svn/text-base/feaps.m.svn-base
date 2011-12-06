% @T ===========================
% \section {Communication setup}
%
% These routines are used to specify which of the three communication modes
% available to MATFEAP should be used.
%
% @q ===========================

% @T -------------------------------------------------------------------
% \subsection{Setting up pipe communication}
%
% The [[feaps_pipe]] function tells MATFEAP to manage communication
% over a bidirectional pipe managed by Java.  This method is not
% available in the C interface -- there the prefered connection method is
% a UNIX-domain socket.
%
% The default location for the FEAP executable used by in pipe mode is
% {\tt {\it MATFEAP}/srv/feapp}.  The location of the [[feaps_pipe.m]]
% file should be {\tt {\it MATFEAP}/srv/feaps\_pipe.m}.  Since the latter
% file is obviously on the MATLAB path, we can get the fully qualified
% name from MATLAB and extract the location of the MATFEAP home directory
% from it.

%@o feaps_pipe.m
% feaps_pipe(cmd)
%
% Tell MATFEAP to use a pipe to connect to FEAP.  If cmd == [], turn off
% MATFEAP pipe connection mode.  If cmd is not provided, fill in a default
% location based on the location of this mfile.

%@c
function feaps_pipe(cmd)

global matfeap_globals
matfeap_globals.sockname = [];
matfeap_globals.server   = [];
matfeap_globals.port     = [];

if nargin < 1
  s = which('feaps_pipe.m');
  i = strfind(s, 'feaps_pipe.m')-length('mlab/');
  matfeap_globals.command = [s(1:i-1), 'srv/feapp'];
  fprintf('Using FEAP in pipe mode: %s\n', matfeap_globals.command);
elseif isempty(cmd)
  matfeap_globals.command = [];
  fprintf('Turning off FEAP pipe mode\n');
else
  matfeap_globals.command = cmd;
end

% @T --------------------------------------------------------------------
% \subsection{Setting up TCP socket communication}
%
% The [[feaps_tcp]] function tells MATFEAP to manage communication
% over a TCP socket (which may be managed by Java or C).  The default
% location for the server is the local host on port 3490.

%@o feaps_tcp.m
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

%@o feaps_unix.m
% feaps_unix(sockname)
%
% Tell MATFEAP to use a UNIX socket to connect to FEAP.  If sockname == [],
% turn off MATFEAP UNIX connection mode.  If sockname is not provided, fill in
% a default socket name based on the location of this mfile.

%@c
function feaps_unix(sockname)

global matfeap_globals
matfeap_globals.command  = [];
matfeap_globals.sockname = [];
matfeap_globals.server   = [];
matfeap_globals.port     = [];

if nargin < 1
  matfeap_globals.sockname = sock_default_unix;
elseif nargin == 1
  if isempty(sockname)
    fprintf('Turning off FEAP UNIX mode\n');
    return;
  else
    matfeap_globals.sockname = sockname;
  end
end

fprintf('Using FEAP on UNIX socket: %s\n', matfeap_globals.sockname);

