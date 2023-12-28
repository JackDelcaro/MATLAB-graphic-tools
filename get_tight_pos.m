% GET_TIGHT_POS Returns the tight position of a graphical object.
%
%   POS = GET_TIGHT_POS(OBJ) calculates and returns the tight position of the
%   specified graphical object OBJ. If OBJ is not provided, the function
%   uses the currently selected object (gco) by default. The tight position
%   represents the minimal bounding box around the object, accounting for
%   its tight inset.
%
%   Input:
%       - OBJ: (Optional) MATLAB graphical object. If not provided, the
%              function uses the currently selected object.
%
%   Output:
%       - POS: 1x4 array representing the tight position of the object.
%
%   Supported Object Types:
%       - MATLAB Axes (matlab.graphics.axis.Axes)
%       - ColorBar (matlab.graphics.illustration.ColorBar)
%       - Legend (matlab.graphics.illustration.Legend)
%
%   Example:
%   fig = figure;
%   for i = 1:4
%     s(i) = subplot(2, 2, i); plot(rand(100, 1));
%   end
%   drawnow;
%   for i = 1:4
%     dimensions = get_tight_pos(s(i));
%     annotation('rectangle', dimensions, 'Color', 'r', 'LineWidth', 2);
%   end
%
% Author: Jack Delcaro
% Tested in MATLAB 2021a
% Last revision: 01/01/2024

function pos = get_tight_pos(obj)

    % If there is no input, use the currently selected object as input
    if ~exist('obj', 'var')
        obj = gco;
    end
    drawnow; % Update the figure to ensure accurate measurements
    
    % If the object is an axis, output the tight inset of the axis
    if isa(obj, 'matlab.graphics.axis.Axes')
        pos = obj.Position+obj.TightInset.*[-1 -1 1 1]+[0 0 obj.TightInset(1:2)];
        pos = max([0 0 0 0], pos);
        pos = min([1 1 1 1], pos);
        
    % If the object is a colorbar, we generate a temporary axis with the
    % same dimensions, fonts and labels of the colorbar and get its
    % position
    elseif isa(obj, 'matlab.graphics.illustration.ColorBar')
        ax = axes(ancestor(obj,'figure'), 'Position', obj.Position, 'Visible', 'off', 'Color', 'none', 'HandleVisibility', 'off');
        
        % Set properties to match colorbar
        ax.TickDir = obj.TickDirection;
        ax.TickLabelInterpreter = obj.TickLabelInterpreter;        
        ax.FontAngle = obj.FontAngle;
        ax.FontName = obj.FontName;
        ax.FontSize = obj.FontSize;
        ax.FontWeight = obj.FontWeight;
        
        % Customize axis based on colorbar orientation
        if string(obj.Orientation) == "horizontal"
            % Horizontal colorbar settings
            ax.XAxisLocation = obj.XAxisLocation;
            ax.XLim = obj.Limits;
            ax.XTick = obj.Ticks;
            ax.XTickLabel = obj.TickLabels;
            ax.XTickLabelMode = obj.TickLabelsMode;
            ax.XColor = 'r';
            ax.YTickLabel = {};
        else 
            % Vertical colorbar settings
            ax.YAxisLocation = obj.YAxisLocation;     
            ax.YLim = obj.Limits;
            ax.YTick = obj.Ticks;
            ax.YTickLabel = obj.TickLabels;
            ax.YTickLabelMode = obj.TickLabelsMode;
            ax.YColor = 'r';
            ax.XTickLabel = {};
        end
        
        % Copy relevant label properties from colorbar to temporary axis
        copyfields = ["String", "FontUnits", "FontAngle", "FontName", "FontSize", "FontWeight", "HorizontalAlignment", "Interpreter", "LineStyle", "LineWidth", "Margin", "Rotation", "VerticalAlignment"];
        for i = 1:length(copyfields)
            if string(obj.Orientation) == "horizontal"
                ax.XLabel.(copyfields(i)) = obj.Label.(copyfields(i));
            else
                ax.YLabel.(copyfields(i)) = obj.Label.(copyfields(i));
            end
        end
        
        % Set label color and make the temporary axis visible
        ax.YLabel.Color = 'r';
        ax.Visible = 'on';
        drawnow;
        
        % Recursively call the function to get tight position of the temporary axis
        pos = get_tight_pos(ax);
        
        % Remove the temporary axis
        delete(ax);
        
    % If the object is a legend, its position is its tight inset
    elseif isa(obj, 'matlab.graphics.illustration.Legend')
        pos = obj.Position;
    
    % Unsupported input object type
    else
        error('Error in function "get_tight_pos": unsupported input object');
    end
end