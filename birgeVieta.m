function [ rts ] = birgeVieta()
%poly = getPolynomial();
x=linspace(-4,8);
y=x.^4-9*x.^3-2*x.^2+120*x-130;
degree =4;
a = [1 -9 -2 120 -130];
%plot(axes,x,y)
Xnew =-3;%getIntialValue();
AError = 10^-6;
Xold=Xnew-AError-1;
nomOfIteration =50;
j=1;

%apply the method
 b = zeros(degree,0);
 b(1)=a(1);
 c = zeros(degree,0);
 c(1)=a(1);
 while(abs( Xnew-Xold)>AError&& j < nomOfIteration+1)
     
for i =  2: degree+1
   b(i)=a(i)+Xnew*b(i-1);
   fprintf('value of b(i): %d\n', b(i));
end
for i =  2: degree
   c(i)=b(i)+Xnew*c(i-1);
   fprintf('value of c(i): %d\n', c(i));
end
c(degree+1)=0;
Xold = Xnew;
Xnew=Xold-(b(degree+1)/c(degree));
disp(Xnew)

j=j+1;
 end
 printIteration(degree,a,b,c)
end
function []= printIteration(degree,a,b,c)
%button
uf =uifigure;
btn = uicontrol(uf);
btn.Style='pushbutton';
btn.String='Next';
btn.Callback=@ButtonPushed;
btn.Position = [20 20 100 22];
function ButtonPushed( event)
         disp('gggggg') 
        end
t=uitable(uf);
t.ColumnName = {'i','a(i)','b(i)','c(i)'};
t.Position = [20 20 500 300];
i=[degree:-1:0]
myData=[i(:),a(:), b(:),c(:)];%horzcat(a,b,c);
t.Data = myData;
%t.ColumnEditable = false;

end
function intialValue = getIntialValue()
prompt = {'Enter Your Start Point:'};
title = 'Input';
dims = [1 35];
definput = {'0','hsv'};
intialValue = inputdlg(prompt,title,dims,definput);
end
function poly = getPolynomial()
prompt = {'Enter Your Polynomial:'};
title = 'Input';
dims = [1 35];
definput = {'20','hsv'};
poly = inputdlg(prompt,title,dims,definput);
end