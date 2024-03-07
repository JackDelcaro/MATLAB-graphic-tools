% get_absolute_outerposition Computes the absolute position of a tile within a nested TiledLayout
%   absolute_position = get_absolute_outerposition(tile) calculates the absolute position of
%   the specified tile within its parent TiledLayout. The absolute position is
%   determined by recursively traversing through the parent tiles and accumulating
%   their positions.
%
%   Input:
%       tile: The tile whose absolute position is to be calculated.
%
%   Output:
%       absolute_position: A 1x4 vector representing the absolute position
%                         [left bottom width height] of the tile.

function absolute_position = get_absolute_outerposition(tile)
    % Initialize absolute position with the position of the input tile
    absolute_position = tile.OuterPosition;
    
    % Get the parent of the input tile
    parent = tile.Parent;
    
    % Iterate until we reach the top-level TiledLayout
    while ~isempty(parent) && (isa(parent, 'matlab.ui.container.TiledLayout') || isa(parent, 'matlab.graphics.layout.TiledChartLayout'))
        % Adjust the x and y positions by adding the parent's inner position
        parent_position = parent.OuterPosition;
        
        absolute_position(1) = absolute_position(1)*parent_position(3) + parent_position(1);
        absolute_position(2) = absolute_position(2)*parent_position(4) + parent_position(2);
        absolute_position(3) = absolute_position(3)*parent_position(3);
        absolute_position(4) = absolute_position(4)*parent_position(4);
        
        % Move to the parent of the current tile
        parent = parent.Parent;
    end
end