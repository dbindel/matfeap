function p = sock_new(hostname, port)

if nargin == 2
  p.helper = FeapClientHelper(hostname, int32(port));
else
  p.helper = FeapClientHelper(hostname);
end
