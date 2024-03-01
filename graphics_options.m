
%% DEFINE COLORS

% Matlab colors defined in a convient struct named 'colors'
colors.matlab = hex2rgb({'#0072BD'; '#D95319'; '#EDB120'; '#7E2F8E'; '#77AC30'; '#4DBEEE'; '#A2142F'});
colors.matlab = [colors.matlab; colors.matlab; colors.matlab];
colors.axes = [0.15 0.15 0.15];
colors.grey = {[1 1 1]*0.85; [1 1 1]*0.7; [1 1 1]*0.55; [1 1 1]*0.4; [1 1 1]*0.25; [1 1 1]*0.1};
colors.white = [1 1 1];
colors.black = [0 0 0];
colors.blue = color_tints_and_shades(colors.matlab{1}, 3, 0.5);
colors.orange = color_tints_and_shades(colors.matlab{2}, 3, 0.5);
colors.yellow = color_tints_and_shades(colors.matlab{3}, 3, 0.5);
colors.purple = color_tints_and_shades([0.5021    0.3122    0.6318], 3, 0.5);
colors.green = color_tints_and_shades(colors.matlab{5}, 3, 0.5);
colors.red = color_tints_and_shades([0.7466    0.1371    0.2981], 3, 0.5);

% Other useful colors
colors.crayon = color_spacer(5);
colors.crayon = [colors.crayon; colors.crayon; colors.crayon];

%% DEFAULT GRAPHIC SETTINGS

set(groot,'defaultAxesFontSize',21);                    % Font size for axes
set(groot,'defaultTextFontSize',21);                    % Font size for text
set(groot,'defaultAxesFontName','latex');               % Font name for axes
set(groot,'defaultTextFontName','latex');               % Font name for text
set(groot,'DefaultAxesBox','on');                       % Enable box in graphics
set(groot,'DefaultAxesXGrid','on');                     % Enable grid in graphics
set(groot,'DefaultAxesYGrid','on');                     % Enable grid in graphics
set(groot,'DefaultLineLinewidth',2);                    % Line width for plots
set(groot, 'DefaultStairLineWidth', 2);                 % Line width for stairs

set(0,'DefaultFigureWindowStyle','docked');             % Set figures to docked

set(0, 'defaultAxesTickLabelInterpreter','latex');      % Axes tick label
set(0, 'defaultLegendInterpreter','latex');             % Legend
set(0, 'defaultTextInterpreter','latex');               % Miscellaneous strings
set(0, 'defaultColorBarTickLabelInterpreter', 'latex'); % Color bar ticks
