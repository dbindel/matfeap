function feapgetset;

% @T ===========================
% \section {Basic getter / setter interfaces}
%
% These are the MATLAB interface routines that get and set FEAP
% matrices, arrays, and scalars.
%
% @q ===========================


% @T --------------------------------------------
% \subsection{Getting scalar values}
%
% To get a scalar variable, we enter the [[feapsrv]] interface
% and issue a {\tt get {it varname}} request.  Either it succeeds,
% in which case the variable is printed; or it fails, in which case
% nothing is printed.  We silently return an empty array to
% indicate the latter case.  After retrieving the variable, we
% issue a [[start]] command to exit the [[feapsrv]] interface
% and get back to the FEAP macro prompt.

%@o feapget.m
% val = feapget(feap, vname)
%
% Get a scalar value out of a FEAP common block entry
% Ex:
%  neq = feapget(p, 'neq');

%@c
function val = feapget(p, var)

if nargin < 2,   error('Missing required argument');      end
if ~ischar(var), error('Variable name must be a string'); end

sock_send(p.fd, 'serv');
feapsrvp(p);
cmd = sprintf('get %s', lower(var));
feapdispv(p, cmd);
sock_send(p.fd, cmd);

val = [];
resp = sock_recv(p.fd);
if ~strcmp(resp, 'FEAPSRV> ')
  val = sscanf(resp, '%g');
  feapdispv(p, resp);
  feapsrvp(p);
end
sock_send(p.fd, 'start');
feapsync(p);
%@o

% @T --------------------------------------------
% \subsection{Getting arrays}
%
% This routine implements the client side of the array fetch
% protocol described in the [[feapsrv]] documentation.  We enter
% the [[feapsrv]] command interface, issue a request for a
% matrix, read the server's description of the matrix size and
% type, and then either start an appropriate binary data transfer
% or bail if something looks malformed.  After all this, we return
% to the FEAP macro interface.

%@o feapgetm.m
% array_val = feapgetm(feap, array_name)
%
% Get a dynamically allocated FEAP array by name.  array_val will be
% a column vector -- use reshape to change it into a matrix if
% appropriate.

%@c
function val = feapgetm(p, var)

if nargin < 2,   error('Missing required argument');      end
if ~ischar(var), error('Variable name must be a string'); end

sock_send(p.fd, 'serv');
feapsrvp(p);
cmd = sprintf('getm %s', upper(var));
feapdispv(p, cmd);
sock_send(p.fd, cmd);

resp = sock_recv(p.fd);
[s, resp] = strtok(resp);
val = [];
if strcmp(s, 'Send')
  [datatype, resp] = strtok(resp);  % Data type (int | double)
  [len,      resp] = strtok(resp);  % Number of entries
  len = str2num(len);
  if strcmp(datatype, 'int')
    feapdispv(p, sprintf('Receive %d ints...', len));
    sock_send(p.fd, 'binary')
    val = sock_recviarray(p.fd, len);
  elseif strcmp(datatype, 'double')
    feapdispv(p, sprintf('Receive %d doubles...', len));
    sock_send(p.fd, 'binary')
    val = sock_recvdarray(p.fd, len);
  else
    feapdispv(p, 'Did not recognize response, bailing');
    sock_send(p.fd, 'cancel')
  end
end

feapsrvp(p);
sock_send(p.fd, 'start')
feapsync(p);
%@o

% @T --------------------------------------------
% \subsection{Setting arrays}
%
% This routine implements the client side of the array set
% protocol described in the [[feapsrv]] documentation.  It is
% exactly analogous to [[feapgetm]], except that now we have to
% make sure that we're sending the right amount of data.  We should
% almost certainly advertize more clearly when we've exited because
% the specified array was the wrong size.

%@o feapsetm.m
% feapsetm(feap, array_name, array_val)
%
% Set a dynamically allocated FEAP array's entries.  Note that array_val
% can be whatever shape is desired, so long as it has the correct number of
% entries.

%@c
function feapsetm(p, var, val)

sock_send(p.fd, 'serv');
feapsrvp(p);
cmd = sprintf('setm %s', upper(var));
feapdispv(p, cmd);
sock_send(p.fd, cmd);

resp = sock_recv(p.fd);
[s, resp] = strtok(resp);
if strcmp(s, 'Recv')
  [datatype, resp] = strtok(resp);
  [len, resp] = strtok(resp);
  len = str2num(len);
  if len ~= prod(size(val))
    feapdispv(p, sprintf('Expected size %d; bailing', len));
    sock_send(p.fd, 'cancel');
  elseif strcmp(datatype, 'int')
    feapdispv(p, sprintf('Sending %d ints...', len));
    sock_send(p.fd, 'binary')
    sock_sendiarray(p.fd, val);
  elseif strcmp(datatype, 'double')
    feapdispv(p, sprintf('Sending %d doubles...', len));
    sock_send(p.fd, 'binary')
    sock_senddarray(p.fd, val);
  else
    feapdispv(p, 'Did not recognize response, bailing');
    sock_send(p.fd, 'cancel')
  end
end

feapsrvp(p);
sock_send(p.fd, 'start')
feapsync(p);
%@o

% @T --------------------------------------------
% \subsection{Getting sparse matrices}
%
% This routine implements the client side of the sparse matrix fetch
% protocol described in the [[feapsrv]] documentation.  We start
% the [[feapsrv]] command interface, request the array, read the
% number of nonzero entries, and either fetch a block of binary
% data and convert it to a sparse matrix, or bail if we saw
% something unexpected.

%@o feapgetsparse.m
% val = feapgetsparse(feap, vname)
%
% Get a sparse matrix value out of FEAP.  Valid array names are
% 'tang', 'utan', 'lmas', 'mass', 'cmas', 'umas', 'damp', 'cdam', 'udam'

%@c
function val = feapgetsparse(p, var)

if nargin < 2,   error('Wrong number of arguments'); end
if ~ischar(var), error('Variable name must be a string'); end
if length(var) < 1, error('Variable name must be at least one char'); end

sock_send(p.fd, 'serv');
feapsrvp(p);
cmd = sprintf('sparse binary %s', lower(var));
feapdispv(p, cmd);
sock_send(p.fd, cmd);

resp = sock_recv(p.fd);
[s, resp] = strtok(resp);
val = [];
if strcmp(s, 'nnz')
  [len, resp] = strtok(resp);
  len = str2num(len);
  feapdispv(p, sprintf('Receive %d matrix entries...', len));
  val = sock_recvdarray(p.fd, 3*len);
  val = reshape(val, 3, len);
  val = sparse(val(1,:), val(2,:), val(3,:));
end

feapsrvp(p);
sock_send(p.fd, 'start')
feapsync(p);
%@o


% @T ===========================
% \section {Getting stiffness, mass, and damping}
%
% These are the high-level interface routines that fetch or write
% the main FEAP sparse matrices.
%
% @q ===========================

% @T --------------------------------------------
% \subsection{Tangent matrix}
%
% The [[feaptang]] and [[feaputan]] routines call FEAP macros
% to form the tangent stiffness matrix (symmetric or unsymmetric)
% without factoring it, and then retrieve the matrix into MATLAB.

%@o feaptang.m 
% K = feaptang(feap)
%
% Form and fetch the current FEAP tangent matrix

%@c
function K = feaptang(p)

feapcmd(p, 'tang,,-1');
K = feapgetsparse(p, 'tang');
%@o

% ---
%@o feaputan.m
% K = feaputan(feap)
%
% Form and fetch the FEAP current unsymmetric tangent matrix

%@c
function K = feaputan(p)

feapcmd(p, 'utan,,-1');
K = feapgetsparse(p, 'utan');
%@o

% @T --------------------------------------------
% \subsection{Mass matrix}
%
% The [[feapmass]] and [[feapumass]] routines call FEAP macros
% to form the mass (symmetric or unsymmetric), and then retrieve
% the matrix into MATLAB.  This high-level interface only allows
% you to get the consistent mass, and not the lumped mass.

%@o feapmass.m
% M = feapmass(feap)
%
% Get the current FEAP mass matrix

%@c
function M = feapmass(p)

feapcmd(p, 'mass');
M = feapgetsparse(p, 'mass');
%@o

% ---
%@o feapumass.m
% M = feapumass(feap)
%
% Get the current FEAP unsymmetric mass matrix

%@c
function M = feapumass(p)

feapcmd(p, 'mass,unsy');
M = feapgetsparse(p, 'umas');
%@o

% @T --------------------------------------------
% \subsection{Damping matrix}
%
% The [[feapdamp]] and [[feapudamp]] routines call FEAP macros
% to form the damping (symmetric or unsymmetric), and then retrieve
% the matrix into MATLAB.

%@o feapdamp.m
% D = feapdamp(feap)
%
% Get the current FEAP damping matrix

%@c
function D = feapdamp(p)

feapcmd(p, 'damp');
D = feapgetsparse(p, 'damp');
%@o

% ---
%@o feapudamp.m
% D = feapudamp(feap)
%
% Get the current FEAP unsymmetric damping matrix

%@c
function D = feapudamp(p)

feapcmd(p, 'damp,unsy');
D = feapgetsparse(p, 'damp');
%@o


% @T ===========================
% \section {Getting and setting [[X]], [[U]], and [[F]] vectors}
%
% These are the high-level interface routines that fetch or write
% the node position, displacement, and residual vectors.
%
% @q ===========================


% @T --------------------------------------------
% \subsection{Getting the displacement}
%
% The [[feapgetu]] command retrieves the full displacement array
% [[U]] and returns some subset of it.  By default, we extract the
% active degrees of freedom in the reduced order, using
% [[map2full]] to retrieve the appropriate reindexing vector.

%@o feapgetu.m
% u = feapgetu(feap, id)
%
% Get the displacement vector from FEAP.  The id argument is optional;
% if it is ommitted, only active degrees of freedom are returned.

%@c
function u = feapgetu(p, id)

if nargin < 2, id = map2full(p); end
u = feapgetm(p, 'u');
u = u(id);
%@o

% @T --------------------------------------------
% \subsection{Setting the displacement}
%
% The [[feapsetu]] command sets some subset of the displacement
% array [[U]] (by default, we set the active degrees of
% freedom).  If we don't provide a vector to write out, then the
% assumption is that we want to clear the displacement vector to
% zero, save for any essential boundary conditions (which FEAP
% keeps in the second part of the [[F]] array).

%@o feapsetu.m
% feapsetu(feap, u, id)
%
% Set the displacement vector from FEAP.  The id argument is optional;
% if it is omitted, all active degrees of freedom are returned.

%@c
function feapsetu(p,u, id)

if nargin < 3, [id, bc_id] = map2full(p); end
u1 = feapgetm(p,'u');

if nargin < 2
  nneq        = feapget(p,'nneq');
  f           = feapgetm(p,'f');
  u1(bc_id)   = f(bc_id + nneq);
end

u1(id) = u;
feapsetm(p, 'u', u1);
%@o

% @T --------------------------------------------
% \subsection{Getting the nodal positions}
%
% The [[feapgetx]] command gets the nodal position matrix [[X]]
% and, optionally, a parallel matrix of displacements.  These
% displacements can be extracted from a displacement vector passed
% in as an argument, or they can be retrieved from the FEAP [[U]]
% array.

%@o feapgetx.m
% [xx, uu] = feapgetx(feap, u)
%
% Get the node positions (xx) and their displacements (uu).
% Uses the reduced displacement vector u, or the reduced displacement
% vector from FEAP if u is not provided.

%@c
function [xx, uu] = feapgetx(p,u)

% Get mesh parameters
nnp  = feapget(p,'numnp'); % Number of nodal points
nneq = feapget(p,'nneq');  % Number of unreduced dof
neq  = feapget(p,'neq');   % Number of dof
ndm  = feapget(p,'ndm');   % Number of spatial dimensions
ndf  = feapget(p,'ndf');   % Maximum dof per node

% Get node coordinates from FEAP
xx = feapgetm(p,'x');
xx = reshape(xx, ndm, length(xx)/ndm);

if nargout > 1

  % Extract u if not provided
  if nargin < 1, u = feapgetu(p); end

  % Find out how to map reduced to full dof set
  id   = feapgetm(p,'id');
  id   = reshape(id(1:nneq), ndf, nnp);
  idnz = find(id > 0);

  % Get full dof set
  uu       = zeros(ndf, nnp);
  uu(idnz) = u(id(idnz));

end
%@o

% @T --------------------------------------------
% \subsection{Getting the residual}
%
% The [[feapresid]] function forms the residual and fetches it
% from FEAP memory.  If the user provides a reduced displacement
% vector [[u]] as an argument, then that vector will be written
% to FEAP's array of nodal unknowns before evaluating the residual.
%
% The one thing that's a little tricky about [[feapresid]] has to do
% with an optimization in FEAP.  Usually, calls to the FEAP macro to
% form the residual don't do anything unless there has been a solve
% step since the previous request for a residual form.  But when we
% modify the displacements and boundary conditions behind FEAP's back,
% we typically invalidate the current residual, whatever it may be.
% So before requesting that FEAP form a new residual, we use the 
% [[feapsrv]] interface to clear the flag that says that the residual has
% already been formed.

%@o feapresid.m
% R = feapresid(feap, u, id)
%
% Get the residual corresponding to a particular input vector.
% Both the u (displacement vector) and id (variable index) arguments
% can be ommitted:
%
%   R = feapresid(p);        % Get the current residual
%   R = feapresid(p,u);     % Set FEAP's active displacements to u first
%   R = feapresid(p,u,id);  % Set displacements (possibly not active) first

%@c
function R = feapresid(p, u, id)

if nargin == 2
  feapsetu(p,u);
elseif nargin == 3
  feapsetu(p,u, id);
end

sock_send(p.fd,'serv');
feapsrvp(p);
feapdispv(p, 'clear_isformed');
sock_send(p.fd, 'clear_isformed');
feapsrvp(p);
sock_send(p.fd, 'start');
feapsync(p);

feapcmd(p,'form');
R = feapgetm(p,'dr');
R = R(1:feapget(p,'neq'));
%@o
