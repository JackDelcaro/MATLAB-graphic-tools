
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

figure;

% tiledlayout is better than subplot
tiledlayout(3, 1, 'TileSpacing', 'tight');

%% FIRST TILE

% Example of plot, scatter and patch with legend
t(1) = nexttile; hold on; grid minor;

% this function creates a cell array of N_lines colors, equally spaced
% across the RGB color spectrum
N_lines = 15;
my_colors = color_spacer(N_lines);

patch_stop_index = 105; % the rainbow batch will stop at this index
line_stop_index = 225; % lines will stop at this index

% Compute the data for the rainbow patch
X_data_patch = [ones(N_lines-1, 1)*x(1); x(1:patch_stop_index); (x(patch_stop_index+1):1:x(N_lines+patch_stop_index-2))'; flip(x(2:N_lines+patch_stop_index-1))];
Y_data_patch = [linspace(y(1)+0.1*(N_lines-0.5),y(1)-0.05,N_lines)'; y(2:patch_stop_index-1)-0.05; linspace(y(patch_stop_index)-0.05,y(N_lines+patch_stop_index-1)+0.1*(N_lines-0.5),N_lines)'; flip(y(2:N_lines+patch_stop_index-2)+0.1*(N_lines-0.5))];
C_data_patch = [linspace(1,0,N_lines)'; ones(size(x(2:patch_stop_index-1)))*0; linspace(0,1,N_lines)'; ones(size(x(2:N_lines+patch_stop_index-2)))*1];
patch(X_data_patch, Y_data_patch, C_data_patch,...
      'LineStyle', 'none', 'FaceAlpha', 0.7, 'HandleVisibility', 'off');

% Use custom colormap, equally spaced in the RGB color spectrum
colormap(t(1), cell2mat(color_spacer(N_lines)));  

% To better understand what each term stands for, you can uncomment and run
% the following line:
% figure; scatter3(X_data_patch, Y_data_patch, C_data_patch, [], C_data_patch, 'filled'); xlabel('$x$'); ylabel('$y$'); zlabel('$c$'); colorbar; colormap(gcf, cell2mat(color_spacer(N_lines))); 

% Plot N_lines lines and scatters
for i = 1:N_lines

    % A mask is used to plot only a portion of the data
    mask = false(size(x));
    i_line_start_index = patch_stop_index + ceil((i-0.5)/(N_lines)*(N_lines-1));
    i_line_stop_index = line_stop_index + i - floor((i-1)/(N_lines/2)).*ceil(rem((i-1),(N_lines/2)))*2;
    mask(i_line_start_index:i_line_stop_index) = true;
    
    % x_init is the exact point in which the rainbow patch ends and the
    % line starts
    x_init = interp1(1:length(x), x, patch_stop_index + (i-0.5)/(N_lines)*(N_lines-1));
    y_init = sin(x_init*pi/180);
    
    % plot the line
    plot([x_init; x(mask)], [y_init + (i-1)*0.1; y(mask) + (i-1)*0.1], 'Color', my_colors{i}, 'DisplayName', num2str(i));
    
    % after the lines we use scatter
    light_color = lighten_color(my_colors{i}, 0.5); % this is a ligher version of color my_colors{i}
    scatter([x_init; x(i_line_stop_index:8:end)], [y_init + (i-1)*0.1; y(i_line_stop_index:8:end) + (i-1)*0.1],...
            'filled', 'MarkerFaceColor', light_color, 'MarkerEdgeColor', my_colors{i}, 'LineWidth', 1.25, 'HandleVisibility', 'off');
end

% Create legend with multiple columns
legend('NumColumns', 5, 'FontSize', 15);

% Label y-axis using latex interpreter
ylabel('$\bar{\Theta}$ [bar]');

%% SECOND TILE

t(2) = nexttile; hold on; grid minor;

% Use custom colormap, equally spaced in the RGB color spectrum
colormap(t(2), cell2mat(color_spacer(256)));

% Draw a rainbow patch with RGB colors
patch([x; flip(x)], [y-0.1; flip(y+1.1)], [cumsum(sign(y))/90-1; flip(sin(x*pi/180-pi/2))],...
      'EdgeColor','interp', 'LineWidth', 2,'FaceAlpha', 0.5);

% Scatter points on top of the rainbow
scatter(x, y + 0.5 + 0.5*sin(x*pi/180*10), [], round(sin(x*pi/180)*5)/5, 'filled', 'HandleVisibility', 'off');

% Draw colorbar and remove its labels
tmp = colorbar;
tmp.TickLabels = '';

% Label y-axis using latex interpreter
ylabel('$\alpha$ [deg]');

%% THIRD TILE

t(3) = nexttile; hold on; grid minor;

% Use custom colormap, equally spaced in the RGB color spectrum. In this
% case we are using only 10 colors in the map, so the result will have more
% evident color patches
colormap(t(3), cell2mat(color_spacer(10)));

% Draw a rainbow patch with RGB colors
patch([x; flip(x)], [y-0.1; flip(y+1.1)], [cumsum(sign(y))/90-1; flip(sin(x*pi/180-pi/2))],...
      'EdgeColor','interp', 'LineWidth', 2,'FaceAlpha', 0.5);

% Scatter points on top of the rainbow
scatter(x, y + 0.5 + 0.5*sin(x*pi/180*10), [], sin(x*pi/180), 'filled', 'HandleVisibility', 'off');

% Draw colorbar
colorbar;

% Label y-axis using latex interpreter
ylabel('$\|\dot{\Phi}\|$ [rad/s]');

% Label x-axis using latex interpreter
xlabel('$\theta$ [deg]');

% Link all horizontal axes and limit them
linkaxes(t, 'x');
xlim([min(x); max(x)]);

% Remove the labels on the x axes of every plot except for the last one
% (to reduce the space between subplots)
for i = 1:length(t)-1
    nexttile(i);
    xticklabels('');
end
    
    