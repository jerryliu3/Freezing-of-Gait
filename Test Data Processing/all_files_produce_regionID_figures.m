close all;
clc;

% Filter for .mat files in directory
listing = dir;
is_datafile = @(filename) extractAfter(string(filename), '.')  ==  'mat';
dir_files = string(extractfield(listing, 'name'));
data_files = dir_files(is_datafile(dir_files));
fig_title = @(carray) carray(1:end-4);
results = zeros(length(data_files), 4);

interval = 50;
data_points = 500;
files_to_loop_through = length(data_files);
save_figs = false;
%string_title = "SOME_TITLE";

% Loop through .mat files
for file = 1:files_to_loop_through
    load(char(data_files(file))); 
    figure; plot(Gz); hold on;
    file_title = strcat('filename: ', data_files(file));
    title({'Z Ang Acc Region Classification (20pt interval)', file_title});
    y = get(gca,'YLim');   
    identifications = [0 0 0];
    % PUT ALGORITHM HERE
    for i = 0: (data_points/interval) - 1
        t_i = (interval)*i + 1;
        t_f = (interval)*(i + 1);
        to_read = Gz(1, t_i : t_f);
        Gz_max = max(to_read);
        Gz_min = min(to_read);
        diff = Gz_max - Gz_min;
        if(diff >= 20000)
            patch('XData',[t_i t_i t_f t_f],'YData', [y(1) y(2) y(2) y(1)],'FaceColor','blue','FaceAlpha',0.1);
            text(mean([t_i t_f]), y(1)+0.08*(y(2)-y(1)), 'N' ,'HorizontalAlignment','center')
        elseif(diff < 5000)
            patch('XData',[t_i t_i t_f t_f],'YData', [y(1) y(2) y(2) y(1)],'FaceColor','red','FaceAlpha',0.1);
            text(mean([t_i t_f]), y(1)+0.08*(y(2)-y(1)), 'S' ,'HorizontalAlignment','center')
        else
            patch('XData',[t_i t_i t_f t_f],'YData', [y(1) y(2) y(2) y(1)],'FaceColor','green','FaceAlpha',0.1)
            text(mean([t_i t_f]), y(1)+0.08*(y(2)-y(1)), 'F' ,'HorizontalAlignment','center')
        end
    end
    % END ALGORITHM
    if save_figs
        saveas(gcf,fig_title(char(data_files(file))),'png')
    end
end
data_files = transpose(data_files);


