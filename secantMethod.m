function [ ] = secantMethod(type,func,interval,tolerance,maxIter,mode)%1 for read from file
global f 
global AError
global nomOfIteration
global j initial1 initial2
global x slowBtn fastBtn
global a pressed
pressed = false;
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
pane =uifigure('Name', 'Result view', 'Color', [0 0.6 0.6], 'Position' , [0 0 2000 1000]);
axes=uiaxes('Parent', pane, 'Position', [800 100 500 600]);
axes.XGrid = 'on';axes.XAxisLocation = 'origin';axes.YAxisLocation = 'origin';
axes.YGrid = 'on';
axes.Title.String = 'Function';

if(type==0)
func =string( func);
a= sym(char(func));
answer= getRequirements();

[init1, init2,maxErr,maxItr] = answer{:};
initial1=str2num(init1);
initial2=str2num(init2);
AError = str2num(maxErr);
nomOfIteration =str2num(maxItr);
else
    try
    readFile(func,interval,tolerance,maxIter);
    catch 
    end
end
fplot(axes,[a],[-5 5]);
view(pane);
zoom(axes, 'on');
if(strcmp(mode,'fast'))
    slowBtn.Visible='off';
    fastBtn.Visible='on';
elseif (strcmp(mode,'single'))
    slowBtn.Visible='on';
    fastBtn.Visible='off';
end
x=zeros(nomOfIteration+2 ,1);
f=zeros(nomOfIteration+2 , 1);
x(1)=initial1;
x(2)=initial2;
j=1;
f(1)=subs(a,x(1));
f(2)=subs(a,x(2));      

end
function readFile(func,interval,tolerance,maxIter)
global AError a
global nomOfIteration initial1 initial2
AError=tolerance;
nomOfIteration=maxIter;
initial1=interval(1);
initial2=interval(2);
func =string( func);
a= sym(char(func));

end
function view(pane)
global slowBtn fastBtn lab3 timeLbl timeEdit
global errorEdit rootEdit itrEdit
t=uitable(pane );
t.Visible='off';
t.ColumnName = {'i','x(i)','f(x(i))','x(i-1)','f(x(i-1))','x(i+1)','error'};
t.Position = [50 80 700 300];
t.ColumnWidth = {40,100,100,100,120,120,120};
t.RowName = {};
t.ForegroundColor = [0 0.451 0.7412];
t.FontSize = 15;
lab1 = uilabel(pane,'Text','numberOfIteration(i)','Position',[90 580 150 32]);
lab1.FontSize = 15;
itrEdit = uieditfield(pane,'numeric','Position',[300 600 100 22],'Editable','off');
itrEdit.FontSize = 15;
itrEdit.BackgroundColor=[0 0.6 0.6];
lab2 = uilabel(pane,'Text','error','Position',[100 530 100 32]);
lab2.FontSize = 15;
errorEdit = uieditfield(pane,'numeric','Position',[300 550 100 22],'Editable','off');
errorEdit.FontSize = 15;
errorEdit.BackgroundColor=[0 0.6 0.6];
lab3 = uilabel(pane,'Text','root','Position',[100 500 100 32]);
lab3.FontSize = 15;
lab3.Visible='off';
rootEdit = uieditfield(pane,'numeric','Position',[300 500 100 22],'Editable','off');
rootEdit.FontSize = 15;
rootEdit.Visible='off';
rootEdit.BackgroundColor=[0 0.6 0.6];
initLbl1=uilabel(pane,'HorizontalAlignment' ,'right','Position',[501 358 23 15],'Text', 'first initial point','Visible','off');
init1=uieditfield(pane,'numeric','Position',[539 354 100 22],'Visible','off');
initLbl2=uilabel(pane,'HorizontalAlignment' ,'right','Position',[501 316 23 15],'Text', 'second initial point','Visible','off');
init2=uieditfield(pane,'numeric','Position',[539 312 100 22],'Visible','off');
slowBtn=uibutton(pane,'push','Text', 'slow mode','Position' ,[200 400 110 40],'ButtonPushedFcn', @(btn,event) nextButtonPushed(t,itrEdit,errorEdit,rootEdit));
fastBtn=uibutton(pane,'push','Text','fast mode','Position', [500 400 100 40],'ButtonPushedFcn', @(btn,event) resultButtonPushed(t));
slowBtn.FontSize = 20;
slowBtn.FontName='Arial';
fastBtn.FontSize = 20;
fastBtn.FontName='Arial';
timeLbl = uilabel(pane,'Text','Time consumed ','Position',[500 550 130 32]);
timeLbl.FontSize = 15;
timeLbl.FontColor = [1 0 0];
timeLbl.Visible='off';
timeEdit = uieditfield(pane,'numeric','Position',[480 515 100 32],'Editable','off');
timeEdit.Visible ='off';
timeEdit.FontSize = 15;
timeEdit.FontColor = [1 0 0];
timeEdit.BackgroundColor=[0 0.6 0.6];
end
function[answer] =getRequirements()
prompt = {'Input your first intial point Xo','Input your second intial point X1','Input the albsolute error','Input max number of iteration'};
      dlg_title = 'Requirements';
      num_lines = [1, length(dlg_title)+20];
      defaultans = {'-3','-2','10^-6','50'};
      answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
end
function []= printIteration(t,error)
global j f x 
t.Visible='on';
%global x
%global f
%i=[numOfIteration:-1:0];
row=[j-2,x(j-2), f(j-2),x(j-1),f(j-1),x(j),error];
oldData=get(t,'Data');
oldData(j-2,:)=row;
set(t,'Data',oldData);
t.ColumnEditable = false;

end
function nextButtonPushed(t,itrEdit,errEdit,rootEdit)
global x slowBtn fastBtn 
global AError
global f pressed
global nomOfIteration
global j lab3
global a
if(~pressed)
slowBtn.Text='next';
fastBtn.Visible='off';
pressed = true;
j=3;
end
error = abs( x(j-1)-x(j-2));
if(error >AError&& j < nomOfIteration+1)
    if((f(j-2)-f(j-1))==0)
        errordlg('division by zero occured , method diverge','error',[1 35]);
    elseif(j>nomOfIteration)
         errordlg('exceeded max number of iteration , method failed','error',[1 35]);
    else
    x(j)=x(j-1)-(f(j-1)*(x(j-2)-x(j-1)))/(f(j-2)-f(j-1));
                f(j)=subs(a,x(j));
fprintf('value of x(i): %d\n', x(j));
error=abs(x(j)-x(j-1));
printIteration(t,error)
itrEdit.Value=j-2;
disp(error);
errEdit.Value=error;
j=j+1;
    end
else
    lab3.Visible='on';
    rootEdit.Visible='on';
    rootEdit.Value=x(j-1);
    pressed = false;
    slowBtn.Text='slow mode';
    %fastBtn.Visible='on';
    rootEdit.Editable='off';
    itrEdit.Editable='off';
    errEdit.Editable='off';
    slowBtn.Enable='off';
end
end
function resultButtonPushed(t)
global x lab3
global AError timeEdit
global f rootEdit timeLbl
global nomOfIteration
global j itrEdit fastBtn
global a errorEdit slowBtn
slowBtn.Enable='off';
tic;
    for j=3: nomOfIteration+1
          if((f(j-2)-f(j-1))==0)
        errordlg('division by zero occured , method diverge','error',[1 35]);
        break;
		elseif(j>nomOfIteration)
         errordlg('exceeded max number of iteration , method failed','error',[1 35]);
         break;
		else
                x(j)=x(j-1)-(f(j-1)*(x(j-2)-x(j-1)))/(f(j-2)-f(j-1));
                f(j)=subs(a,x(j));
                fprintf('value of x(i): %d\n', x(j));
                 error=abs( x(j)-x(j-1));
                  if error>AError
                       printIteration(t,error)
                       itrEdit.Value=j;
                       errorEdit.Value=error;
                  else
                       lab3.Visible='on';
                       rootEdit.Visible='on';
                       rootEdit.Value=x(j-1);
                       printIteration(t,error)
                       break;
                  end
          end
    end
    time=toc;
timeLbl.Visible='on';
timeEdit.Visible='on';
timeEdit.Value=time;
	                   itrEdit.Value=j-2;
                       errorEdit.Value=error;
                        lab3.Visible='on';
                       rootEdit.Visible='on';
					   rootEdit.Value=x(j-1);
                       fastBtn.Enable='off';
end

