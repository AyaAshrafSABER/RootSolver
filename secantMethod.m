function [ ] = secantMethod(axes )
global f 
global AError
global nomOfIteration
global j
global x 
global a
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
pane =uifigure('Name', 'Result view', 'Color', [0 0.6 0.6], 'Position' , [0 0 2000 1000]);
axes=uiaxes('Parent', pane, 'Position', [100 100 500 600]);
axes.XGrid = 'on';axes.XAxisLocation = 'origin';axes.YAxisLocation = 'origin';
axes.YGrid = 'on';
axes.Title.String = 'Function';
func =string( getFunc());
a= sym(char(func));
z=linspace(-10,10,200);
%f1 = subs(a,z);
fplot(axes,[a],[-5 5]);
answer= getRequirements();
[initial1, initial2,maxErr,maxItr] = answer{:};
x0=str2num(initial1);
x1=str2num(initial2);
AError = str2num(maxErr);
nomOfIteration =str2num(maxItr);
x=zeros(nomOfIteration+2 ,1);
f=zeros(nomOfIteration+2 , 1);
x(1)=x0;
x(2)=x1;
j=1;

            f(1)=subs(a,x(1));
            f(2)=subs(a,x(2));
            
view(pane);
end

function view(pane)


t=uitable(pane);
lab1 = uilabel(pane,'Text','numberOfIteration(i)','Position',[100 350 100 32]);
itrEdit = uieditfield(pane,'numeric','Position',[200 365 100 22],'Editable','off');
lab2 = uilabel(pane,'Text','error','Position',[100 325 100 32]);
errorEdit = uieditfield(pane,'numeric','Position',[200 340 100 22],'Editable','off');
lab3 = uilabel(pane,'Text','root','Position',[100 300 100 32]);
rootEdit = uieditfield(pane,'numeric','Position',[200 315 100 22],'Editable','off');
           

initLbl1=uilabel(pane,'HorizontalAlignment' ,'right',...
            'Position',[501 358 23 15],...
            'Text', 'first initial point',...
            'Visible','off');
init1=uieditfield(pane,'numeric',...
    'Position',[539 354 100 22],...
    'Visible','off');
initLbl2=uilabel(pane,'HorizontalAlignment' ,'right',...
            'Position',[501 316 23 15],...
            'Text', 'second initial point',...
            'Visible','off');
init2=uieditfield(pane,'numeric',...
    'Position',[539 312 100 22],...
    'Visible','off');
     pressed = false;

slowBtn=uibutton(pane,'push',... 
     'Text', 'slow mode',...
     'Position' ,[523 253 100 22],...
     'ButtonPushedFcn', @(btn,event) nextButtonPushed(t,pressed,itrEdit,errorEdit,rootEdit));
 fastBtn=uibutton(pane,'push',...
     'Text','fast mode',...
     'Position', [523 213 100 22],...
     'ButtonPushedFcn', @(btn,event) resultButtonPushed(t));
     

end

function func = getFunc()
prompt = {'Enter Your Function:'};
title = 'Input';
dims = [1 35];
definput = {'sin(x)'};
func = inputdlg(prompt,title,dims,definput);
end
function[answer] =getRequirements()
prompt = {'Input your first intial point Xo','Input your second intial point X1','Input the albsolute error','Input max number of iteration'};
      dlg_title = 'Requirements';
      num_lines = [1 20];
      defaultans = {'-3','-2','10^-6','50'};
      answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
end
function []= printIteration(t,error)
global j f x 
global nomOfIteration
%global x
%global f
display('hi')
t.ColumnName = {'i','x(i)','f(x(i))','x(i-1)','f(x(i-1))','x(i+1)','error'};
t.Position = [20 20 500 300];
%i=[numOfIteration:-1:0];
row=[j-2,x(j-2), f(j-2),x(j-1),f(j-1),x(j),error];
oldData=get(t,'Data');
oldData(j-2,:)=row;
set(t,'Data',oldData);
t.ColumnEditable = false;

end
function nextButtonPushed(t,pressed,itrEdit,errEdit,rootEdit)
global x 
global AError
global f
global nomOfIteration
global j
global a
slowBtn.Text='next';
fastBtn.Visible='off';
pressed = true;
j=3;
error = abs( x(j-1)-x(j-2));
if(error >AError&& j < nomOfIteration+1)
    x(j)=x(j-1)-(f(j-1)*(x(j-2)-x(j-1)))/(f(j-2)-f(j-1));
                f(j)=subs(a,x(j));
   fprintf('value of x(i): %d\n', x(j));

error=abs(x(j)-x(j-1));
 printIteration(t,error)
 itrEdit.Value=j-2;
 errEdit.Value=error;
j=j+1;
else
    rootEdit.Value=x(j-1);
    pressed = false;
    nextBtn.Text='slow mode';
resultBtn.Visible='on';
 end
end
function resultButtonPushed(t)
global x 
global AError
global f
global nomOfIteration
global j
global a

    for j=3: nomOfIteration+1
          
                x(j)=x(j-1)-(f(j-1)*(x(j-2)-x(j-1)))/(f(j-2)-f(j-1));
                f(j)=subs(a,x(j));
                fprintf('value of x(i): %d\n', x(j));
                 error=abs( x(j)-x(j-1));
                  if error>AError
                       printIteration(t,error)
                       itrEdit.Value=j;
                       errEdit.Value=error;
                  else
                       rootEdit.Value=x(j-1);
                       break;
                  end
                 
    end
    
end

