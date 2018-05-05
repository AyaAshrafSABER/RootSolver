function root = FalsePosition(func,xlf, xuf, esf, imaxf)
if(isnan(esf))
    esf = 0.0001;
end
if(isnan(imaxf))
    imaxf = 50;
end
x = zeros(1,imax);
y = zeros(1,imax);
a = zeros(1,imax);
b = zeros(1,imax);
ya = zeros(1,imax);
yb = zeros(1,imax);
a(1) = xlf; b(1) = xuf;
ya(1) = feval(func,a(1)); yb(1) = feval(func,b(1));
if(ya(1)*yb(1)>0.0)
    error('Function has the same sign at both end points');
end
for i = 1:1:imaxf
    x(i) = (b(i)-yb(i))*(b(i)-a(i))/(yb(i)-ya(i));
    y(i) = feval(func,x(i));
    if y(i) == 0 
        disp('exact root fount');break;
    elseif y(i)-ya(i) < 0
        a(i+1) = a(i); ya(i+1) = ya(i);
        b(i+1) = x(i); yb(i+1) = y(i);
    else 
        b(i+1) = b(i); yb(i+1) = yb(i);
        a(i+1) = x(i); ya(i+1) = y(i);
    end
    if((i>1) && (abs(x(i)-x(i-1)< esf)))
        disp('false position method has converged'); break;
    end
    iteration = i;
end
if(iteration >= imaxf)
    disp('root not found to desired tolerance');
end
root = x(i);
s=sprintf('\n Root with false position method= %f #Iterations = %d \n', x(i),i); disp(s);