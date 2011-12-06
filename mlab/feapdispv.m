% feapdispv(feap, msg)
%
% Display the message if verbose is true

%@c
function feapdispv(p, msg)

if p.verb
  if length(msg) == 0, msg = ' '; end 
  disp(msg);
end
