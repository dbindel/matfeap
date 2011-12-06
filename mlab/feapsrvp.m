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
