%% Clear previous data
clear all;
clc;
clear;
%% Create serial object for Arduino
s = serial('/dev/cu.wchusbserial1420'); % change the COM Port number as needed
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

% while(get(s, 'BytesAvailable')==0)
% end
x = [];
y = [];
z = [];
while(length(x) < 250)
%     fprintf(s, '%i', slave);
%     fwrite(s, 's');
%     fprintf(s, '%i', command);
%     fwrite(s, 's');
      while(get(s, 'BytesAvailable')==0)
      end
      x_new = fscanf(s, '%d');
      y_new = fscanf(s, '%d');
      z_new = fscanf(s, '%d');
      x = [x, x_new]; %how to get readings from Arduino
      y = [y, y_new]; %how to get readings from Arduino
      z = [z, z_new]; %how to get readings from Arduino

      
      %disp(x_new);
      %disp(y_new);
      %disp(z_new);
end
disp('Execution Ended');
fclose(s);