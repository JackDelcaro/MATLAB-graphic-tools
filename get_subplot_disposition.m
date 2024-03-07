% get_subplot_disposition - Compute the optimal disposition of subplots within a figure.
%
%   matrix = get_subplot_disposition(fig, debug)
%
%   This function takes a figure handle 'fig' and an optional 'debug' flag
%   to compute the current arrangement of subplots within the figure. It
%   returns a matrix 'matrix' representing the positions of each subplot in
%   the figure grid.
%
%   Parameters:
%   - fig: Figure handle. If not provided, the current figure (gcf) is used.
%   - debug: Optional flag for debugging mode. If true, the function plots
%     annotations on the figure to visualize the subplot arrangement.
%
%   Output:
%   - matrix: Matrix representing the subplot positions in the figure grid.
%     Each element corresponds to the index of the subplot in the original
%     order.
%
%   Example:
%   fig = figure;
%   subplot(2, 2, 1); plot(rand(100, 1));
%   subplot(3, 2, 2); plot(rand(100, 1));
%   subplot(3, 2, 4); plot(rand(100, 1));
%   subplot(2, 4, 5); plot(rand(100, 1));
%   subplot(3, 4, [10 11 12]); plot(rand(100, 1));
%   matrix = get_subplot_disposition(fig, true);
%
% Author: Jack Delcaro
% Tested in MATLAB 2021a
% Last revision: 01/01/2024

function matrix = get_subplot_disposition(fig, debug)
    
    % Check inputs
    if ~exist('fig', 'var')
        fig = gcf;
    end
    if ~exist('debug', 'var')
        debug = false;
    end
    
    drawnow;
    
    % We get all subplots
    all_axes = findall(fig, 'Type', 'axes');
    
    % If in debug mode we plot some annotations on top of the figure.
    % In particular, we plot the index of the subplot in the center of its axis
    if debug
        for i = 1:length(all_axes)
            annotation('textbox', 'Position', get_absolute_position(all_axes(i)), 'String', num2str(i), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'EdgeColor', 'none', 'FontSize', 30, 'Color', 'g');
        end
    end
    
    % We now write a matrix with all the positions of all axes. Each line
    % is in the form [left, bottom, right, top]
    axes_positions = nan(length(all_axes), 4);
    for i = 1:length(all_axes)
        axes_positions(i, :) = get_absolute_outerposition(all_axes(i));
    end
    axes_positions(:, 3) = axes_positions(:, 1) + axes_positions(:, 3);
    axes_positions(:, 4) = axes_positions(:, 2) + axes_positions(:, 4);
    
    % We smooth out numerical inconsistencies
    axes_positions = round(axes_positions/(max(axes_positions, [], 'all')/1000))*(max(axes_positions, [], 'all')/1000);
    
    % Get the axes outer limits
    min_left   = min(axes_positions(:, 1));
    max_right  = max(axes_positions(:, 3));
    min_bottom = min(axes_positions(:, 2));
    max_top    = max(axes_positions(:, 4));
    
    % Sort the axes by position
    [~, sorter_left]  = sortrows(axes_positions, 1);
    [~, sorter_right] = sortrows(axes_positions, -3);
    [~, sorter_bot]   = sortrows(axes_positions, 2);
    [~, sorter_top]   = sortrows(axes_positions, -4);
    
    % Main algorithm: for every axis, get the closest right, left, top and
    % bottom axes in order to get their position. We then compute the
    % maximum dimensions for the current axis by expanding it by half of
    % the empty space between it and its closest neighbors. The new
    % enlarged dimensions are contained in matrix box_positions.
    % col_divisors (row_divisors) are all the vertical (horizontal)
    % divisors in which the figure is splitted    
    col_divisors = [min_left; max_right];
    row_divisors = [min_bottom; max_top];
    box_positions = nan(size(axes_positions));    
    for i = 1:size(axes_positions, 1)
        
        % Indexes of the closest axes to the current one
        closest_to_right  = sorter_left(  find(axes_positions(sorter_left, 1)  > axes_positions(i, 3), 1, 'first') );
        closest_to_left   = sorter_right( find(axes_positions(sorter_right, 3) < axes_positions(i, 1), 1, 'first') );
        closest_to_bottom = sorter_top(   find(axes_positions(sorter_top, 4)   < axes_positions(i, 2), 1, 'first') );
        closest_to_top    = sorter_bot(   find(axes_positions(sorter_bot, 2)   > axes_positions(i, 4), 1, 'first') );
        
        % Compute enlarged box dimensions
        box_right  = (axes_positions(closest_to_right,  1) + axes_positions(i, 3) )/2;
        box_left   = (axes_positions(closest_to_left,   3) + axes_positions(i, 1) )/2;
        box_bottom = (axes_positions(closest_to_bottom, 4) + axes_positions(i, 2) )/2;
        box_top    = (axes_positions(closest_to_top,    2) + axes_positions(i, 4) )/2;
        
        % Saturate enlarged box dimensions
        if isempty(box_right) || box_right > max_right
            box_right = max_right;
        end
        if isempty(box_left) || box_left < min_left
            box_left = min_left;
        end
        if isempty(box_bottom) || box_bottom < min_bottom
            box_bottom = min_bottom;
        end
        if isempty(box_top) || box_top > max_top
            box_top = max_top;
        end        
        
        % We now know the dimensions of the enlarged box
        box_positions(i, :) = [box_left, box_bottom, box_right, box_top];
        
        % Expand col_divisors and row_divisors
        col_divisors = [col_divisors; box_right; box_left]; %#ok<AGROW>
        row_divisors = [row_divisors; box_bottom; box_top]; %#ok<AGROW>
        
        % If in debug mode, plot the enlarged boxes
        if debug
            annotation('rectangle', [box_left, box_bottom, box_right-box_left, box_top-box_bottom]);
        end
    end
    
    % Remove all duplicate divisors
    col_divisors = sort(uniquetol(col_divisors, 0.001));
    row_divisors = sort(uniquetol(row_divisors, 0.001));
    
    % We can now compute the width and height between two consecutive
    % divisors
    col_diff_divisor = diff(col_divisors)/(max(col_divisors) - min(col_divisors));
    row_diff_divisor = diff(row_divisors)/(max(row_divisors) - min(row_divisors));
    
    % Since col_diff_divisor and row_diff_divisor contain generic
    % fractions, we want to approximate them to simpler fractions of
    % an integer.
    [~, num_cols] = approximate_fractions(col_diff_divisor);
    [~, num_rows] = approximate_fractions(row_diff_divisor);
    
    % We can now compute the matrix which contains the information about
    % the position of all axes. To do so, we divide the figure space into
    % num_rows and num_cols and for each square we check which axis its
    % center belongs to.
    matrix = nan(num_rows, num_cols);
    for i = 1:num_rows
        y_center = max_top - (i-0.5)/num_rows*(max_top-min_bottom);
        for ii = 1:num_cols
            x_center = min_left + (ii-0.5)/num_cols*(max_right-min_left);
            
            % Determining the index of the containing box based on the center coordinates
            tmp = find(box_positions(:, 1) < x_center & box_positions(:, 3) > x_center & box_positions(:, 2) < y_center & box_positions(:, 4) > y_center, 1);
            if ~isempty(tmp)
                matrix(i, ii) = tmp;
            end
            
            % If in debug mode, draw the center and its (i, ii) coordinates
            if debug
                annotation('ellipse', 'Position', [x_center, y_center, 0.01, 0.01], 'Color', 'r', 'FaceColor', 'r');
                annotation('textbox', 'Position', [x_center, y_center, 0.1, 0.1], 'Color', 'r', 'String', "(" + num2str(i) +", " + num2str(ii) +")", 'FontSize', 20, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'EdgeColor', 'none');
            end
        end
    end

end

% function [out_num, out_den] = approximate_fractions(input_fractions)
% This function approximates the input fractions as fractions of integers.
% The output fractions have one common denominator. The input fractions
% must sum up to 1.
%
% inputs:
% - input_fractions: some input fractions which sum must be 1
%
% outputs:
% - out_num: numerators of the fractions
% - out_den: common denominator for all fractions
function [out_num, out_den] = approximate_fractions(in)

    N = length(in);
    
    % Allowed integers for denominator
    allowed_fractions_den = (N:50)';
    
    % The algorithm does as follows: it approximates the input fractions
    % using an integer denominator, then it computes the root-mean-square
    % error between the input fractions and the approximated ones. When the
    % rmse starts increasing we stop the algorithm.
    cost = nan(size(allowed_fractions_den));
    tested_solutions = nan(length(allowed_fractions_den), N);
    for i = 1:length(allowed_fractions_den)
        fractions = round(in*allowed_fractions_den(i))/allowed_fractions_den(i);
        cost(i) = sqrt(mean((fractions - in).^2));
        tested_solutions(i, :) = fractions';
        
        if i > 1 && cost(i) > cost(i-1)
            break;
        end
    end
    
    idx = find([diff(cost) > 0; false], 1, 'first');
    out_num = tested_solutions(idx,:)'*allowed_fractions_den(idx);
    out_den = allowed_fractions_den(idx);
end
