function feapuser;

% @T ===========================
% \section {User commands}
%
% These are the main routines in the interface used directly by MATFEAP
% users.
%
% @q ===========================

% @T --------------------------------------------
% \subsection{Invoking FEAP macro commands}
%
% The [[feapcmd]] routine is used to invoke FEAP macro routines.
% It's up to the user to ensure that after the end of the last command
% in the list, FEAP is back at a prompt involving a [[tinput]]
% command (e.g. the macro prompt or a plot prompt).
%
% The [[feapcmd]] routine should not be used to quit FEAP; use
% [[feapquit]] for that.

%@o feapcmd.m
% feapcmd(feap, c1, c2, c3, ...)
%
% Run the FEAP macro commands specified by strings c1, ...

%@c
function feapcmd(p, varargin)

for k = 1:length(varargin)
  sock_send(p.fd, varargin{k});
  feapsync(p);
end
%@o

% @T --------------------------------------------
% \subsection{Exiting FEAP}
%
% The [[feapquit]] command invokes the quit command, says ``n''
% when asked whether we would like to continue, waits for the
% sign-off synchronization message, and shuts down the connection.
% This is the graceful way to exit from FEAP.  In contrast, the
% [[feapkill]] command should be treated as a last-ditch effort
% to kill a misbehaving FEAP process.

%@o feapquit.m
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
%@o

%@o feapkill.m
% feapkill(feap)
%
% Force quit on FEAP process.

%@c
function feapkill(p)

sock_close(p.fd);
%@o


% @T --------------------------------------------
% \subsection{Putting MATFEAP into verbose mode}
%
% In verbose mode, you can see all the interactions between MATFEAP
% and FEAP.  It's possible to switch to verbose mode by setting the
% [[verbose]] field in the parameter structure for [[feapstart]],
% or by setting the [[matfeap_globals]] structure directly; but
% I find myself wanting to see verbose output fairly regularly, so
% it seemed worthwhile to have a special method for it.

%@o feaps_verb.m
% Put MATFEAP into verbose mode.

%@c
function feaps_verb

global matfeap_globals;
matfeap_globals.verbose = 1;
