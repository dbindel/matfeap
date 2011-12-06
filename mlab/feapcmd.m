% feapcmd(feap, c1, c2, c3, ...)
%
% Run the FEAP macro commands specified by strings c1, ...

%@c
function feapcmd(p, varargin)

for k = 1:length(varargin)
  sock_send(p.fd, varargin{k});
  feapsync(p);
end
