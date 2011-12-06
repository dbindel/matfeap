function feaputil;

% @T ===========================
% \section {Utility commands}
%
% These are low-level routines that should generally be invisible
% to the user.
%
% @q ===========================

% @T --------------------------------------------
% \subsection{Waiting for synchronization}
%
% The [[feapsync]] command is used to wait for a synchronization
% message sent by the server.  For the moment, we don't use the
% synchronization labels.

%@o feapsync.m
% feapsync(feap, barriernum) 
%
% Synchronize on a MATFEAP SYNC string

%@c
function feapsync(p, barriernum)

if nargin == 1, barriernum = 0; end

while 1
  s = sock_recv(p.fd);
  if strfind(s, 'MATFEAP SYNC')
    if barriernum == 0
      break;
    elseif strcmp(s, sprintf('MATFEAP SYNC %d', barriernum))
      break
    else
      feapdispv(p, 'Unexpected barrier');
      feapdispv(p, s);
    end
  else
    feapdispv(p, s);
  end
end
%@o


% @T --------------------------------------------
% \subsection{Waiting for {\tt FEAPSRV}}
%
% The [[feapsrvp]] command is used to wait for the server to send
% a [[FEAPSRV]] prompt when using the [[feapsrv]] command
% interface.

%@o feapsrvp.m
% s = feapsrvp(feap)
%
% Wait for the FEAPSRV prompt

%@c
function s = feapsrvp(p, prompt)

while 1
  s = sock_recv(p.fd);
  feapdispv(p, s);
  if strfind(s, 'FEAPSRV>'), break; end
end
%@o


% @T --------------------------------------------
% \subsection{Verbose output}
% 
% The [[feapdispv]] routine is used to write messages to the
% standard output conditioned on the FEAP server being in verbose
% mode.  This is useful if you want to look at the output of FEAP
% for debugging purposes.

%@o feapdispv.m
% feapdispv(feap, msg)
%
% Display the message if verbose is true

%@c
function feapdispv(p, msg)

if p.verb
  if length(msg) == 0, msg = ' '; end 
  disp(msg);
end
%@o

% @T --------------------------------------------
% \subsection{Index mapping}
% 
% The [[ID]] array in FEAP is used to keep track of which nodal
% variables are active and which are determined by some boundary
% condition.  We return the relevant portion of the [[ID]] array
% along with:
% \begin{enumerate}
% \item 
%   The indices of all active degrees of freedom ([[full_id]]).
% \item
%   The indices of all variables subject to BCs ([[bc_id]]).
% \item
%   An array to map the indices of the active degrees of freedom
%   in the full vector to indices in a reduced vector ([[reduced_id]]).
% \end{enumerate}

%@o map2full.m
% [full_id, bc_id, reduced_id, id] = map2full(feap)
%
% Get mapping from full to reduced dof set for current FEAP deck.
%
% Output:
%   full_id    -- index of free variables in full dof vector
%   bc_id      -- index of displacement BC variables
%   reduced_id -- index of free variables in reduced dof set 
%                 (a permutation)
%   id         -- first part of FEAP index array

%@c
function [full_id, bc_id, reduced_id, id] = map2full(p)

% Get mesh parameters
nneq  = feapget(p, 'nneq');  % Number of unreduced dof
numnp = feapget(p, 'numnp'); % Number of dof
ndf   = feapget(p, 'ndf');   % Maximum dof per node

% Get the index map
id = feapgetm(p, 'id');
id = reshape(id(1:nneq), ndf, numnp);

% Find the index set for free vars in full and reduced vectors
full_id    = find(id >  0);
bc_id      = find(id <= 0);
reduced_id = id(full_id);
