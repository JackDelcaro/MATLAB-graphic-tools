
clc
close all
clearvars

%% ADDPATHS

paths.file_folder_path = string(matlab.desktop.editor.getActiveFilename);
paths.file_folder_path = fileparts(paths.file_folder_path);
[paths.file_plotutilities_path, ~, ~] = fileparts(paths.file_folder_path);
addpath(genpath(paths.file_plotutilities_path));

%% SETTINGS

run('graphics_options.m');

%% EXAMPLES


figure;
tiledlayout(1, 2, 'TileSpacing', 'compact');

nexttile; hold on;
title('RGB color spectrum');
% color_spacer is used to get colors in a spectrum (from blue to red)
my_colors = color_spacer(21);
for i = 1:length(my_colors)
    plot([0 1], [0 1]+i-0.5, 'color', my_colors{i}, 'LineWidth', 3);
end
ylim([0.4 length(my_colors)+0.6]);
xticklabels('');

nexttile; hold on;
title('MATLAB colors');
for i = 1:length(colors.matlab)
    plot([0 1], [0 1]+i-0.5, 'color', colors.matlab{i}, 'LineWidth', 3);
end
ylim([0.4 length(my_colors)+0.6]);
xticklabels('');

figure;
tiledlayout(1, 3, 'TileSpacing', 'compact');

nexttile; hold on;
title('Various shades of blue');
my_colors = color_tints_and_shades(colors.matlab{1}, 10, 0.5);
for i = 1:length(my_colors)
    plot(sin((0:99)/99*2*pi*2)*0.5+i, 'color', my_colors{i}, 'LineWidth', 3);
end
ylim([0.4 length(my_colors)+0.6]);
xticklabels('');

nexttile; hold on;
title('Varying blue brightness');
my_colors = color_shades_brightness(colors.matlab{1}, 10, 0.5);
for i = 1:length(my_colors)
    plot(sin((0:99)/99*2*pi*2)*0.5+i, 'color', my_colors{i}, 'LineWidth', 3);
end
ylim([0.4 length(my_colors)+0.6]);
xticklabels('');

nexttile; hold on;
title('Varying blue saturation');
my_colors = color_shades_saturation(colors.matlab{1}, 10, 0.5);
for i = 1:length(my_colors)
    plot(sin((0:99)/99*2*pi*2)*0.5+i, 'color', my_colors{i}, 'LineWidth', 3);
end
ylim([0.4 length(my_colors)+0.6]);
xticklabels('');

figure; hold on;
title('Ready-to-use colors: 3 shades of red');
% For each color there are 3 shades already available
for i = 1:length(colors.red)
    plot([0 1], [0 1]+i, 'color', colors.red{i}, 'LineWidth', 3);
end
xticklabels('');