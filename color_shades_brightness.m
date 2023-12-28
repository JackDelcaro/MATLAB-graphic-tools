% Function: color_shades_brightness(color, N, color_span)
% 
% Description:
%   Generates a cell array of N RGB triplets with different levels of
%   brightness. The colors are centered around the input color and they are
%   ordered from brightest to darkest. You can change how much to spread
%   the brightness of the output colors by using the parameter
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
%   cmap = color_shades_brightness(color, N, color_span);
%   figure; hold on;
%   for i = 1:length(cmap)
%     plot(rand(100,1) + i, 'Color', cmap{i});
%   end
%
% Author: Jack Delcaro
% Tested in MATLAB 2021a
% Last revision: 01/01/2024

function cmap = color_shades_brightness(color, N, color_span)
    
    % Saturate color_span between 0 and 1
    if color_span > 1 || color_span < 0
        color_span = max(color_span, 0);
        color_span = min(color_span, 1);
        warning("Saturated parameter 'color_span' to " + num2str(color_span));
    end

    % Generate beta values for adjusting brightness
    beta_values = linspace(-color_span, color_span, N);

    % Initialize a matrix to store RGB values
    color_matrix = nan(N, 3);
    
    % Iterate over N and adjust brightness for each color
    for i = 1:N
        color_matrix(N-i+1, :) = brighten(color, beta_values(i));
    end

    % Convert the matrix to a cell array
    cmap = mat2cell(color_matrix, ones(size(color_matrix, 1), 1));

end