% function color_spacer(N)
%
% Syntax:
%   cmap = color_spacer(N)
%
% Description:
%   This function generates a cell array of N colors that are equally spaced
%   across the color spectrum. It uses a predefined color spectrum and
%   interpolates between the colors to create a colormap of desired length.
%   The output colors are ordered as follows: purple, blue, green, yellow,
%   orange, red.
%
% Input:
%   - N: Number of colors to generate in the colormap.
%
% Output:
%   - cmap: Cell array containing RGB triplets of the generated colors.
%
% Example:
%   % Generate a colormap of 10 equally spaced colors
%   cmap = color_spacer(10);
%   figure; hold on;
%   for i = 1:length(cmap)
%     plot(rand(100,1) + i, 'Color', cmap{i});
%   end
%
% Author: Jack Delcaro
% Tested in MATLAB 2021a
% Last revision: 01/01/2024

function cmap = color_spacer(N)
    
    % Color spectrum definition
    spectrum_cmapp = [178, 22, 73;
             213, 62, 79;
             244, 109, 67;
             253, 174, 97;
             238, 223, 153;
             171, 221, 164;
             102, 194, 165;
             50, 136, 189;
             94, 79, 162]/255;
    spectrum_x = linspace(1, N, size(spectrum_cmapp,1));
    
    % Initialize an empty matrix to store RGB triplets
    cmap = zeros(N,3);
    
    % Interpolate the spectrum to get N colors
    xi = 1:N;
    for ii = 1:3
        cmap(:, ii) = pchip(spectrum_x, spectrum_cmapp(:,ii), xi);
    end
    % Flip the colormap vertically
    cmap = flipud(cmap);
    
    % Convert the matrix to a cell array
    cmap = mat2cell(cmap, ones(size(cmap, 1), 1));

end