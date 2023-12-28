
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

%% ELABORATE DATA

x = (0:1:360)';
y = sin(x*pi/180);

%% PLOT

N_plots = 15;

% this function creates a cell array of N_plots colors, equally spaced
% across the RGB color spectrum
my_colors = color_spacer(N_plots);

% this function starts from a given color and outputs a spectrum of N_plots
% centered around the central color
my_colors_2 = color_tints_and_shades(colors.matlab{1}, N_plots, 0.8);

figure;
tiledlayout(4, 1, 'TileSpacing', 'tight');
% tiledlayout is better than subplot

%% TILE 1: rainbow lines

% Example of simple plot with legend
t(1) = nexttile; hold on; grid minor;

% Plot N_plot lines
for i = 1:N_plots
    plot(x, y + i*0.1, 'Color', my_colors{i}, 'DisplayName', num2str(i));
end

% Create legend with multiple columns
legend('NumColumns', 3, 'FontSize', 15);

% Label y-axis using latex interpreter
ylabel('$pressure$ [bar]');

%% TILE 2: scatter plot

t(2) = nexttile; hold on; grid minor;

% Plot N_plots scatter
for i = 1:N_plots
    % If you want a nicer scatter plot, you can fill the markers with a
    % lighter color wrt the marker's edge
    light_color = lighten_color(my_colors{i}, 0.5);
    scatter(x(i:10:end), y(i:10:end) + i*0.1, 'filled', 'MarkerFaceColor', light_color, 'MarkerEdgeColor', my_colors{i}, 'LineWidth', 1.5, 'HandleVisibility', 'off');
end

% Label y-axis using latex interpreter
ylabel('$\alpha$ [deg]');

%% TILE 3: scatter plot with colorbar

t(3) = nexttile; hold on; grid minor;

scatter(x, y, [], sin(x*pi/180-pi/2), 'filled', 'HandleVisibility', 'off');
scatter(x, y + 1, [], sin(x*pi/180-pi/2), 'filled', 'HandleVisibility', 'off');
scatter(x, y + 0.5 + 0.5*sin(x*pi/180*10), [], sin(x*pi/180-pi/2), 'filled', 'HandleVisibility', 'off');

% Use custom colormap, equally spaced in the RGB color spectrum
colormap(t(3), cell2mat(color_spacer(256)));

% Draw colorbar
colorbar;

% Label y-axis using latex interpreter
ylabel('$\|\dot{\Phi}\|$ [rad/s]');

%% TILE 4: lines and patches

t(4) = nexttile; hold on; grid minor;

% Plot background grey patches
patch_abscissas = (1:30:360)';
patch_ordinates = [-0.5; 3];
patch([patch_abscissas(1:2:end)'; patch_abscissas(1:2:end)'; patch_abscissas(2:2:end)'; patch_abscissas(2:2:end)'],...
      repmat([patch_ordinates; flip(patch_ordinates)], 1, length(patch_abscissas(1:2:end))),...
      colors.grey{2}, 'FaceAlpha', 0.25, 'EdgeColor', 'none', 'HandleVisibility', 'off');

% Plot lines of varying shades of blue
for i = 1:N_plots
    plot(x, cumsum(sign(y))/180 + i*0.1, 'Color', my_colors_2{i}, 'HandleVisibility', 'off');
end

% Label y-axis using latex interpreter
ylabel('$\overline{x}_{abc}$ [mm]');

% Label x-axis using latex interpreter
xlabel('$\theta$ [deg]');

% Link all horizontal axes and limit them
linkaxes(t, 'x');
xlim([min(x); max(x)]);

% Here I remove the labels on the x axes of every plot except for the last
% one. These commands work better if applied after the entire figure has
% been plotted
for i = 1:length(t)-1
    nexttile(i);
    xticklabels('');
end
    
    
    