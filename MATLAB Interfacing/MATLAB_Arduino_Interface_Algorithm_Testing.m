close all;
clc;
%Gz = Gy;
Gz = -Gz;
%1 = positive, -1 = negative
derivative = 0;
pos_in_signal = 2;
start_countdown = false;

last_classification = 0;
counter = 0;

Gz_max = 0;
Gz_min = 0;
min_found = false;
%Feature 1
num_peaks = 0;
average_value = 0;

classification = [1, length(Ax)];
for i = 1:500
    classification(1, i) = -1;
end
while(pos_in_signal < length(Ax))
    Ax_new = Ax(pos_in_signal);
    Ay_new = Ay(pos_in_signal);
    Az_new = Az(pos_in_signal);
    Gx_new = Gx(pos_in_signal);
    Gy_new = Gy(pos_in_signal);
    Gz_new = Gz(pos_in_signal);
    %if they are not taking a normal step
    if(Gz_new < 20000)
%         if(min_found)
%             average_value = (average_value * counter + Gz_new)/(counter + 1);
%         end
        %calculate if new max or min
        if(Gz_new > Gz_max && min_found)
            Gz_max = Gz_new;
        elseif(Gz_new < Gz_min)
            Gz_min = Gz_new;
            min_found = true;
        end
        
        %ignore when values are constant because saddle points are useless
        %so derivative of 0 has no impact
        if(Gz(pos_in_signal)-Gz(pos_in_signal-1) > 500)
            if(derivative == -1)
                %num_peaks = num_peaks+1;
            end
            derivative = 1;
        elseif(Gz(pos_in_signal)-Gz(pos_in_signal-1) < -500)
            if(derivative == 1)
                num_peaks = num_peaks+1;
                average_value = (average_value * counter + Gz_new)/(counter + 1);
            end
            derivative = -1;
        end
        if(num_peaks >= 3)
            if(average_value < 2000 && average_value > -1000 && Gz_max - Gz_min > 2000 && Gz_max < 14000 && Gz_min > -14000)
                disp('Freezing');
                classification(1, pos_in_signal) = 2;
            elseif(Gz_max - Gz_min < 1500 && Gz_max < 5000 && Gz_min > -5000 || average_value < 0 || Gz_max - Gz_min > 20000)
                disp('Stopping or walking');
                classification(1, pos_in_signal) = 1;
            end
            disp(pos_in_signal);
            disp(average_value);
            disp(Gz_max - Gz_min);
            disp(Gz_max);
            disp(Gz_min);
            counter = 0;
            Gz_max = 0;
            Gz_min = 0;
            min_found = false;
            num_peaks = 0;
            average_value = 0;
        elseif(counter >= 40)
            disp('Either normal walking or stopping');
            classification(1, pos_in_signal) = 1;
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
        average_value = 0;
    end
    counter = counter + 1;
    pos_in_signal = pos_in_signal + 1;
end

% figure;
% subplot(3,1,1), plot(Ax);xlim([0 data_points]); xlabel('Time'); ylabel('X Acceleration Value');
% subplot(3,1,2), plot(Ay);xlim([0 data_points]); xlabel('Time'); ylabel('Y Acceleration Value');
% subplot(3,1,3), plot(Az);xlim([0 data_points]); xlabel('Time'); ylabel('Z Acceleration Value');

figure;
%subplot(3,1,1), plot(Gx);xlim([0 data_points]); xlabel('Time'); ylabel('X Angular Acceleration Value');
%subplot(3,1,2), plot(Gy);xlim([0 data_points]); xlabel('Time'); ylabel('Y Angular Acceleration Value');
%subplot(3,1,3), 
plot(Gz);xlim([0 data_points]); xlabel('Time'); ylabel('Z Angular Acceleration Value');
hold on;
for i = 1:500
    if(classification(1, i) == -1)
        plot(i, Gz(i), 'blackx', 'MarkerSize', 8);
    elseif(classification(1, i) == 0)
        plot(i, Gz(i), 'gx', 'MarkerSize', 12);
    elseif(classification(1, i) == 1)
        plot(i, Gz(i), 'gx', 'MarkerSize', 12);
    else
        plot(i, Gz(i), 'bx', 'MarkerSize', 20);
    end
end