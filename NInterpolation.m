function [final,final_Simplified_func,query_result] = NInterpolation(order,p,y,query)
b = zeros(1,length(p));
temp = zeros(1,length(p));
 for i= 1:1:(order+1)
     if(i == 1)
         temp(i) = y(i);
         b(i) = y(i);
     else
         temp(i) = (y(i)-y(i-1))/(p(i)- p(i-1));
         b(i)= temp(i);
     end
 end
if (order > 1)
    k = 2;
   for i =3:1:length(b)
       for j= i:1:length(b)
           b(j) = (temp(j)-temp(j-1))/(p(j)- p(j-k));
       end
       temp = b;
       k = k+1;
   end
end
disp(b);
syms term0(x)
syms final(x)
syms lastTerm(x)
syms final_Simplified_func(x)
final(x) = zeros(1,length(p));
lastTerm(x) = zeros(1,length(p));
term0(x) = zeros(1,2);
for i= 1:1:length(p)
    if(i == 1)
        term0(x) = b(i);
        final(x) = term0(x);
    elseif(i==2)
            lastTerm(x) = (b(i)*(x-p(i-1)));
            final(x) = final(x)+lastTerm(x);
    else
        lastTerm(x) = (lastTerm(x)*b(i)*((x-p(i-1))))/b(i-1);
        final(x) = final(x)+lastTerm(x);
    end
end
plot(p,y);
disp((final(x)));
final_Simplified_func = simplify(final(x));
disp(final_Simplified_func);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
query_result = zeros(1,length(query));
for i = 1:1:length(query_result)
    query_result(i) = feval(final,query(i));
    disp(query_result(i));
end