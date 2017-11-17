close all;
clc;

%1 = positive, -1 = negative
derivative = 0;
pos_in_signal = 1;
start_countdown = false;
countdown = 10;
last_classification = 0;

while(countdown > 0)
    if(start_countdown)
        countdown = countdown - 1;
    end
    Ax_new = Ax(pos_in_signal);
    Ay_new = Ay(pos_in_signal);
    Az_new = Az(pos_in_signal);
    Gx_new = Gx(pos_in_signal);
    Gy_new = Gy(pos_in_signal);
    Gz_new = Gz(pos_in_signal);
    pos_in_signal = pos_in_signal + 1;
    if(Gz_new > 20000)
        start_countdown = true;
        last_classification = length(Gz);
    end
end

counter = 0;

Gz_max = 0;
Gz_min = 0;
min_found = false;
%Feature 1
num_peaks = 0;

while(pos_in_signal < length(Ax))
    Ax_new = Ax(pos_in_signal);
    Ay_new = Ay(pos_in_signal);
    Az_new = Az(pos_in_signal);
    Gx_new = Gx(pos_in_signal);
    Gy_new = Gy(pos_in_signal);
    Gz_new = Gz(pos_in_signal);
    %disp(counter);
    %if they are not taking a normal step
    if(Gz_new < 20000)
        
        %calculate if new max or min
        if(Gz_new > Gz_max && min_found)
            Gz_max = Gz_new;
        elseif(Gz_new < Gz_min)
            Gz_min = Gz_new;
            min_found = true;
        end
        
        %ignore when values are constant because saddle points are useless
        %so derivative of 0 has no impact
        if(Gz(pos_in_signal)-Gz(pos_in_signal-1) > 1200)
            if(derivative == -1)
                num_peaks = num_peaks+1;
            end
            derivative = 1;
        elseif(Gz(pos_in_signal)-Gz(pos_in_signal-1) < -1200)
            if(derivative == 1)
                num_peaks = num_peaks+1;
            end
            derivative = -1;
        end
        if(num_peaks >= 6 && Gz_max - Gz_min < 20000 && Gz_max - Gz_min > 10000)
            disp('Freezing');
            disp(pos_in_signal);
            counter = 0;
            Gz_max = 0;
            Gz_min = 0;
            min_found = false;
            num_peaks = 0;
        elseif(counter >= 40)
            disp('Either normal walking or stopping');
            %classification
            if(num_peaks <= 3)
                disp('stopping?');
            else
                disp('normal walking');
            end
            disp(pos_in_signal);
            counter = 0;
            Gz_max = 0;
            Gz_min = 0;
            min_found = false;
            num_peaks = 0;
        else
            %disp('Unknown');
        end
    else
        %disp('Normal step');
        %disp(pos_in_signal);
        %reset everything since normal step
        counter = 0;
        Gz_max = 0;
        Gz_min = 0;
        min_found = false;
        num_peaks = 0;
    end
    counter = counter + 1;
    pos_in_signal = pos_in_signal + 1;
end

% figure;
% subplot(3,1,1), plot(Ax);xlim([0 data_points]); xlabel('Time'); ylabel('X Acceleration Value');
% subplot(3,1,2), plot(Ay);xlim([0 data_points]); xlabel('Time'); ylabel('Y Acceleration Value');
% subplot(3,1,3), plot(Az);xlim([0 data_points]); xlabel('Time'); ylabel('Z Acceleration Value');

figure;
subplot(3,1,1), plot(Gx);xlim([0 data_points]); xlabel('Time'); ylabel('X Angular Acceleration Value');
subplot(3,1,2), plot(Gy);xlim([0 data_points]); xlabel('Time'); ylabel('Y Angular Acceleration Value');
subplot(3,1,3), plot(Gz);xlim([0 data_points]); xlabel('Time'); ylabel('Z Angular Acceleration Value');