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
