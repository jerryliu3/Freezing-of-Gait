clear all;
close all;
clc;
%%Initialization
name = 'Angus';
test = 'FoG';
date = '112917';
data_points = 1000;
load(strcat(name, test,date, '.mat'));
GyZ = [0 0 0];
FoGCounter = 0;
numPeaks = 0;

%plot graph
figure;
plot(Gz); xlabel('Time (data points)'); ylabel('Z Ang Acc (raw)'); 
title(strcat(name, ' Gyroscope', test,{' '},date));
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
    if(isMax(GyZ) && GyZ(2) > 20000)
        numPeaks = 0;
        FoGCounter = 0;
        
    elseif(isMax(GyZ) && isFoGZZero(GyZ(2)))
        numPeaks = numPeaks + 1;
        if(FoGCounter == 0)
            FoGCounter = FoGCounter + 1;
        elseif(FoGCounter >= 151)
            numPeaks = 0;
            FoGCounter = 0;
        end
        if(numPeaks > 2)
            plot(i, Gz(i), 'rx');
            numPeaks = 0;
            FoGCounter = 0;
        end
    end
end

%saveas(figure2, strcat(name, '_Gyroscope', '_',location, '_', test,'_',date, '.png'));

function boolean = isMax(GyZ)
    boolean = (GyZ(2) > GyZ(1) && GyZ(2) > GyZ(3));
end

function boolean = isFoGZZero(z)
    boolean = (z > 2000 && z < 20000);
end