clear all;
close all;
clc;
%%Initialization
name = ["Angus", "Jerry", "Manthan", "YanYan"];
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
        for x = 1:1000
            if(Gz(x) < 0)
                Gz(x) = 0;
            end
        end
        %plot graph
        figure1 = figure;
        figure(figure1);
        plot(Gz); xlabel('Time (data points)'); ylabel('Z Ang Acc (raw)'); 
        title(strcat(name(n), ' Gyroscope',{' '}, test(t),{' '},date));
        axis tight;
        hold on;
        for i = 1:3
            GyZ(i) = Gz(i);
            if(GyZ(i) < 0)
                GyZ(i) = 0;
            end
        end
        for i = 4:1000

            if(FoGCounter ~= 0)
                FoGCounter = FoGCounter + 1;
            end

            GyZ(1) = GyZ(2);
            GyZ(2) = GyZ(3);
            GyZ(3) = Gz(i);
            if(GyZ(3) < 0)
                GyZ(3) = 0;
            end
            if(GyZ(2) > 25000)
                numPeaks = 0;
                FoGCounter = 0;
                keep_on = false;
            elseif(isMax(GyZ) && isFoGZZero(GyZ(2)))
                numPeaks = numPeaks + 1;
                if(FoGCounter == 0)
                    FoGCounter = FoGCounter + 1;
                elseif(FoGCounter >= 151)
                    numPeaks = 0;
                    FoGCounter = 0;
                end
                if(numPeaks > 2 && ~keep_on)
                    plot(i, Gz(i), 'rx');
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
    boolean = (z > 2000 && z < 25000);
end