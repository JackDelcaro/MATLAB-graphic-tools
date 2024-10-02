% plot_patches: Function to draw colored rectangle patches underneath existing
%               plots in each axis.
% 
% Syntax:
%   tiles = plot_patches(time, enable, tiles, patch_properties)
%
% Input Arguments:
%   - time: Time vector corresponding to the data.
%   - enable: Vector indicating when to draw patches (logical).
%   - tiles: Existing axes where the patches will be plotted (array of axes handles).
%   - patch_properties (optional): Properties for the rectangle patch to be drawn (cell array).
%
% Output:
%   - tiles: Updated axes with patches drawn below the plots.
%
% Notes:
%   - This function assumes that patches are to be drawn below existing plots
%     in each axis specified by tiles.
%   - It is expected that the data has already been plotted into tiles before
%     calling this function.
%   - The enable vector indicates when patches should be drawn. A patch is
%     drawn whenever the enable vector is true.
%
% Example:
%   time = (0:0.01:10)';
%   val1 = sin(2*pi*time/max(time)) + rand(length(time), 1)*0.1;
%   val2 = cos(2*pi*time/max(time)) + rand(length(time), 1)*0.1;
%   tiles = plot_data(time, val1, [], val2, val1, val2, 'line_properties', {'LineWidth', 2, 'DisplayName', 'meas'}, 'yaxis_labels', {'$y_1$', '$y_2$', 'cos'}, 'xaxis_labels', {'', '$x_2$', 'sin'}, 'tile_disposition', [1 1 3; 2 2 3]);
%   val1 = sin(2*pi*time/max(time)) + rand(length(time), 1)*0.1;
%   val2 = cos(2*pi*time/max(time)) + rand(length(time), 1)*0.1;
%   tiles = plot_data(time, val1, [], val2, val1, val2, 'line_properties', {'LineWidth', 2, 'DisplayName', 'est'}, 'prev_tiles', tiles);
% 
%   patch_properties = {'FaceColor', colors.orange{1}, 'FaceAlpha', 0.15, 'EdgeColor', 'none', 'DisplayName', 'Area'};
%   enable = abs(val1) > 0.5;
%   plot_patches(time, enable, tiles(1:2), patch_properties);
%
% Author: Jack Delcaro
% Data: 05/03/2024

function tiles = plot_patches(time, enable, tiles, patch_properties)
    
    % Check if time variable exists
    if ~exist('time', 'var')
        error('Time vector not specified!');       
    end
    
    % Check if enable variable exists
    if ~exist('enable', 'var')
        error('Enable vector not specified!');       
    end
    
    % Check if tiles variable exists
    if ~exist('tiles', 'var')
        error('Can only plot over some existing axes!');       
    end
    
    % Check if patch_properties variable exists
    if ~exist('patch_properties', 'var')
        patch_properties = {};      
    end
    
    % Ensure enable vector is a row vector
    if size(enable, 1) > size(enable, 2)
        enable = enable';
    end
    
    % Calculate start and end times for patches
    dt = mode(diff(time));
    start_times = time(diff([0, enable]) == +1) - dt/2;
    end_times   = time(diff([enable, 0]) == -1) + dt/2;
    
    % Return if no patches to be drawn
    if isempty(start_times)
        return;
    end
    
    % Check for mismatched start and end times
    if length(start_times) ~= length(end_times)
        warning('Error in: plot_r_beta_delta_patch, unable to plot patches');
        return;
    end
    
    % Define x coordinates for patches
    x_data(1, :) = start_times;
    x_data(2, :) = end_times;
    x_data(3, :) = end_times;
    x_data(4, :) = start_times;
    
    % Get the number of plots (axes)
    N_plots = length(tiles);
    
    % Iterate over each axis
    drawnow;
    for i = 1:N_plots
        % Get current y-limits of the axis
        curr_ylims = tiles(i).YLim;
        
        % Define y coordinates for patches
        y_data(1, :) = curr_ylims(1) - abs(diff(curr_ylims))*10000*ones(size(start_times));
        y_data(2, :) = curr_ylims(1) - abs(diff(curr_ylims))*10000*ones(size(start_times));
        y_data(3, :) = curr_ylims(2) + abs(diff(curr_ylims))*10000*ones(size(start_times));
        y_data(4, :) = curr_ylims(2) + abs(diff(curr_ylims))*10000*ones(size(start_times));
        
        % Draw patches
        mypatch = patch(tiles(i), 'XData', x_data, 'YData', y_data, patch_properties{:});
        uistack(mypatch, 'bottom');
        tiles(i).YLim = curr_ylims;
    end
    
end
