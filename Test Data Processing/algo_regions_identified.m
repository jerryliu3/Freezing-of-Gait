Filter for .mat files in directory
listing = dir;
is_datafile = @(filename) extractAfter(string(filename), '.')  ==  'mat';
dir_files = string(extractfield(listing, 'name'));
data_files = dir_files(is_datafile(dir_files));
results = zeros(length(data_files), 4);

data_points = 500;
interval = 20;


plot(Gz); hold on;
y = get(gca,'YLim');

for i = 0: (data_points/interval) - 1
        t_i = (interval)*i + 1;
        t_f = (interval)*(i + 1);
        to_read = Gz(1, t_i : t_f);
        Gz_max = max(to_read);
        Gz_min = min(to_read);
        diff = Gz_max - Gz_min;
        if(diff >= 20000)
            patch('XData',[t_i t_i t_f t_f],'YData', [y(1) y(2) y(2) y(1)],'FaceColor','blue','FaceAlpha',0.1);
        elseif(diff < 5000)
            patch('XData',[t_i t_i t_f t_f],'YData', [y(1) y(2) y(2) y(1)],'FaceColor','red','FaceAlpha',0.1);
        else
            patch('XData',[t_i t_i t_f t_f],'YData', [y(1) y(2) y(2) y(1)],'FaceColor','green','FaceAlpha',0.1)
        end
end
    
