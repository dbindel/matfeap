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

