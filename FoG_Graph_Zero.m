%close all;
clc;
%%Initialization
name = 'Test';
location = 'Lower-Leg';
test = 'FoG-Full';
date = '11-20-17';
data_points = 500;

%  Gx = Az;
%  Gy = Ax;
%  Gz = Ay;
%temp = Gy;
%Gy = Gz;
%Gz = temp;
%angle = matrix(1, 500);
for i = 1:500
angle(i) = atan(Ax(i)/Az(i))*(180/pi);
Gz1(i) = 1/Gz(i);
Gy1(i) = 1/Gy(i);
multiply(i) = abs(Gy(i)*Gz(i));
multiply1(i) = 1/multiply(i);
multiply3(i) = abs(Gy(i)*Gz(i)*Gx(i));
multiply31(i) = 1/multiply3(i);
square(i) = Gz(i)^2;
square2(i) = Gz(i)^2*Gy(i)^2;
square3(i) = Gz(i)^2*Gy(i)^2*Gx(i)^2;
absGy(i) = abs(Gy(i));
absGz(i) = abs(Gz(i));
end
figure;
plot(square);
figure;
plot(square2);
for i = 1:500
   if(Gz(i) < 0)
       zeroGz(i) = 0;
   else
       zeroGz(i) = Gz(i);
   end
   
   if(Gy(i) < 0)
       zeroGy(i) = 0;
   else
       zeroGy(i) = Gy(i);
   end
end
figure;
plot(zeroGy);
figure;
plot(zeroGz);

for i = 1:500
    zerosquare(i) = zeroGy(i)*zeroGz(i);
end
figure;
plot(zerosquare);
%save(strcat('data_',name,'_',location,'_',test,'_',date,'.mat'));
figure1 = figure; 
figure(figure1);
subplot(3,1,1), plot(Ax);xlim([0 data_points]); xlabel('Time (data points)'); ylabel('X Acc (raw)');
title(strcat(name, ' Accelerometer', {' '},location ,{' '}, test,{' '},date));
axis tight;

subplot(3,1,2), plot(Ay);xlim([0 data_points]); xlabel('Time (data points)'); ylabel('Y Acc (raw)');
axis tight;

subplot(3,1,3), plot(Az);xlim([0 data_points]); xlabel('Time (data points)'); ylabel('Z Acc (raw)');
%saveas(figure1, strcat(name, '_Accelerometer', '_',location, '_', test,'_',date, '.png'));
axis tight;
figure2 = figure;
figure(figure2);
subplot(3,1,1), plot(Gx);xlim([0 data_points]); xlabel('Time (data points)'); ylabel('X Ang Acc (raw)');
title(strcat(name, ' Gyroscope', {' '},location ,{' '}, test,{' '},date));
axis tight;

subplot(3,1,2), plot(Gy);xlim([0 data_points]); xlabel('Time (data points)'); ylabel('Y Ang Acc (raw)');
axis tight;

subplot(3,1,3), plot(Gz);xlim([0 data_points]); xlabel('Time (data points)'); ylabel('Z Ang Acc (raw)');
axis tight;

%saveas(figure2, strcat(name, '_Gyroscope', '_',location, '_', test,'_',date, '.png'));