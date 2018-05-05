function root = Bisection(func,xl, xu, es, imax)
if(isnan(es))
    es = 0.0001;
end
if(isnan(imax))
    imax = 50;
end
k = ceil((log10(abs(xu-xl))- log10(es))/log10(2));
if(k < imax)
    xr = zeros(1,k);
else
    xr = zeros(1,imax);
end

if(eval(subs(func,xl))*eval(subs(func,xu)))>0 
disp('There is no root in this interval')
return
end
ea = 1;
tic;
disp('#Iterations     xl          xu          Approximate Root     Precision');
for i=1:1:imax
xr(i)=(xu+xl)/2;
if(i>1)
    ea = abs(xr(i)-xr(i-1)); 
end
disp('%d              %f          %f          %f                   %f \n',i,xl,xu,xr(i),ea);
test=(eval(subs(func,xl))*eval(subs(func,xu)));
if(test < 0)
    xu=xr(i);
else xl=xr(i);
end
if(test == 0)
    ea=0; end
if(ea < es) 
    break; end
end
executionTime = toc;
root = xr(i);
disp('number of iterations = %d, approximate root using Bisection = %f, execution time = %f',i,xr(i),executionTime);