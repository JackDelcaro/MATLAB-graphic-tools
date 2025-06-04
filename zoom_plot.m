% function [parent_axis, child_axis, rect_zoom, zoom_lines] = zoom_plot(varargin)
% This function creates an additional plot in which a zoomed portion of a
% plot is reported. There are many ways to interact with this function:
% - manual method: after drawing your figure, call zoom_plot function. By
%                  selecting the "Edit Plot" option on the top of the
%                  figure (pointer-shaped button in the figure toolbar) you
%                  can change both the position of the rectangle and of the
%                  newly generated zoomed axis plot. This metod does NOT
%                  work if you are using the tiledlayout option.
% - coded method: you can specify programmatically the position of the
%                 zoom rectangle, its color and linewidth and the new zoomed
%                 plot axis position as input arguments to the zoom_plot function 
%
% inputs:
% - axis_handle (optional): handle to the axis you want to zoom in to
% - name/parameter (optional):
%    - name: 'mode', parameter: string, it can be either "pinned_rectangle"
%            (default) or "fig_aligned_rectangle". In "pinned_rectangle"
%            mode, if you pan/zoom either the parent or child axis the
%            rectangle moves consequently. In "fig_aligned_rectangle" mode
%            the rectangle keeps the same position with respect to the
%            parent axis and the child axis is updated consequently.
%    - name: 'rectangle_color', parameter: color of the rectangle
%    - name: 'rectangle_linewidth', parameter: LineWidth of the rectangle
%    - name: 'rectangle_position', parameter: position of the rectangle in
%            x-y coordinates. As any position, it must be specified as a
%            vector of 4 elements: [left, bottom, width, height]
%    - name: 'zoom_axis_position', parameter: position of the new zoomed
%            plot axis, specified in [0-1] coordinates referred to the
%            parent axis. As any position, it must be specified as a
%            vector of 4 elements: [left, bottom, width, height]. Example:
%            [0.7 0.1 0.3 0.2] is a rectangle with 30% of the width of the
%            parent axis, 20% of its height, whose bottom left corner is
%            placed in (70%, 10%) of the parent axis box.
%    - name: 'absolute_rectangle_position', parameter: boolean. If true the
%            parameter 'rectangle_position' is set to be absolute within
%            the figure (as an annotation or an axis), and not relative to
%            the parent axis.
%    - name: 'absolute_zoom_axis_position', parameter: boolean. If true the
%            parameter 'zoom_axis_position' is set to be absolute within
%            the figure (as an annotation or an axis), and not relative to
%            the parent axis.
%
% Example:
% figure; hold on;
% plot(rand(1,100)*0.05+1-exp(-(0:99)/75));
% zoom_plot();
%
% Other example:
% figure; hold on;
% plot(rand(1,100)*0.05+1-exp(-(0:99)/30));
% plot(rand(1,100)*0.05+1-exp(-(0:99)/30));
% plot(rand(1,100)*0.05+1-exp(-(0:99)/30));
% [parent_axis, child_axis, rect_handle, line_handles] = zoom_plot(gca, 'mode', 'fig_aligned_rectangle',...
%    'rectangle_position', [30 0.6518 11.2258 0.1281], 'zoom_axis_position', [0.5169 0.0605 0.4543 0.5141],...
%    'rectangle_color', 'k', 'rectangle_linewidth', 2);
%
% Other example:
% figure; hold on;
% plot(rand(1,100)*0.05+1-exp(-(0:99)/30));
% plot(rand(1,100)*0.05+1-exp(-(0:99)/30));
% plot(rand(1,100)*0.05+1-exp(-(0:99)/30));
% [parent_axis, child_axis, rect_handle, line_handles] = zoom_plot(gca, 'mode', 'pinned_rectangle',...
%    'rectangle_position', [0.3625 0.5527 0.0870 0.0870], 'zoom_axis_position', [0.5306 0.1593 0.3521 0.4190],...
%    'rectangle_color', 'k', 'rectangle_linewidth', 2, 'absolute_rectangle_position', 1, 'absolute_zoom_axis_position', 1);
% 
%
% Author: Jack Delcaro
% Tested in MATLAB 2021a
% Last revision: 01/01/2024

function varargout = zoom_plot(varargin)

drawnow;

%% ELABORATE INPUTS

if nargin == 1 || (nargin > 1 && mod(nargin, 2) == 1)
    parent_axis = varargin{1};
    if(~isa(parent_axis,'matlab.graphics.axis.Axes'))
        error('First input argument should be an Axis handle');
    end
    varargin = varargin(2:end);
else
    parent_axis = gca;
end

% Default values
mode = "pinned_rectangle"; % # The position of the rectangle is fixed with respect to the graph beneath it.
color = [0.15 0.15 0.15]; % Standard grey color
linewidth = 1; % Used for both the rectangle and the lines
rect_pos(1) = parent_axis.Position(3)*0.3 + parent_axis.Position(1);
rect_pos(2) = parent_axis.Position(4)*0.4 + parent_axis.Position(2);
rect_pos(3) = 0.25*parent_axis.Position(3);
rect_pos(4) = 0.25*parent_axis.Position(4);
child_axis_pos(1) = parent_axis.Position(3)*0.6 + parent_axis.Position(1);
child_axis_pos(2) = parent_axis.Position(4)*0.05 + parent_axis.Position(2);
child_axis_pos(3) = 0.35*parent_axis.Position(3);
child_axis_pos(4) = 0.35*parent_axis.Position(4);
absolute_rect_pos = false;
absolute_child_axis_pos = false;
cursor_selected = 'on';

% Parse all inputs and check their values
allowed_inputs = ["rectangle_color"; "rectangle_linewidth"; "rectangle_position"; "zoom_axis_position"; "absolute_rectangle_position"; "absolute_zoom_axis_position"; "mode"];
for i = 1:2:length(varargin)
    if string(varargin{i}) == allowed_inputs(1)
        color = varargin{i+1};
    elseif string(varargin{i}) == allowed_inputs(2)
        if isscalar(varargin{i+1})
            linewidth = varargin{i+1};
        else
            error('Parameter rectangle_linewidth is not scalar.');
        end
    elseif string(varargin{i}) == allowed_inputs(3)
        tmp = varargin{i+1};
        if isvector(tmp) && length(tmp) == 4 && isnumeric(tmp)
            new_rect_pos = tmp;
            cursor_selected = 'off';
        else
            error('Parameter rectangle_position is not a numeric vctor of dimension 4.');
        end
    elseif string(varargin{i}) == allowed_inputs(4)
        tmp = varargin{i+1};
        if isvector(tmp) && length(tmp) == 4 && isnumeric(tmp)
            new_child_axis_pos = tmp;
            cursor_selected = 'off';
        else
            error('Parameter rectangle_position is not a numeric vctor of dimension 4.');
        end
    elseif string(varargin{i}) == allowed_inputs(5)
        if islogical(varargin{i+1}) || varargin{i+1} == 0 || varargin{i+1} == 1
            absolute_rect_pos = boolean(varargin{i+1});
        else
            error('Parameter absolute_rectangle_position is not boolean.');
        end
    elseif string(varargin{i}) == allowed_inputs(6)
        if islogical(varargin{i+1}) || varargin{i+1} == 0 || varargin{i+1} == 1
            absolute_child_axis_pos = boolean(varargin{i+1});
        else
            error('Parameter absolute_zoom_axis_position is not boolean.');
        end
    elseif string(varargin{i}) == allowed_inputs(7)
        if (isstring(varargin{i+1}) || ischar(varargin{i+1})) && (string(varargin{i+1}) == "pinned_rectangle" || string(varargin{i+1}) == "fig_aligned_rectangle")
            mode = string(varargin{i+1});
        else
            error('Parameter mode is not correct.');
        end
    else
        error("Invalid input argument: " + string(varargin{i}));
    end
end

% Set the position of the rectangle
if exist('new_rect_pos', 'var') && ~absolute_rect_pos
    rect_pos(1) = (new_rect_pos(1)-parent_axis.XLim(1))/diff(parent_axis.XLim)*parent_axis.Position(3) + parent_axis.Position(1);
    rect_pos(2) = (new_rect_pos(2)-parent_axis.YLim(1))/diff(parent_axis.YLim)*parent_axis.Position(4) + parent_axis.Position(2);
    rect_pos(3) = new_rect_pos(3)/diff(parent_axis.XLim)*parent_axis.Position(3);
    rect_pos(4) = new_rect_pos(4)/diff(parent_axis.YLim)*parent_axis.Position(4);
elseif exist('new_rect_pos', 'var') && absolute_rect_pos
    rect_pos = new_rect_pos;
end

% Set the position of the child axis
if exist('new_child_axis_pos', 'var') && ~absolute_child_axis_pos
    child_axis_pos(1) = parent_axis.Position(3)*new_child_axis_pos(1) + parent_axis.Position(1);
    child_axis_pos(2) = parent_axis.Position(4)*new_child_axis_pos(2) + parent_axis.Position(2);
    child_axis_pos(3) = new_child_axis_pos(3)*parent_axis.Position(3);
    child_axis_pos(4) = new_child_axis_pos(4)*parent_axis.Position(4);
elseif exist('new_child_axis_pos', 'var') && absolute_child_axis_pos
    child_axis_pos = new_child_axis_pos;
end

clearvars tmp;

%% PLOT RECTANGLE and AXIS

hold on;

% Draw the rectangle
rect_zoom = annotation('rectangle', rect_pos, 'EdgeColor', color, 'LineWidth', linewidth, 'Selected', cursor_selected, 'HandleVisibility', 'off');

% Draw the child axis
child_axis = axes('position', child_axis_pos, 'Selected', cursor_selected, 'Layer', 'top', 'Box', 'on');

% Copy all graphic element of the parent axis to the child
graphic_elements = copy(parent_axis.Children);
for i = length(graphic_elements):-1:1
   copyobj(graphic_elements(i), child_axis)
end

% Draw the lines connecting the rectangle and the child axis. For the
% moment these lines are just a placeholder
zoom_lines(1) = annotation('line', [0 0], [0 0], 'Color', color, 'LineWidth', linewidth, 'HandleVisibility', 'off');
zoom_lines(2) = annotation('line', [0 0], [0 0], 'Color', color, 'LineWidth', linewidth, 'HandleVisibility', 'off');

% In order to access all the object in the callbacks (see later) we add a
% pointer to all graphic objects within the UserData field of each graphic
% object
tmp.mode = mode;
tmp.zoom_line1 = zoom_lines(1);
tmp.zoom_line2 = zoom_lines(2);
tmp.child_axis = child_axis;
tmp.parent_axis = parent_axis;
tmp.rect_zoom = rect_zoom;
zoom_lines(1).UserData = tmp;
zoom_lines(2).UserData = tmp;
child_axis.UserData = tmp;
parent_axis.UserData = tmp;
rect_zoom.UserData = tmp;
rect_zoom.UserData.previous_position = rect_zoom.Position;
child_axis.UserData.relative_position = [(child_axis.Position(1)-parent_axis.Position(1))/parent_axis.Position(3), (child_axis.Position(2)-parent_axis.Position(2))/parent_axis.Position(4), child_axis.Position(3)/parent_axis.Position(3), child_axis.Position(4)/parent_axis.Position(4)];
rect_zoom.UserData.relative_position = [(rect_zoom.Position(1)-parent_axis.Position(1))/parent_axis.Position(3)*diff(parent_axis.XLim)+parent_axis.XLim(1) (rect_zoom.Position(2)-parent_axis.Position(2))/parent_axis.Position(4)*diff(parent_axis.YLim)+parent_axis.YLim(1) rect_zoom.Position(3)/parent_axis.Position(3)*diff(parent_axis.XLim) rect_zoom.Position(4)/parent_axis.Position(4)*diff(parent_axis.YLim)];

% Run the callbacks once
drawnow;
event.AffectedObject.UserData = tmp;
limit_rectangle_area(nan, event);
update_zoom_lines(nan, event);
update_child_axis_limits(nan, event);

% Add listeners: if the user manually changes the rectangle, child axis,
% zoom of the parent axis all the objects' properties are automatically
% changed
if mode == "fig_aligned_rectangle"
    rect_zoom.UserData.listener(1)   = addlistener(rect_zoom, 'Position', 'PostSet', @update_zoom_lines);
    rect_zoom.UserData.listener(2)   = addlistener(rect_zoom, 'Position', 'PostSet', @limit_rectangle_area);
    rect_zoom.UserData.listener(3)   = addlistener(rect_zoom, 'Position', 'PostSet', @update_child_axis_limits);
    child_axis.UserData.listener(1)  = addlistener(child_axis, 'Position', 'PostSet', @update_zoom_lines);
    child_axis.UserData.listener(2)  = addlistener(child_axis, 'XLim', 'PostSet', @update_zoom_rect);
    child_axis.UserData.listener(3)  = addlistener(child_axis, 'YLim', 'PostSet', @update_zoom_rect);
    parent_axis.UserData.listener(1) = addlistener(parent_axis, 'XLim', 'PostSet', @update_child_axis_limits);
    parent_axis.UserData.listener(2) = addlistener(parent_axis, 'YLim', 'PostSet', @update_child_axis_limits);
    parent_axis.UserData.listener(3) = addlistener(parent_axis, 'Position', 'PostSet', @update_child_axis_limits);
    parent_axis.UserData.listener(4) = addlistener(parent_axis, 'Position', 'PostSet', @update_child_axis_position);
else
    rect_zoom.UserData.listener(1)   = addlistener(rect_zoom, 'Position', 'PostSet', @update_zoom_lines);
    rect_zoom.UserData.listener(2)   = addlistener(rect_zoom, 'Position', 'PostSet', @limit_rectangle_area);
    rect_zoom.UserData.listener(3)   = addlistener(rect_zoom, 'Position', 'PostSet', @update_child_axis_limits);
    child_axis.UserData.listener(1)  = addlistener(child_axis, 'Position', 'PostSet', @update_zoom_lines);
    child_axis.UserData.listener(2)  = addlistener(child_axis, 'XLim', 'PostSet', @update_zoom_rect);
    child_axis.UserData.listener(3)  = addlistener(child_axis, 'YLim', 'PostSet', @update_zoom_rect);
    parent_axis.UserData.listener(1) = addlistener(parent_axis, 'XLim', 'PostSet', @update_zoom_rect);
    parent_axis.UserData.listener(2) = addlistener(parent_axis, 'YLim', 'PostSet', @update_zoom_rect);
    parent_axis.UserData.listener(3) = addlistener(parent_axis, 'Position', 'PostSet', @update_zoom_rect);
    parent_axis.UserData.listener(4) = addlistener(parent_axis, 'Position', 'PostSet', @update_child_axis_position);
end

%% OUPTUTS

if nargout == 0
    varargout = {};
end
if nargout >= 1
    varargout{1} = parent_axis;
end
if nargout >= 2
    varargout{2} = child_axis;
end
if nargout >= 3
    varargout{3} = rect_zoom;
end
if nargout >= 4
    varargout{4} = zoom_lines;
end
if nargout > 4
    error('Incorrect number of outputs');
end

end

% This function updates the position of the two lines connecting the
% rectangle to the child axis
function update_zoom_lines(~, event)
    
    parent_axis = event.AffectedObject.UserData.parent_axis;
    child_axis = event.AffectedObject.UserData.child_axis;
    rect_zoom = event.AffectedObject.UserData.rect_zoom;
    zoom_lines(1) = event.AffectedObject.UserData.zoom_line1;
    zoom_lines(2) = event.AffectedObject.UserData.zoom_line2;
    
    % Vertexes are ordered as follows: bottom left A, bottom right B, top
    % right C and top left D. 1 refers to the rectangle and 2 refers to the
    % child axis.
    vertexes.A1.x = rect_zoom.Position(1);
    vertexes.A1.y = rect_zoom.Position(2);
    vertexes.B1.x = rect_zoom.Position(1)+rect_zoom.Position(3);
    vertexes.B1.y = rect_zoom.Position(2);
    vertexes.C1.x = rect_zoom.Position(1)+rect_zoom.Position(3);
    vertexes.C1.y = rect_zoom.Position(2)+rect_zoom.Position(4);
    vertexes.D1.x = rect_zoom.Position(1);
    vertexes.D1.y = rect_zoom.Position(2)+rect_zoom.Position(4);

    vertexes.A2.x = child_axis.Position(1);
    vertexes.A2.y = child_axis.Position(2);
    vertexes.B2.x = child_axis.Position(1)+child_axis.Position(3);
    vertexes.B2.y = child_axis.Position(2);
    vertexes.C2.x = child_axis.Position(1)+child_axis.Position(3);
    vertexes.C2.y = child_axis.Position(2)+child_axis.Position(4);
    vertexes.D2.x = child_axis.Position(1);
    vertexes.D2.y = child_axis.Position(2)+child_axis.Position(4);
    
    % The following conditions are necessary to understand the relative
    % position between rectangle and child axis, so as to connect the two
    % in the correct way.
    if     (vertexes.A1.x <= vertexes.A2.x && vertexes.A1.y >= vertexes.A2.y && vertexes.D1.x <= vertexes.D2.x && vertexes.D1.y <= vertexes.D2.y) || (vertexes.A1.x <= vertexes.A2.x && vertexes.A1.y <= vertexes.A2.y && vertexes.D1.x <= vertexes.D2.x && vertexes.D1.y >= vertexes.D2.y)
        set(zoom_lines(1), 'X', [vertexes.B1.x, vertexes.A2.x], 'Y', [vertexes.B1.y, vertexes.A2.y]);
        set(zoom_lines(2), 'X', [vertexes.C1.x, vertexes.D2.x], 'Y', [vertexes.C1.y, vertexes.D2.y]);
    elseif (vertexes.A1.x >= vertexes.A2.x && vertexes.A1.y <= vertexes.A2.y && vertexes.B1.x <= vertexes.B2.x && vertexes.B1.y <= vertexes.B2.y) || (vertexes.A1.x <= vertexes.A2.x && vertexes.A1.y <= vertexes.A2.y && vertexes.B1.x >= vertexes.B2.x && vertexes.B1.y <= vertexes.B2.y)
        set(zoom_lines(1), 'X', [vertexes.D1.x, vertexes.A2.x], 'Y', [vertexes.D1.y, vertexes.A2.y]);
        set(zoom_lines(2), 'X', [vertexes.C1.x, vertexes.B2.x], 'Y', [vertexes.C1.y, vertexes.B2.y]);
    elseif (vertexes.A1.x >= vertexes.A2.x && vertexes.A1.y >= vertexes.A2.y && vertexes.D1.x >= vertexes.D2.x && vertexes.D1.y <= vertexes.D2.y) || (vertexes.A1.x >= vertexes.A2.x && vertexes.A1.y <= vertexes.A2.y && vertexes.D1.x >= vertexes.D2.x && vertexes.D1.y >= vertexes.D2.y)
        set(zoom_lines(1), 'X', [vertexes.D1.x, vertexes.C2.x], 'Y', [vertexes.D1.y, vertexes.C2.y]);
        set(zoom_lines(2), 'X', [vertexes.A1.x, vertexes.B2.x], 'Y', [vertexes.A1.y, vertexes.B2.y]);
    elseif (vertexes.A1.x >= vertexes.A2.x && vertexes.A1.y >= vertexes.A2.y && vertexes.B1.x <= vertexes.B2.x && vertexes.B1.y >= vertexes.B2.y) || (vertexes.A1.x <= vertexes.A2.x && vertexes.A1.y >= vertexes.A2.y && vertexes.B1.x >= vertexes.B2.x && vertexes.B1.y >= vertexes.B2.y)
        set(zoom_lines(1), 'X', [vertexes.A1.x, vertexes.D2.x], 'Y', [vertexes.A1.y, vertexes.D2.y]);
        set(zoom_lines(2), 'X', [vertexes.B1.x, vertexes.C2.x], 'Y', [vertexes.B1.y, vertexes.C2.y]);
    else
        if (vertexes.B1.x < vertexes.B2.x && vertexes.B1.y < vertexes.B2.y) || (vertexes.B1.x > vertexes.B2.x && vertexes.B1.y > vertexes.B2.y)
            set(zoom_lines(1), 'X', [vertexes.B1.x, vertexes.B2.x], 'Y', [vertexes.B1.y, vertexes.B2.y]);
        end
        if (vertexes.D1.x < vertexes.D2.x && vertexes.D1.y < vertexes.D2.y) || (vertexes.D1.x > vertexes.D2.x && vertexes.D1.y > vertexes.D2.y)
            set(zoom_lines(2), 'X', [vertexes.D1.x, vertexes.D2.x], 'Y', [vertexes.D1.y, vertexes.D2.y]);
        end
        if (vertexes.A1.x > vertexes.A2.x && vertexes.A1.y < vertexes.A2.y) || (vertexes.A1.x < vertexes.A2.x && vertexes.A1.y > vertexes.A2.y)
            set(zoom_lines(1), 'X', [vertexes.A1.x, vertexes.A2.x], 'Y', [vertexes.A1.y, vertexes.A2.y]);
        end
        if (vertexes.C1.x > vertexes.C2.x && vertexes.C1.y < vertexes.C2.y) || (vertexes.C1.x < vertexes.C2.x && vertexes.C1.y > vertexes.C2.y)
            set(zoom_lines(2), 'X', [vertexes.C1.x, vertexes.C2.x], 'Y', [vertexes.C1.y, vertexes.C2.y]);
        end
    end
    
    child_axis.UserData.relative_position = [(child_axis.Position(1)-parent_axis.Position(1))/parent_axis.Position(3), (child_axis.Position(2)-parent_axis.Position(2))/parent_axis.Position(4), child_axis.Position(3)/parent_axis.Position(3), child_axis.Position(4)/parent_axis.Position(4)];

end

% This function is needed to keep the rectangle completely contained inside
% the parent axis (the rectangle is an annotation so in principle it could
% float outside the parent axis)
function limit_rectangle_area(~, event)
    
    parent_axis = event.AffectedObject.UserData.parent_axis;
    rect_zoom = event.AffectedObject.UserData.rect_zoom;

    previous_rect_pos = rect_zoom.UserData.previous_position;
    
    % If the new position is outside the parent axis, reset the position to
    % the last allowed position
    if rect_zoom.Position(1) < parent_axis.Position(1) || ...
       rect_zoom.Position(1)+rect_zoom.Position(3) > parent_axis.Position(1)+parent_axis.Position(3) || ...
       rect_zoom.Position(2) < parent_axis.Position(2) || ...
       rect_zoom.Position(2)+rect_zoom.Position(4) > parent_axis.Position(2)+parent_axis.Position(4)

        rect_zoom.Position = previous_rect_pos;

    end

    rect_zoom.UserData.previous_position = rect_zoom.Position;
    rect_zoom.UserData.relative_position = [(rect_zoom.Position(1)-parent_axis.Position(1))/parent_axis.Position(3)*diff(parent_axis.XLim)+parent_axis.XLim(1) (rect_zoom.Position(2)-parent_axis.Position(2))/parent_axis.Position(4)*diff(parent_axis.YLim)+parent_axis.YLim(1) rect_zoom.Position(3)/parent_axis.Position(3)*diff(parent_axis.XLim) rect_zoom.Position(4)/parent_axis.Position(4)*diff(parent_axis.YLim)];

end

% This function is used to update the child axis XLim and YLim whenever
% there are any changes in the position of the rectangle
function update_child_axis_limits(~, event)
    
    child_axis = event.AffectedObject.UserData.child_axis;
    parent_axis = event.AffectedObject.UserData.parent_axis;
    rect_zoom = event.AffectedObject.UserData.rect_zoom;

    parent_axis_pos = get(parent_axis, 'Position');
    
    parent_axis_xlim = get(parent_axis, 'XLim');
    parent_axis_ylim = get(parent_axis, 'YLim');

    x_start = (rect_zoom.Position(1) - parent_axis_pos(1))/parent_axis_pos(3)*diff(parent_axis_xlim) + parent_axis_xlim(1);
    y_start = (rect_zoom.Position(2) - parent_axis_pos(2))/parent_axis_pos(4)*diff(parent_axis_ylim) + parent_axis_ylim(1);
    x_end = (rect_zoom.Position(1)+rect_zoom.Position(3) - parent_axis_pos(1))/parent_axis_pos(3)*diff(parent_axis_xlim) + parent_axis_xlim(1);
    y_end = (rect_zoom.Position(2)+rect_zoom.Position(4) - parent_axis_pos(2))/parent_axis_pos(4)*diff(parent_axis_ylim) + parent_axis_ylim(1);

    xlim(child_axis, [x_start, x_end]);
    ylim(child_axis, [y_start, y_end]);
end

% This function is used to update the child axis position whenever
% there are any changes in the position of the parent axis
function update_child_axis_position(~, event)
    
    child_axis = event.AffectedObject.UserData.child_axis;
    parent_axis = event.AffectedObject.UserData.parent_axis;

    previous_child_axis_relative_pos = child_axis.UserData.relative_position;
    
    child_axis_pos(1) = parent_axis.Position(3)*previous_child_axis_relative_pos(1) + parent_axis.Position(1);
    child_axis_pos(2) = parent_axis.Position(4)*previous_child_axis_relative_pos(2) + parent_axis.Position(2);
    child_axis_pos(3) = previous_child_axis_relative_pos(3)*parent_axis.Position(3);
    child_axis_pos(4) = previous_child_axis_relative_pos(4)*parent_axis.Position(4);

    child_axis.Position = child_axis_pos;
end

% This function updates the position of the rectangle according to the
% child axis XLim and YLim
function update_zoom_rect(~, event)
    
    child_axis = event.AffectedObject.UserData.child_axis;
    parent_axis = event.AffectedObject.UserData.parent_axis;
    rect_zoom = event.AffectedObject.UserData.rect_zoom;
    
    if rect_zoom.Selected == 1
        return;
    end
    
    child_axis_xlim = get(child_axis, 'XLim');
    child_axis_ylim = get(child_axis, 'YLim');

    parent_axis_pos = get(parent_axis, 'Position');
    
    parent_axis_xlim = get(parent_axis, 'XLim');
    parent_axis_ylim = get(parent_axis, 'YLim');
    
    rect_zoom.UserData.listener(3).Enabled = 0;

    rect_zoom.Position(1) = (child_axis_xlim(1) - parent_axis_xlim(1))/diff(parent_axis_xlim)*parent_axis_pos(3) + parent_axis_pos(1);
    rect_zoom.Position(2) = (child_axis_ylim(1) - parent_axis_ylim(1))/diff(parent_axis_ylim)*parent_axis_pos(4) + parent_axis_pos(2);
    rect_zoom.Position(3) = diff(child_axis_xlim)/diff(parent_axis_xlim)*parent_axis_pos(3);
    rect_zoom.Position(4) = diff(child_axis_ylim)/diff(parent_axis_ylim)*parent_axis_pos(4);
    
    rect_zoom.UserData.relative_position = [(rect_zoom.Position(1)-parent_axis.Position(1))/parent_axis.Position(3)*diff(parent_axis.XLim)+parent_axis.XLim(1) (rect_zoom.Position(2)-parent_axis.Position(2))/parent_axis.Position(4)*diff(parent_axis.YLim)+parent_axis.YLim(1) rect_zoom.Position(3)/parent_axis.Position(3)*diff(parent_axis.XLim) rect_zoom.Position(4)/parent_axis.Position(4)*diff(parent_axis.YLim)];
    
    rect_zoom.UserData.listener(3).Enabled = 1;
end
