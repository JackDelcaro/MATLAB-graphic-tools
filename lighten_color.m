% Function: lighten_color(color, color_span)
%
% Description:
%   Lightens an RGB color by a specified amount, producing a new color.
%
% Syntax:
%   out = lighten_color(color, color_span)
%
% Inputs:
%   - color: RGB input triplet representing the original color.
%   - color_span: Scalar value between 0 and 1 indicating the degree of
%                 lightening to be applied (0 for no change, 1 for maximum
%                 lightening).
%
% Output:
%   - out: RGB triplet representing the lightened color.
%
% Example:
%   color = [0  0.4471  0.7412]; % RGB triplet
%   lightened_color = lighten_color(color, 0.5);
%   figure; hold on;
%   plot(rand(100,1), 'Color', color);
%   plot(rand(100,1)+1, 'Color', lightened_color);
%
% Author: Jack Delcaro
% Tested in MATLAB 2021a
% Last revision: 01/01/2024

function out = lighten_color(color, color_span)
    
    tmp = color_tints_and_shades(color, 3, color_span);
    out = tmp{1};

end