% Function: darken_color(color, color_span)
%
% Description:
%   Darkens an RGB color by a specified amount, producing a new color.
%
% Syntax:
%   out = darken_color(color, color_span)
%
% Inputs:
%   - color: RGB input triplet representing the original color.
%   - color_span: Scalar value between 0 and 1 indicating the degree of
%                 darkening to be applied (0 for no change, 1 for maximum
%                 darkening).
%
% Output:
%   - out: RGB triplet representing the darkened color.
%
% Example:
%   color = [0  0.4471  0.7412]; % RGB triplet
%   darkened_color = darken_color(color, 0.5);
%   figure; hold on;
%   plot(rand(100,1), 'Color', color);
%   plot(rand(100,1)+1, 'Color', darkened_color);
%
% Author: Jack Delcaro
% Tested in MATLAB 2021a
% Last revision: 01/01/2024

function out = darken_color(color, color_span)
    
    tmp = color_tints_and_shades(color, 3, color_span);
    out = tmp{3};

end