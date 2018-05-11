function   birgeVieta(type,func,interval,tolerance,maxIter,mode)% 1 for read from file 0 for normal
global Xnew 
global AError
global Xold
global nomOfIteration 
global j btnNext btnRslt
global degree a b c
if(type==0)
poly = func;
poly=string(poly);
y= sym(char(poly));
a=sym2poly(y);
answer= getRequirements();
[first, second,third] = answer{:};
Xnew =str2num(first);%getIntialValue();
AError = str2num(second);
nomOfIteration =str2num(third);
else
    readFile(func,interval,tolerance,maxIter);
end
x=linspace(-4,8);
f1 = polyval(a,x);
uf =uifigure('Name', 'Result view', 'Color', [0 0.6 0.6], 'Position' , [0 0 2000 1000]);
axes=uiaxes('Parent', uf, 'Position', [100 100 500 600]);
axes.XGrid = 'on';axes.XAxisLocation = 'origin';axes.YAxisLocation = 'origin';
axes.YGrid = 'on';
axes.Title.String = 'Function';
createView(uf);
plot(axes,x,f1);
zoom(axes, 'on');
if(strcmp(mode,'fast'))
    btnNext.Visible='off';
    btnRslt.Visible='on';
elseif (strcmp(mode,'single'))
    btnNext.Visible='on';
    btnRslt.Visible='off';
end
degree =length(a)-1;
Xold=Xnew-AError-1;
j=1;
%apply the method
 b = zeros(degree,0);
 b(1)=a(1);
 c = zeros(degree,0);
 c(1)=a(1);


end
function readFile(func,interval,tolerance,maxIter)
global Xnew 
global AError
global Xold
global nomOfIteration a
Xnew=interval(1);
Xold=interval(2);
AError=tolerance;
nomOfIteration=maxIter;
poly = func;
poly=string(poly);
y= sym(char(poly));
a=sym2poly(y);
end
function createView(uf)
global btnNext btnRslt timeEdit timeLbl
global lab3 
t=uitable('Parent', uf);
t.Visible = 'off';
t.ColumnName = {'i','a(i)','b(i)','c(i)'};
t.ColumnWidth = {50,130,130,130};
t.RowName = {};
t.ForegroundColor = [0 0.451 0.7412];
t.Position=[800 150 440 250];
t.FontSize = 15;
lab1 = uilabel(uf,'Text','numberOfIteration(i)','Position',[800 600 150 32]);
lab1.FontSize = 15;
itrEdit = uieditfield(uf,'numeric','Position',[1100 600 100 22],'Editable','off');
itrEdit.FontSize = 15;
itrEdit.BackgroundColor=[0 0.6 0.6];
lab2 = uilabel(uf,'Text','Xi','Position',[800 550 100 32]);
lab2.FontSize = 15;
XiEdit = uieditfield(uf,'numeric','Position',[1100 550 100 22],'Editable','off');
XiEdit.FontSize = 15;
XiEdit.BackgroundColor=[0 0.6 0.6];
lab3 = uilabel(uf,'Text','root','Position',[800 500 100 32]);
lab3.FontSize = 15;
lab3.Visible='off';
rootEdit = uieditfield(uf,'numeric','Position',[1100 500 100 22],'Editable','off');
rootEdit.FontSize = 15;
rootEdit.Visible='off';
rootEdit.BackgroundColor=[0 0.6 0.6];
btnNext = uibutton(uf,'push','Text', 'Next','Position',[1100, 650, 100, 40],'ButtonPushedFcn', @(btn,event) nextButtonPushed(t,itrEdit,XiEdit,rootEdit));
btnNext.FontSize = 20;
btnNext.FontName='Arial';
btnRslt = uibutton(uf,'push','Text', 'Result','Position',[900, 650, 100, 40],'ButtonPushedFcn',  @(btn,event) resultButtonPushed(t,itrEdit,XiEdit,rootEdit));
btnRslt.FontSize = 20;
btnRslt.FontName='Arial';
timeLbl = uilabel(uf,'Text','Time consumed ','Position',[875 100 130 32]);
timeLbl.FontSize = 15;
timeLbl.FontColor = [1 0 0];
timeLbl.Visible='off';
timeEdit = uieditfield(uf,'numeric','Position',[1075 115 100 32],'Editable','off');
timeEdit.Visible ='off';
timeEdit.FontSize = 15;
timeEdit.FontColor = [1 0 0];
timeEdit.BackgroundColor=[0 0.6 0.6];
end
function nextButtonPushed(t,itrEdit,XiEdit,rootEdit)
global Xnew btnRslt
global AError
global Xold btnNext
global nomOfIteration
global j
global lab3 
global degree a b c
btnRslt.Visible='off';
if(abs( Xnew-Xold)>AError&& j < nomOfIteration+1)
for i =  2: degree+1
   b(i)=a(i)+Xnew*b(i-1);
end
for i =  2: degree
   c(i)=b(i)+Xnew*c(i-1);
end
c(degree+1)=0;
Xold = Xnew;
try 
Xnew=Xold-(b(degree+1)/c(degree));
catch
     errordlg('division by zero occured','error',[1 35]);
end
 printIteration(t,degree,a,b,c)
 itrEdit.Value=j;
 XiEdit.Value=Xnew;
j=j+1;
else
    rootEdit.Value=Xnew;
    lab3.Visible='on';
    rootEdit.Visible='on';
    btnNext.Enable='off';
    
end
 if(j>nomOfIteration)
    errordlg('Exceeded Max Nomber Of Iteration','error',[1 35]);
 end    

end
function resultButtonPushed(t,itrEdit,XiEdit,rootEdit)
global Xnew btnNext
global AError timeLbl
global Xold timeEdit
global nomOfIteration
global j
global degree a b c
btnNext.Visible='off';
tic;
while(abs( Xnew-Xold)>AError&& j < nomOfIteration+1)
for i =  2: degree+1
   b(i)=a(i)+Xnew*b(i-1);
end
for i =  2: degree
   c(i)=b(i)+Xnew*c(i-1);
end
c(degree+1)=0;
Xold = Xnew;
try
Xnew=Xold-(b(degree+1)/c(degree));
catch
     errordlg('division by zero occured','error',[1 35]);
      break;
end 
 printIteration(t,degree,a,b,c)
 pause(1);
 itrEdit.Value=j;
 XiEdit.Value=Xnew;
j=j+1;
end
time=toc;
timeLbl.Visible='on';
timeEdit.Visible='on';
timeEdit.Value=time;
if(j>nomOfIteration)
    errordlg('Exceeded Max Nomber Of Iteration','error',[1 35]);
end    
 rootEdit.Value=Xnew;
end
function[answer] =getRequirements()
prompt = {'Input your intial point Xo','Input the albsolute error','Input max number of iteration'};
      dlg_title = 'Requirements';
      num_lines = [1, length(dlg_title)+20];
      defaultans = {'-3','10^-6','50'};
      answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
end
function []= printIteration(t,degree,a,b,c)
t.Visible = 'on';
i=[degree:-1:0];
myData=[i(:),a(:), b(:),c(:)];%horzcat(a,b,c);
t.Data = myData;
t.ColumnEditable = false;
end
