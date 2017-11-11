%% Clear previous data
clear all;
clc;
clear;
%%Initialization
name = 'Jerry';
location = 'Lower-Leg';
test = 'Stopping-Test-1';
date = '10-29-17';
data_points = 500;

%% Create serial object for Arduino
%s = serial('/dev/cu.wchusbserial1420'); % change the COM Port number as needed
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
Ax = [];
Ay = [];
Az = [];
Gx = [];
Gy = [];
Gz = [];
counter = 1;
while(length(Ax) < data_points)
    while(get(s, 'BytesAvailable')==0)
    end
    disp(counter);
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
    counter = counter+1;
end

save(strcat('data_',name,'_',location,'_',test,'_',date,'.mat'));

figure1 = figure; 
figure(figure1);
subplot(3,1,1), plot(Ax);xlim([0 data_points]); xlabel('Time (data points)'); ylabel('X Ang Acc (raw)');
title(strcat(name, ' Gyroscope', {' '},location, {' '}, test,{' '},date));
subplot(3,1,2), plot(Ay);xlim([0 data_points]); xlabel('Time (data points)'); ylabel('Y Ang Acc (raw)');
subplot(3,1,3), plot(Az);xlim([0 data_points]); xlabel('Time (data points)'); ylabel('Z Ang Acc (raw)');
saveas(figure1, strcat(name, ' Gyroscope', ' ',location, ' ', test,' ',date, '.png'));

figure2 = figure;
figure(figure2);
subplot(3,1,1), plot(Gx);xlim([0 data_points]); xlabel('Time (data points)'); ylabel('X Acc (raw)');
title(strcat(name, ' Accelerometer', {' '},location, {' '}, test,{' '},date));
subplot(3,1,2), plot(Gy);xlim([0 data_points]); xlabel('Time (data points)'); ylabel('Y Acc (raw)');
subplot(3,1,3), plot(Gz);xlim([0 data_points]); xlabel('Time (data points)'); ylabel('Z Acc (raw)');
saveas(figure1, strcat(name, ' Accelerometer', ' ',location, ' ', test,' ',date, '.png'));

fclose(s);