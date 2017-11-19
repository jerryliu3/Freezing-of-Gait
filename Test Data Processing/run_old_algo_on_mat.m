close all;
clc;
% Filter for .mat files in directory
listing = dir;
is_datafile = @(filename) extractAfter(string(filename), '.')  ==  'mat';
dir_files = string(extractfield(listing, 'name'));
data_files = dir_files(is_datafile(dir_files));
results = zeros(length(data_files), 4);

% Input interval
data_points = 500;
interval = 20;

% Loop through .mat files
for file = 1:length(data_files)
    load(char(data_files(file)));    
    identifications = [0 0 0];
    % Run algorithm
    for i = 0: (data_points/interval) - 1
        t_i = interval*i + 1;
        t_f = interval*(i + 1);
        to_read = Gz(1, t_i : t_f);
        Gz_max = max(to_read);
        Gz_min = min(to_read);
        diff = Gz_max - Gz_min;
        if(diff >= 20000)
            identifications(1) = identifications(1)+ 1;
        elseif(diff < 5000)
            identifications(2) = identifications(2) + 1;
        else
            identifications(3) = identifications(3) + 1;
        end
    end
    % End Algorithm
    % Record Algorithm's Results
    steps = identifications(1);
    stops = identifications(2);
    fogs  = identifications(3);
    %strcat(listing(file).name, ':', sprintf(' Steps: %d Stops: %d FoGs: %d', steps, stops, fogs))
    % Store result into matrix
    results(file,:) = [file, steps, stops, fogs];
end
results
data_files = transpose(data_files);


