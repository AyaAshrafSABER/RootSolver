function [ rts ] = birgeVieta(axes)
global Xnew 
global AError
global Xold
global nomOfIteration
global j
global degree a b c
poly = getPolynomial();
poly=string(poly);
y= sym(char(poly));
a=sym2poly(y);
x=linspace(-4,8);
f1 = polyval(a,x);
plot(axes,x,f1,'r--')
degree =length(a)-1;
answer= getRequirements();
[first, second,third] = answer{:};
Xnew =str2num(first);%getIntialValue();
AError = str2num(second);
Xold=Xnew-AError-1;
nomOfIteration =str2num(third);
j=1;
%apply the method
 b = zeros(degree,0);
 b(1)=a(1);
 c = zeros(degree,0);
 c(1)=a(1);

createView();
end
function createView()
uf =uifigure;
t=uitable(uf);
lab1 = uilabel(uf,'Text','numberOfIteration(i)','Position',[100 350 100 32]);
itrEdit = uieditfield(uf,'numeric','Position',[200 365 100 22],'Editable','off');
lab2 = uilabel(uf,'Text','Xi','Position',[100 325 100 32]);
XiEdit = uieditfield(uf,'numeric','Position',[200 340 100 22],'Editable','off');
lab3 = uilabel(uf,'Text','root','Position',[100 300 100 32]);
rootEdit = uieditfield(uf,'numeric','Position',[200 315 100 22],'Editable','off');
btnNext = uibutton(uf,'push',...
                 'Text', 'next',...
               'Position',[400, 400, 100, 22],...
               'ButtonPushedFcn', @(btn,event) nextButtonPushed(t,itrEdit,XiEdit,rootEdit));
btnResult = uibutton(uf,'push',...
                 'Text', 'finalResult',...
               'Position',[100, 400, 100, 22],...
               'ButtonPushedFcn', @(btn,event) resultButtonPushed(t));
end
function nextButtonPushed(t,itrEdit,XiEdit,rootEdit)
global Xnew 
global AError
global Xold
global nomOfIteration
global j
global degree a b c
if(abs( Xnew-Xold)>AError&& j < nomOfIteration+1)
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
 printIteration(t,degree,a,b,c)
 itrEdit.Value=j;
 XiEdit.Value=Xnew;
j=j+1;
else
    rootEdit.Value=Xnew;
 end
end
function resultButtonPushed(t)
       disp('result')
end
function[answer] =getRequirements()
prompt = {'Input your intial point Xo','Input the albsolute error','Input max number of iteration'};
      dlg_title = 'Requirements';
      num_lines = [1 20];
      defaultans = {'-3','10^-6','50'};
      answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
end
function []= printIteration(t,degree,a,b,c)
t.ColumnName = {'i','a(i)','b(i)','c(i)'};
t.Position = [20 20 500 300];
i=[degree:-1:0];
myData=[i(:),a(:), b(:),c(:)];%horzcat(a,b,c);
t.Data = myData;
t.ColumnEditable = false;
end
function poly = getPolynomial()
prompt = {'Enter Your Polynomial:'};
title = 'Input';
dims = [1 35];
definput = {'x^4-9*x^3-2*x^2+120*x-130','hsv'};
poly = inputdlg(prompt,title,dims,definput);
end
