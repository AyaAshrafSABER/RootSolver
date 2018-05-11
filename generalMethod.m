function generalMethod(type,func,interval,tolerance,maxIter,mode)% 1 for read from file 0 for normal
global first maxItr Tolerance z
global second index1 index2 btnNext btnRslt
global X1 X2 index roots flag
if (type==0)
maxItr=10;
Tolerance=.000000001;
answer=getRequirements();
[first, second] = answer{:};
first= str2num(first);
second = str2num(second);
y=string(func);
z=sym(char(y));
else
    fileRead(func,interval,tolerance,maxIter);
end

%method
delta=.1;
X1=first;
X2=first+delta;
index=1;
index1=1;
index2=1;
roots=strings(10,2);
flag=0;
createView(z);
if(strcmp(mode,'fast'))
    btnNext.Visible='off';
    btnRslt.Visible='on';
elseif (strcmp(mode,'single'))
    btnNext.Visible='on';
    btnRslt.Visible='off';
end


end
function createView(z)
global first btnNext btnRslt
global second timeLbl timeEdit
uf = uifigure('Name', 'Result view', 'Color', [0 0.6 0.6], 'Position' , [0 0 2000 1000]);
ax=uiaxes('Parent', uf, 'Position', [100 100 500 600]);
            ax.XGrid = 'on';
            ax.YGrid = 'on';
            ax.Title.String = 'Result plot';
hold(ax,'on');
ax.YLimMode = 'auto';
fplot(ax,z,[first,second],'b');
zoom(ax, 'on');
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
rootLbl = uilabel(uf,'Text','Roots','Position',[1025 575 100 32]);
rootLbl.FontSize = 25;
rootLbl.FontColor = [0.902 0.902 0.902];
tableN = uitable(uf,'ColumnName',{'NewtonRaphson'});
tableN.Position = [850 250 200 300];
tableB = uitable(uf,'ColumnName',{'Bisection'});
tableB.Position = [1050 250 200 300];
btnNext = uibutton(uf,'push','Text', 'Next','Position',[1100, 650, 100, 40],'ButtonPushedFcn', @(btn,event) nextButtonPushed(z,ax,tableN,tableB));
btnNext.FontSize = 20;
btnNext.FontName='Arial';
btnRslt = uibutton(uf,'push','Text', 'Result','Position',[900, 650, 100, 40],'ButtonPushedFcn', @(btn,event) resultButtonPushed(z,ax,tableN,tableB));
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
function fileRead(func,interval,tolerance,maxIter)
global maxItr Tolerance first second z
maxItr=maxIter;
Tolerance = tolerance;
first = interval(1);
second = interval(2);
disp(func);
z=sym(func);
end
function resultButtonPushed(z,ax,tableN,tableB)
global X1 X2 index roots flag btnNext first timeLbl
global second index1 index2 maxItr Tolerance timeEdit
tic;
btnNext.Visible='off';
Y1 = subs(z,X1);
Y2= subs(z,X2);
while((X2<second))
    if(abs(Y1-Y2)<1)
         [error ,root] = Newton_Raphson(z,maxItr, Tolerance,X1);
         disp(error)
         if ((error == "") && (flag==0))
             flag=1;
           roots(index)=root;
           if(root<second && root> first)
           oldData=get(tableN,'Data');
           oldData(index1,:)= root;
           set(tableN,'Data',oldData);
           index1=index1+1;
           index=index+1;
           dr=diff(z);
          Ydr=abs(subs(dr,root));
    while(Ydr<.01)
        disp('repeated')
        roots(index)= root;
        oldData=get(tableN,'Data');
           oldData(index1,:)= root;
           set(tableN,'Data',oldData); 
           index1=index1+1;
        index=index+1;
        dr=diff(dr);
        Ydr=abs(subs(dr,root));
    end
           end
     end
    end
    if((Y1*Y2)<0)
    root=Bisec(z,X1, X2, Tolerance,maxItr);
       roots(index)= root;
           oldData=get(tableB,'Data');
           oldData(index2,:)= root;
           set(tableB,'Data',oldData);
           index2=index2+1;
    index= index+1;
    dr=diff(z);
    Ydr=abs(subs(dr,root));
    while(Ydr<.01)
        disp('repeated')
        roots(index)= root;
        oldData=get(tableB,'Data');
           oldData(index2,:)= root;
           set(tableB,'Data',oldData); 
           index2=index2+1;
        index=index+1;
        dr=diff(dr);
        Ydr=abs(subs(dr,root));
    end
    end
    clear();
     draw(ax,X1);
     pause(.5);
     X1=X1+.1;%delta
    X2=X2+.1;%delta
    Y1 = subs(z,X1);
    Y2= subs(z,X2);
end
time=toc;
timeLbl.Visible='on';
timeEdit.Visible='on';
timeEdit.Value=time;
end
function nextButtonPushed(z,ax,tableN,tableB)
global X1 X2 index roots flag btnRslt
global second index1 index2
btnRslt.Visible='off';
Y1 = subs(z,X1);
Y2= subs(z,X2);
if((X2<second))
    if(abs(Y1-Y2)<1)
       % disp('positive'+(Y1*Y2))
         [error ,root] = Newton_Raphson(z,10, .000000001,X1);
         disp(error)
         if ((error == "") && (flag==0))
             flag=1;
           roots(index)=root;
           oldData=get(tableN,'Data');
           oldData(index1,:)= root;
           set(tableN,'Data',oldData);
           index1=index1+1;
           index=index+1;
           dr=diff(z);
          Ydr=abs(subs(dr,root));
    while(Ydr<.01)
        disp('repeated')
        roots(index)= root;
        oldData=get(tableN,'Data');
           oldData(index1,:)= root;
           set(tableN,'Data',oldData); 
           index1=index1+1;
        index=index+1;
        dr=diff(dr);
        Ydr=abs(subs(dr,root));
    end
         end
    end
    if((Y1*Y2)<0)
    root=Bisec(z,X1, X2, .000000001,10);
       roots(index)= root;
           oldData=get(tableB,'Data');
           oldData(index2,:)= root;
           set(tableB,'Data',oldData);
           index2=index2+1;
    index= index+1;
    dr=diff(z);
    Ydr=abs(subs(dr,root));
    while(Ydr<.01)
        disp('repeated')
        roots(index)= root;
        oldData=get(tableB,'Data');
           oldData(index2,:)= root;
           set(tableB,'Data',oldData); 
           index2=index2+1;
        index=index+1;
        dr=diff(dr);
        Ydr=abs(subs(dr,root));
    end

    end
    clear();
    draw(ax,X1);
     X1=X1+.1;%delta
    X2=X2+.1;%delta
    Y1 = subs(z,X1);
    Y2= subs(z,X2);
end
end
function clear()
global h1 h2
delete(h2);
delete(h1);
end
function draw(ax,X1)
global h1 h2
h1=plot(ax,[X1 X1],get(ax,'YLim'),'r');
h2=plot(ax,[X1+.1 X1+.1],get(ax,'YLim'),'r');
end
 function answer =getRequirements()
prompt = {'Input start of your interval','Input end of the interval'};
      dlg_title = 'Requirements';
      num_lines = [1, length(dlg_title)+20];
      default={'-3','5'};
      answer = inputdlg(prompt,dlg_title,num_lines,default);
end