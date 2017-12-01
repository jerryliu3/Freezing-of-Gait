clear all;
close all;
clc;
%%Initialization
%"Angus", "Jerry", "Manthan", 
name = ["YanYan", "Jerry", "Angus"];

average_delay = [];
average_peak = [];
last_FoG_start = 0;
for n = 1:4
    for t = 1:3
        test = ["Stopping", "FoG", "Full"];
        date = '112917';
        keep_on = false;
        data_points = 1000;
        load(strcat(name(n), test(t),date, '.mat'));
        GyZ = [0 0 0];
        FoGCounter = 0;
        numPeaks = 0;
        new_section = true;
        zero_counter = 0;
        delay = 0;
        for x = 1:data_points
            if(Gz(x) < 0)
                Gz(x) = 0;
            end
            if(Gx(x) < 0)
                Gx(x) = 0;
            end
        end
        Gxz = Gx.*Gz;
        %plot graph
        figure1 = figure;
        figure(figure1);
        plot(Gxz); xlabel('Time (data points)'); ylabel('XZ Ang Acc (transformed)'); 
        title(strcat(name(n), ' Gyroscope',{' '}, test(t),{' '},date));
        axis tight;
        hold on;
        for i = 1:3
            GyZ(i) = Gxz(i);
            if(GyZ(i) < 0)
                GyZ(i) = 0;
            end
        end
        for i = 4:data_points

            if(FoGCounter ~= 0)
                FoGCounter = FoGCounter + 1;
            end

            GyZ(1) = GyZ(2);
            GyZ(2) = GyZ(3);
            GyZ(3) = Gxz(i);
            delay = delay + 1;
            if(GyZ(3) < 0)
                GyZ(3) = 0;
            end
            if(zero_counter > 35)
                numPeaks = 0;
                zero_counter = 0;
            end
            if(GyZ(2) == 0 && GyZ(3) == 0)
                new_section = true;
                delay = 0;
            end
            if(GyZ(3) < 50000)
                zero_counter = zero_counter + 1;
            else
                zero_counter = 0;
            end
            if(GyZ(2) > 150000000)
                numPeaks = 0;
                FoGCounter = 0;
                keep_on = false;
                new_section = false;
            elseif(new_section && isMax(GyZ) && isFoGZZero(GyZ(2)))
                new_section = false;
                numPeaks = numPeaks + 1;
                if(numPeaks ==1)
                    last_FoG_start = i - delay;
                end
                if(FoGCounter == 0)
                    FoGCounter = FoGCounter + 1;
                elseif(FoGCounter >= 133)
                    numPeaks = 0;
                    FoGCounter = 0;
                    zero_counter = 0;
                end
                if(numPeaks > 1 && ~keep_on)
                    plot(i, Gxz(i), 'rx');
                    average_delay = [average_delay i-last_FoG_start];
                    average_peak = [average_peak GyZ(2)];
                    keep_on = true;
                    numPeaks = 0;
                    FoGCounter = 0;
                end
            end
        end
        hold off;
        c1 = cellstr(name);
        c2 = cell2mat(c1(n));
        c3 = cellstr(test);
        c4 = cell2mat(c3(t));
        saveas(figure1, strcat(c2, c4, 'AlgPlot', date, '.png'));
    end
end

function boolean = isMax(GyZ)
    boolean = (GyZ(2) - GyZ(1) > 500 && GyZ(2) - GyZ(3) > 500);
end

function boolean = isFoGZZero(z)
    boolean = (z > 1000000 && z < 20000000);
    %boolean = (z > 2000000 && z < 30000000);
end