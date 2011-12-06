% Test block loading

params.n = 20;
p = feapstart('Iblock1', params); 
K = feaptang(p);
u = feapgetu(p);
u(1) = 1;
R = feapresid(p,u);

fprintf('norm(K*u+R) = %g\n', norm(K*u+R));

feapquit(p);
