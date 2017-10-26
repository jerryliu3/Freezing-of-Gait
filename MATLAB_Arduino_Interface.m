%% Clear previous data
clear all;
clc;
clear;
%% Create serial object for Arduino
s = serial('COM9'); % change the COM Port number as needed
set(s, 'BaudRate', 9600);
set(s, 'DataBits', 8);
set(s, 'StopBits', 1);
set(s, 'Parity', 'none');
%s.InputBufferSize = 1; % read only one byte every time
while(true)
    try
        fopen(s);
        break;
    catch err
        fclose(instrfind);
    end
end
%% Get User Input
while(true)
    command = input('Which command do you want: ');
    %used to write basic information to the slave (in this case the master
    %Arduino)
    fprintf(s, '%i', slave);
    fwrite(s, 's');
    fprintf(s, '%i', command);
    fwrite(s, 's');
    while(get(s, 'BytesAvailable')==0)
    end
    %a=fread(s, 1); %how to get readings from Arduino
end
disp('Execution Ended');
fclose(s);
clear all;