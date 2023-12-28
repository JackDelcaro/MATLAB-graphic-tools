% Function: color_tints_and_shades(color, N, color_span)
% 
% Description:
%   Generates a cell array of N RGB triplets with different levels of
%   shades. The colors are centered around the input color and they are
%   ordered from lightest to darkest. You can change how much to spread
%   the tints of the output colors by using the parameter
%   color_span, 0 being all equal output colors and 1 being the
%   widest.
%
% Inputs:
%   - color: RGB input triplet (1x3 vector)
%   - N: Number of output colors
%   - color_span: Spread of the output colors, a value from 0 to
%     1 (1 being the widest possible span)
%
% Outputs:
%   - cmap: Cell array of N RGB triplets
%
% Example:
%   color = [0  0.4471  0.7412]; % Example RGB color
%   N = 10; % Number of output colors
%   color_span = 0.8; % Color span percentage
%   cmap = color_tints_and_shades(color, N, color_span);
%   figure; hold on;
%   for i = 1:length(cmap)
%     plot(rand(100,1) + i, 'Color', cmap{i});
%   end
%
% Author: Jack Delcaro
% Tested in MATLAB 2021a
% Last revision: 01/01/2024

function cmap = color_tints_and_shades(color, N, color_span)
    
    % Saturate color_span between 0 and 1
    if color_span > 1 || color_span < 0
        color_span = max(color_span, 0);
        color_span = min(color_span, 1);
        warning("Saturated parameter 'color_span' to " + num2str(color_span));
    end
    
    % Compute lightest and darkest colors
    lightest_color = [(1-color(1))*color_span+color(1), (1-color(2))*color_span+color(2), (1-color(3))*color_span+color(3)];
    darkest_color = [(1-color_span)*color(1), (1-color_span)*color(2), (1-color_span)*color(3)];
    
    % Initialize color table for interpolation
    interp_cmap = [lightest_color; color; darkest_color];
    interp_x = linspace(1, N, size(interp_cmap, 1));
    
    % Interpolate colormap and get all N colors
    xi = 1:N;
    color_matrix = zeros(N, 3);
    for ii = 1:3
        color_matrix(:, ii) = interp1(interp_x, interp_cmap(:, ii), xi);
    end
    
    % Convert the matrix to a cell array
    cmap = mat2cell(color_matrix, ones(size(color_matrix, 1), 1));

end