% Function: color_shades_saturation(color, N, color_span)
% 
% Description:
%   Generates a cell array of N RGB triplets with different levels of
%   saturation. The colors are centered around the input color and they are
%   ordered from most desaturated to darkest. You can change how much to spread
%   the saturation of the output colors by using the parameter
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
%   cmap = color_shades_saturation(color, N, color_span);
%   figure; hold on;
%   for i = 1:length(cmap)
%     plot(rand(100,1) + i, 'Color', cmap{i});
%   end
%
% Author: Jack Delcaro
% Tested in MATLAB 2021a
% Last revision: 01/01/2024

function cmap = color_shades_saturation(color, N, color_span)
    
    % Saturate color_span between 0 and 1
    if color_span > 1 || color_span < 0
        color_span = max(color_span, 0);
        color_span = min(color_span, 1);
        warning("Saturated parameter 'color_span' to " + num2str(color_span));
    end

    % Determine the number of lighter and darker colors based on N
    if mod(N, 2) == 0 % even number
        lighter_colors_number = N/2;
        darker_colors_number = N/2 - 1;
    else % odd number
        lighter_colors_number = floor(N/2);
        darker_colors_number = floor(N/2);
    end
    
    % Initialize an empty matrix to store RGB triplets
    color_matrix = nan(N, 3);
    
    % Convert input RGB color to HSV format for easier manipulation
    hsv_color = rgb2hsv(color);
    
    % Calculate multipliers for adjusting saturation levels
    light_color_multiplier = (1-color_span);
    dark_color_multiplier = (1-color_span);
    
    % Generate lighter colors
    for i = 1:lighter_colors_number
        tmp = hsv_color;
        tmp(2) = ((1 - light_color_multiplier)/lighter_colors_number*(i - 1) + light_color_multiplier)*hsv_color(2);
        color_matrix(i, :) = hsv2rgb(tmp);
    end
    
    % Set the center color (unchanged)
    color_matrix(lighter_colors_number+1, :) = color;
    
    % Generate darker colors
    for i = 1:darker_colors_number
        tmp = hsv_color;
        tmp(3) = ((1 - dark_color_multiplier)/darker_colors_number*(i - 1) + dark_color_multiplier)*hsv_color(3);
        color_matrix(N-i+1, :) = hsv2rgb(tmp);
    end

    % Convert the matrix to a cell array
    cmap = mat2cell(color_matrix, ones(size(color_matrix, 1), 1));

end