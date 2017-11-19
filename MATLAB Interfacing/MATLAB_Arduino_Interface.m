%% Clear previous data
clear all;
clc;
%%Initialization
data_points = 500;
%% Create serial object for Arduino
s = serial('/dev/cu.wchusbserial1410'); % change the COM Port number as needed
%s = serial('COM9'); % change the COM Port number as needed
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
Ax = [];
Ay = [];
Az = [];
Gx = [];
Gy = [];
Gz = [];

for i = 0:10
    while(length(Ax) < 50)
        %disp(length(Ax));
        while(get(s, 'BytesAvailable') == 0)
        end
        Ax_new = fscanf(s, '%d');
        Ay_new = fscanf(s, '%d');
        Az_new = fscanf(s, '%d');
        Gx_new = fscanf(s, '%d');
        Gy_new = fscanf(s, '%d');
        Gz_new = fscanf(s, '%d');
        Ax = [Ax, Ax_new]; %how to get readings from Arduino
        Ay = [Ay, Ay_new]; %how to get readings from Arduino
        Az = [Az, Az_new]; %how to get readings from Arduino
        Gx = [Gx, Gx_new]; %how to get readings from Arduino
        Gy = [Gy, Gy_new]; %how to get readings from Arduino
        Gz = [Gz, Gz_new]; %how to get readings from Arduino
    end
    
    Gz_max = max(Gz);
    Gz_min = min(Gz);
    diff = Gz_max - Gz_min;
    disp(diff);
    if(diff >= 20000)
        disp('Normal walking!!!');
    elseif(diff < 5000)
        disp('Stopping');
    else
        disp('Freezing');
    end
    Ax = [];
    Ay = [];
    Az = [];
    Gx = [];
    Gy = [];
    Gz = [];
end

figure;
subplot(3,1,1), plot(Ax);xlim([0 data_points]); xlabel('Time'); ylabel('X Acceleration Value');
subplot(3,1,2), plot(Ay);xlim([0 data_points]); xlabel('Time'); ylabel('Y Acceleration Value');
subplot(3,1,3), plot(Az);xlim([0 data_points]); xlabel('Time'); ylabel('Z Acceleration Value');

figure;
subplot(3,1,1), plot(Gx);xlim([0 data_points]); xlabel('Time'); ylabel('X Angular Acceleration Value');
subplot(3,1,2), plot(Gy);xlim([0 data_points]); xlabel('Time'); ylabel('Y Angular Acceleration Value');
subplot(3,1,3), plot(Gz);xlim([0 data_points]); xlabel('Time'); ylabel('Z Angular Acceleration Value');

fclose(s);

save('Test.mat');