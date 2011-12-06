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

