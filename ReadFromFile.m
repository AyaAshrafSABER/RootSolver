function [methodNum,func,interval,tolerance,maxIter] = ReadFromFile(filename)
fileID = fopen(filename);
line = fgetl(fileID);
counter = 1;
while ischar(line)
    if(counter == 1)
        methodNum = line;
    elseif(counter == 2)
            func = line;
    elseif(counter == 3)
            interval = line;
    elseif(counter == 4)
            tolerance = line;
    else
        maxIter = line;        
    end
    line = fgetl(fileID);
    counter = counter+1;
end
fclose(fileID);
interval = str2num(interval);
methodNum = str2num(methodNum);
tolerance = str2num(tolerance);
maxIter = str2num(maxIter);
