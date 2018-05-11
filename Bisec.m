function root = Bisec(func,xl, xu, es, imax)
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
if(subs(func,xl)*subs(func,xu))>0 
%disp('no bracket')
return
end
ea = 1;
for i=1:1:imax
xr(i)=(xu+xl)/2;
%disp(xr(i));
if(i>1)
    ea = abs(xr(i)-xr(i-1)); 
  %  disp(ea);
end
test= (subs(func,xl)*subs(func,xu));
if(test < 0)
    xu=xr(i);
else xl=xr(i);
end
if(test == 0)
    ea=0; end
if(ea < es) 
    break; end
end
root = xr(i);
s=sprintf('\n Root with bisection= %f #Iterations = %d \n', xr(i),i); disp(s);
end