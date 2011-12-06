% feap = feapstart(fname, params)
%
% Start a FEAP process using an input file given by ifname.
% The optional param argument may be used to set parameters
% for the input deck; for example, if a parameter 'n' is used
% in a deck 'Ifoo', then
%
%   param.n = 10
%   p = feapstart('Ifoo', param)
%
% will give n a default value of 10.
%
% The params structure can also contain special fields that
% control details of the deck processing:
%
%   verbose  - Indicate whether we want to see FEAP interactions or not
%   sockname - If defined, connect to FEAP via a UNIX domain socket
%   command  - If defined, connect to the indicated FEAP via a pipe
%   server   - Host name for FEAP server (default: '127.0.0.1') 
%   port     - Port for FEAP server (default: 3490)
%
% Parameters can also be passed through a global variable called
% matfeap_globals.  feapstart reads control parameters from matfeap_globals
% as though they were entered through the params structure; if the control
% parameters are specified via matfeap_globals and via a parameter argument,
% the latter has precedence.

%@T
% \section{Starting FEAP}
%
% The [[feapstart]] command is used to launch a new FEAP process:
%@c
function p = feapstart(fname, params)
%@T
%
% The file name argument is required.  The optional [[params]]
% argument plays double duty: a set of special parameters are used
% to control things about the MATFEAP interface, and the remaining
% parameters are used to initialize the FEAP variable list before
% opening the designated input deck.
%@q

% --- Checking input parameters ---

if ~ischar(fname), error('Expected filename as string'); end
if nargin > 1,
  if ~isstruct(params) & ~isempty(params)
    error('Expected params as struct'); 
  end
else
  params = [];
end

%@T -----------------------------------------------------------
% \subsection{Merging global parameters}
%
% The [[matfeap_globals]] variable is used to provide default
% values for the fields in the [[params]] structure, if explicit
% values are not otherwise provided.

%@c
global matfeap_globals;

if isstruct(matfeap_globals)
  if isempty(params)
    params = matfeap_globals;
  else
    pnames = fieldnames(matfeap_globals);
    for k = 1:length(pnames)
      if ~isfield(params, pnames{k})
        pvalue = getfield(matfeap_globals, pnames{k});
        params = setfield(params, pnames{k}, pvalue);
      end
    end
  end
end

%@T -----------------------------------------------------------
% \subsection{Special parameters}
%
% The special parameters are
% \begin{itemize}
%   \item [[verbose]]: if true, output all the stuff that FEAP sends
%   \item [[server]] and [[port]]: the server host name
%     (string) and port number (integer)
%   \item [[command]]: if defined, this string says how to
%     execute the extended FEAP directly from the command line.
%     Used as an alternative to opening a socket connection.
%   \item [[dir]]: the starting directory to change to after
%     connecting to the FEAP server.  By default we use the
%     client's present working directory.
% \end{itemize}
%
% At the same time we process these parameters, we remove them
% from the [[param]] structure.  That way, everything remaining
% in the [[param]] structure after this step can be interpreted
% as a FEAP input parameter.

%@c
verb    = 0;           % Are we in verbose mode?
server  = '127.0.0.1'; % Server where FEAP is located
port    = 3490;        % Port where FEAP is located
dir     = pwd;         % Base directory to use for rel paths
command = [];          % Command string to use with pipe interface
sockname = [];         % UNIX domain socket name

if ~isempty(params)
  if isfield(params, 'verbose')
    verb = params.verbose;
    params = rmfield(params, 'verbose');
  end
  if isfield(params, 'server')
    server = params.server;
    params = rmfield(params, 'server');
  end
  if isfield(params, 'port')
    port = params.port;
    params = rmfield(params, 'port');
  end
  if isfield(params, 'command')
    command = params.command;
    params = rmfield(params, 'command');
  end
  if isfield(params, 'sockname')
    sockname = params.sockname;
    params = rmfield(params, 'sockname');
  end
  if isfield(params, 'dir')
    dir = params.dir;
    params = rmfield(params, 'dir');
  end
end


%@T -----------------------------------------------------------
% \subsection{Input deck directory}
%
% I assume that the file name does not contain any slashes or
% backslashes; if those occur in the input deck name, then we'll
% split the name argument into [[pathname]] and [[fname]].

%@c
lastslash = max([strfind(fname, '/'), strfind(fname, '\')]);
if ~isempty(lastslash)
  pathname = fname(1:lastslash-1);
  fname = fname(lastslash+1:end);
else
  pathname = [];
end


%@T -----------------------------------------------------------
% \subsection{Opening FEAP}
%
% If [[sockname]] is nonempty, then the user has specified
% a UNIX domain socket to connect to the FEAP server.  Otherwise
% if [[command]] is nonempty, then the user has specified the
% name of a command to start the (extended) FEAP.  This FEAP
% executable has the same interface as the socket-based version,
% but it communicates using the ordinary standard I/O streams,
% which we will connect to a pipe.  Otherwise, we'll try to
% communicate with the server via TCP.  We give the same generic error
% message in the event of any error -- ``is the server there?''
%
% Once a connection to the FEAP process has been established,
% we save the relevant Java helper (or C handle) and the verbosity flag 
% together in a handle structure.  This structure is the first argument 
% to all the high-level MATFEAP interface functions.

%@c
try
  if ~isempty(sockname)
    fd = sock_new(sockname);
  elseif ~isempty(command)
    fd = sock_new(command);
  else
    fd = sock_new(server, port);
  end
catch
  fprintf('Could not open connection -- is the FEAP server running?\n');
  error(lasterr);
end

p = [];
p.fd = fd;
p.verb = verb;

%@T -----------------------------------------------------------
% \subsection{Passing parameters}
%
% The [[param]] command in the [[feapsrv]] interface allows the
% user to send parameters to FEAP.  Parameter assignments have the
% form ``param var val''.  Invalid assignments are (perhaps suboptimally)
% simply ignored.

%@c
feapsrvp(p);
if ~isempty(params)
  pnames = fieldnames(params);
  for k = 1:length(pnames)
    pvar = pnames{k};
    pval = getfield(params, pnames{k});
    if ~isnumeric(pval)
      fprintf('Ignoring non-numeric parameter %s\n', pvar);
    else
      sock_send(fd, sprintf('param %s %g', pvar, pval));
      feapsrvp(p);
    end
  end
end

%@T -----------------------------------------------------------
% \subsection{Setting the current directory}
%
% If a home directory was specified via a [[dir]] special
% argument, we first change to that directory (by default, we
% change to the client's present working directory).  If a path was
% specified as part of the input deck name, we then change to that
% directory.  If both [[dir]] and [[pathname]] are non-empty
% and the [[pathname]] specifies a relative path, we will end up
% in the path relative to the specified base directory.
%
% The [[feapsrv]] command to change directories will return a
% diagnostic message if for any reason the directory change doesn't
% go through.  We ignore said message.

%@c
if ~isempty(dir)
  sock_send(fd, ['cd ', dir]);
  feapsrvp(p);
end
if ~isempty(pathname)
  sock_send(fd, ['cd ', pathname]);
  feapsrvp(p);
end

%@T -----------------------------------------------------------
% \subsection{Sending the file names}
%
% Once we've set up the parameter string and changed to the proper
% directory, we're ready to actually start processing an input
% deck.  The [[start]] command gets us out of the [[feapsrv]]
% interface and into ordinary FEAP interactions.  We now need to
% send to FEAP:
% \begin{enumerate}
% \item
%   The name of the input deck.
% \item
%   Blank lines to say ``we accept the default names for the
%   auxiliary files.''  The number of auxiliary files has changed
%   over time, which is why we don't use a counter -- we just send
%   a blank line at every synchronization message until we see a
%   string that indicates that we've entered all the desired file
%   names.
% \item
%   A string ``y'' for when we're asked if the file names are
%   correct.
% \end{enumerate}
%
% If an error occurs during entering the file name, we send the
% ``quit'' string and get out of dodge.  In response to a request
% to quit, FEAP will go through the ordinary shutdown procedure,
% so we'll wait for the last synchronization message before closing
% the connection.

%@c
sock_send(fd, 'start');
feapsync(p);
sock_send(fd, fname);

doneflag = 0;
while 1
  s = sock_recv(fd);
  if strfind(s, '*ERROR*')
    p.verb = 1;
    feapsync(p);
    sock_send(fd, 'quit');
    feapsync(p);
    sock_close(fd);
    p = [];
    return;
  elseif strfind(s, 'Files are set')
    feapdispv(p, s);
    feapsync(p);
    sock_send(fd, 'y')
    feapsync(p);
    return;
  elseif strfind(s, 'MATFEAP SYNC')
    sock_send(fd, '');
  else
    feapdispv(p, s);
  end
end
