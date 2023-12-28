
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
T = tiledlayout(4, 4, 'TileSpacing', 'tight');

% histogram
nexttile(1, [2, 1]);
x = randn(1000,1);
y = randn(1000,1);
histogram2(x,y,'Normalization','probability');

% heatmap
nexttile(2, [2, 1]);
heatmap(magic(10));

% bode plot
t = tiledlayout(T, 2, 1, 'TileSpacing', 'tight');
t.Layout.Tile = 3;
t.Layout.TileSpan = [2 2];

s = tf('s');
G = 1/(s^2+0.25*s+1);
[mag, phase, ome] = bode(G);
mag = mag(1, :)';
phase = phase(1, :)';

t1 = nexttile(t); grid minor;
semilogx(ome/2/pi, 20*log10(mag));
ylabel('$\| G(j \omega) \|$ [dB]', 'FontSize', 15);

t2 = nexttile(t);
semilogx(ome/2/pi, phase);
ylabel('$\angle G(j \omega)$ [deg]', 'FontSize', 15);
xlabel('$freq$ [Hz]', 'FontSize', 15);

linkaxes([t1, t2], 'x');
xlim([min(ome), max(ome)]/2/pi);

t1.XTickLabel = '';

% boxchart
nexttile(T, 9, [2 1]);
boxchart([rand(10,4); 4*rand(1,4)],'BoxFaceColor',colors.blue{2},'MarkerColor',colors.blue{3}, 'MarkerStyle', 'o')

% simple plot
nexttile(10, [2 2]);
plot([0 1], [1 0]);

% polar histogram
nexttile(12, [2, 1]);
theta = atan2(rand(100000,1)-0.5,2*(rand(100000,1)-0.5));
polarhistogram(theta,25);