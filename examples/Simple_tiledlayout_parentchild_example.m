
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

%% PLOTS

figure;
parentT = tiledlayout(4, 2, 'TileSpacing', 'loose');

% bode plot
s = tf('s');
G = 1/(s^2+0.25*s+1);
[mag, phase, ome] = bode(G);
mag = mag(1, :)';
phase = phase(1, :)';

% Generate children tiledlayout
childT = tiledlayout(parentT, 2, 1, 'TileSpacing', 'tight');
childT.Layout.Tile = 2; % specify children tile position
childT.Layout.TileSpan = [3, 1]; % specify how many rows and columns of the parent tile you want to occupy with the children tile

t1 = nexttile(childT, 1, [1, 1]); grid minor;
semilogx(ome/2/pi, 20*log10(mag));
ylabel('$\| G(j \omega) \|$ [dB]', 'FontSize', 15);

t2 = nexttile(childT, 2, [1, 1]);
semilogx(ome/2/pi, phase);
ylabel('$\angle G(j \omega)$ [deg]', 'FontSize', 15);
xlabel('$freq$ [Hz]', 'FontSize', 15);

linkaxes([t1, t2], 'x');
xlim([min(ome), max(ome)]/2/pi);
t1.XTickLabels = '';

% Generate children tiledlayout
child2T = tiledlayout(parentT, 2, 1, 'TileSpacing', 'tight');
child2T.Layout.Tile = 3; % specify children tile position
child2T.Layout.TileSpan = [3, 1]; % specify how many rows and columns of the parent tile you want to occupy with the children tile

t1 = nexttile(child2T, 1, [1, 1]); grid minor;
semilogx(ome/2/pi, 20*log10(mag));
ylabel('$\| G(j \omega) \|$ [dB]', 'FontSize', 15);

t2 = nexttile(child2T, 2, [1, 1]);
semilogx(ome/2/pi, phase);
ylabel('$\angle G(j \omega)$ [deg]', 'FontSize', 15);
xlabel('$freq$ [Hz]', 'FontSize', 15);

linkaxes([t1, t2], 'x');
xlim([min(ome), max(ome)]/2/pi);
t1.XTickLabels = '';
