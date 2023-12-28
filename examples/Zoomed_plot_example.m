
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

%% DATA

x = (0:0.1:99)';
y1 = (sin(x/99*2*pi*20       )*0.05+1-exp(-x/30)+randn(length(x), 1)*0.002)*100;
y2 = (sin(x/99*2*pi*20+2*pi/3)*0.05+1-exp(-x/30)+randn(length(x), 1)*0.002)*100;
y3 = (sin(x/99*2*pi*20-2*pi/3)*0.05+1-exp(-x/30)+randn(length(x), 1)*0.002)*100;

%% INTERACTIVE PLOT

figure; hold on;
plot(rand(1,100)*0.05+1-exp(-(0:99)/75));
title('Interact with the objects');
zoom_plot();

%% PROGRAMMED PLOT

figure;

t = tiledlayout(1,2,'TileSpacing', 'compact');

nexttile; hold on;
plot(x, y1, 'Color', colors.blue{1});
plot(x, y2, 'Color', colors.blue{2});
plot(x, y3, 'Color', colors.blue{3});
xlabel('$time$ [s]');
ylabel('$data$ [-]');
ylim([0 100]);

nexttile; hold on;
plot(y1, x, 'Color', colors.green{1});
plot(y2, x, 'Color', colors.green{2});
plot(y3, x, 'Color', colors.green{3});
xlabel('$time$ [s]');
ylabel('$data$ [-]');
xlim([0 100]);

sgtitle('Zoom examples', 'FontSize', 21);

nexttile(t, 1)
[~, ~, rect_handle, ~] = zoom_plot('zoom_axis_position', [0.3859    0.0716    0.5558    0.5165], 'rectangle_position', [26.1554   60.8948   13.4261   10.6784], 'rectangle_linewidth', 1.5);
rect_handle.FaceColor = colors.grey{1};
rect_handle.FaceAlpha = 0.5;
nexttile(t, 2)
[~, ~, rect_handle, ~] = zoom_plot('zoom_axis_position', [0.1090    0.4671    0.5380    0.4692], 'rectangle_position', [55.7042   25.7335   16.3581   12.8695], 'rectangle_linewidth', 1.5);
rect_handle.FaceColor = colors.grey{1};
rect_handle.FaceAlpha = 0.5;