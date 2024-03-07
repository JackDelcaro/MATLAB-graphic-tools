
% PLOT_DATA Plot data using tiledlayout specified via a matrix or plot data over previous tiles.
%   TILES = PLOT_DATA(XDATA1, YDATA1, XDATA2, YDATA2, ..., 'Name', Value) plots data specified by XDATA and YDATA 
%   pairs on tiled axes. The number of data pairs can vary, and each pair will be plotted on its own tile. Optionally, 
%   additional parameters can be specified as name-value pairs:
%
%   'line_properties'  - Cell array of line properties for each plot. Default is empty cell array.
%   'yaxis_labels'     - Cell array of y-axis labels for each plot. Default is empty cell array.
%   'xaxis_labels'     - Cell array of x-axis labels for each plot. Default is empty cell array.
%   'tile_disposition' - Matrix specifying the layout of the tiles. Default results in a vertical layout.
%   'prev_tiles'       - Handle array of previous tiles. If specified, new plots will be added over these tiles.
%
%   If neither 'prev_tiles' nor 'tile_disposition' is provided, the plots will be laid out vertically.
%
%   TILES is an array of handles to the tiled axes created for each plot.
%
%   Additional Specification:
%   - If XDATA is specified as empty, the corresponding YDATA will be plotted on the same x-axis as the previous plot 
%     with non-empty XDATA. These plots will be linked in the x-axis and
%     the useless xticklabels will be removed to compact the plots.
%   - Example: 
%       tiles = plot_data(XDATA1, YDATA1, [], YDATA2, [], YDATA3, XDATA4, YDATA4, [], YDATA5, XDATA6, YDATA6);
%       Plots 1, 2, and 3 will be linked in the x-axis, while plots 4 and 5 will be linked separately.
%
%   Example:
%       time = (0:0.01:10)';
%       val1 = sin(2*pi*time/max(time)) + rand(length(time), 1)*0.1;
%       val2 = cos(2*pi*time/max(time)) + rand(length(time), 1)*0.1;
%       tiles = plot_data(time, val1, [], val2, val1, val2, 'line_properties', {'LineWidth', 2, 'DisplayName', 'meas'}, 'yaxis_labels', {'$y_1$', '$y_2$', 'cos'}, 'xaxis_labels', {'', '$x_2$', 'sin'}, 'tile_disposition', [1 1 3; 2 2 3]);
%       val1 = sin(2*pi*time/max(time)) + rand(length(time), 1)*0.1;
%       val2 = cos(2*pi*time/max(time)) + rand(length(time), 1)*0.1;
%       tiles = plot_data(time, val1, [], val2, val1, val2, 'line_properties', {'LineWidth', 2, 'DisplayName', 'est'}, 'prev_tiles', tiles);

% Author: Jack Delcaro
% Data: 05/03/2024

function tiles = plot_data(varargin)

%% CHECK INPUTS

    % Initialize variables
    xdata = {};
    ydata = {};
    line_properties = {};
    yaxis_labels = {};
    xaxis_labels = {};
    tile_disposition = [];
    prev_tiles = [];
    
    % Parse inputs
    i = 1;
    while i <= numel(varargin)
        % Check if the input is an array or matrix
        if i < numel(varargin) && (isnumeric(varargin{i}) || islogical(varargin{i}))
            xdata{end+1} = varargin{i}; %#ok<AGROW>
            ydata{end+1} = varargin{i+1}; %#ok<AGROW>
            i = i + 2;
        % Check if the input is a name-value pair
        elseif i < numel(varargin) && (ischar(varargin{i}) || isstring(varargin{i})) && any(strcmp(varargin{i}, {'line_properties', 'yaxis_labels', 'xaxis_labels', 'tile_disposition', 'prev_tiles'}))
            % Check which name-value pair it is and assign the value
            switch varargin{i}
                case 'line_properties'
                    line_properties = varargin{i+1};
                case 'yaxis_labels'
                    yaxis_labels = varargin{i+1};
                case 'xaxis_labels'
                    xaxis_labels = varargin{i+1};
                case 'tile_disposition'
                    tile_disposition = varargin{i+1};
                case 'prev_tiles'
                    prev_tiles = varargin{i+1};
            end
            i = i + 2;
        else
            error('Invalid input arguments');
        end
    end

    % Check if custom tiles are provided
    if ~isempty(prev_tiles)
        generate_tiles = false;
        tiles = prev_tiles;
    else
        generate_tiles = true;
    end
    
    if ~isempty(prev_tiles) && ~isempty(tile_disposition)
        error('Cannot specify both the tiles to plot in and the tile disposition');
    end
    
    % Compute number of plots
    if ~isempty(prev_tiles)
        N_plots = length(prev_tiles);
    elseif ~isempty(tile_disposition)
        N_plots = length(unique(tile_disposition(:)));
    else
        N_plots = length(xdata);
        tile_disposition = (1:N_plots)';
    end
    
    % Validate data consistency
    if length(xdata) ~= N_plots
        error('Data inputs and tile_disposition matrix have different number of plots!');
    end
    
    % If no plots provided, return
    if N_plots == 0
        return;
    end
    
    % Get unique values in the matrix
    unique_values = sort(unique(tile_disposition(:)));
    if any(unique_values ~= (1:length(unique_values))')
        error('Invalid matrix tile_disposition; values only subsequent integer values starting from 1 are allowed.');
    end

    % Check each unique value
    for val = unique_values'
        % Find indices of occurrences of the current value
        [row_indices, col_indices] = find(tile_disposition == val);
        num_elements = length(find(tile_disposition == val));

        % Check if occurrences form a rectangle
        is_rectangle = length(unique(row_indices))*length(unique(col_indices)) == num_elements;

        % Display result
        if ~is_rectangle
            error('Invalid matrix tile_disposition; not all sub-matrices are rectangular');
        end
    end
    
    % Convert labels to string
    yaxis_labels = string(yaxis_labels);
    xaxis_labels = string(xaxis_labels);
    
    % Check consistency of y-axis labels    
    if N_plots ~= length(yaxis_labels)
        if ~isempty(yaxis_labels)
            warning("Inconsistent ylabel entries: there are " + num2str(N_plots) + " input data but " + num2str(length(yaxis_labels)) + " ylabels. Skipping the labels");
        end
        skip_y_labels = true;
    else
        skip_y_labels = false;
    end
    
    % Check consistency of x-axis labels    
    if N_plots ~= length(xaxis_labels)
        if ~isempty(xaxis_labels)
            warning("Inconsistent xlabel entries: there are " + num2str(N_plots) + " input data but " + num2str(length(xaxis_labels)) + " xlabels. Skipping the labels");
        end
        skip_x_labels = true;
    else
        skip_x_labels = false;
    end
    
    if isempty(line_properties)
        line_properties = {};
    end
    
    % Check which data to plot and check which x axes to link
    plot_data = false(N_plots, 1);
    linked_xaxes = nan(N_plots, 1); % Vector containing which plots are linked
    linked_xaxes(1) = 1;
    for i = 1:N_plots
        % If x_data is not specified copy the data of the previous plot
        if i > 1 && isempty(xdata{i})
            xdata{i} = xdata{i-1}; %#ok<AGROW>
            linked_xaxes(i) = linked_xaxes(i-1);
        elseif i > 1
            linked_xaxes(i) = linked_xaxes(i-1) + 1;
        end
        plot_data(i) = ~isempty(xdata{i}) && ~isempty(ydata{i}) && all(size(xdata{i}) == size(ydata{i}));
        if any(size(xdata{i}) ~= size(ydata{i})) && ~isempty(xdata{i}) && ~isempty(ydata{i})
            warning("Inconsistent dimensions: time data and input data " + num2str(i) + " are not consistent. Skipping plot.");
        end
    end
    
%% GENERATE TILES

    % Generate tiles
    if generate_tiles 
        
        figure();
        tiledlayout(size(tile_disposition, 1), size(tile_disposition, 2), 'TileSpacing', 'tight');
        
        for i = 1:N_plots
            tiles(i) = nexttile(find(tile_disposition' == i, 1, 'first'), [sum(any(tile_disposition == i, 2)), sum(any(tile_disposition == i, 1))]); hold on; grid minor;
            if ~isempty(line_properties) && any(string(line_properties(1:2:end)) == "DisplayName")
                legend;
            end
            if ~skip_y_labels
                ylabel(yaxis_labels(i));
            end
            if ~skip_x_labels
                xlabel(xaxis_labels(i));
            end
        end
        
    else
        % If custom tiles are provided, skip tile generation
        for i = 1:N_plots
            if ~isempty(line_properties) && any(string(line_properties(1:2:end)) == "DisplayName")
                legend(tiles(i));
            end
            if ~skip_y_labels
                ylabel(yaxis_labels(i));
            end
            if ~skip_x_labels
                xlabel(xaxis_labels(i));
            end
        end        
    end

%% PLOT DATA

    % Plot data on respective tiles
    for i = 1:N_plots
        if plot_data(i)
            plot(tiles(i), xdata{i}, ydata{i}, line_properties{:});
            tiles(i).XLim = [min(xdata{i}, [], 'all'), max(xdata{i}, [], 'all')];
        end
    end
    
    drawnow;
    
%% ADJUST PLOTS
    
    % Adjust plot layout: if there are linked axes, remove the xticklabels
    % of the all the plots above the bottom one (only bottom plot keeps the
    % xticklabels for each set of linked axes)
    if generate_tiles
        
        % Cycle for each set of linked axes
        for val = unique(linked_xaxes)'
            
            % Get indexes of the linked axes
            curr_axes_indexes = unique_values(linked_xaxes == val);
            
            % Cycle for each linked axis
            for idx = curr_axes_indexes'
                
                % Get rows and columns for the considered axis
                [row_indices, col_indices] = find(tile_disposition == idx);
                last_row_idx = max(row_indices);
                
                % Check whether below the considered axis there are other
                % axes contained in the same set of linked axes. If so,
                % remove its xticklabel
                if ~isempty(tile_disposition(last_row_idx+1:end, unique(col_indices))) && any(tile_disposition(last_row_idx+1:end, unique(col_indices)) == reshape(curr_axes_indexes, 1, 1, []), 'all')
                    tiles(idx).XTickLabel = '';
                end
            end
            
            % Link all axes in the linked axes set
            linkaxes(tiles(curr_axes_indexes), 'x'); 
        end
        
    end
    
end