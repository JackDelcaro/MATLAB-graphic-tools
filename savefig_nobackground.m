% SAVEFIG_NOBACKGROUND Saves a figure without background.
%
%   savefig_nobackground() Saves the current figure with an untitled name
%   and default extension "svg" in the current working directory.
%
%   savefig_nobackground(gcf, 'my_figure') Saves the current figure,
%   without background with an name 'my_figure'.
%
%   savefig_nobackground(fig, FILENAME) Saves the specified figure fig
%   with the specified FILENAME with its extension. If FILENAME
%   does not have an extension, it will be appended with ".svg".
%
%   Supported extensions: "svg", "png", "pdf", "emf", "eps".
%   For the png format the program inkscape is required. For the png format
%   the dpi are set to 300.
%
%   Example:
%     savefig_nobackground(); % Saves current figure as "untitled.svg"
%     savefig_nobackground(gcf, 'my_figure.png'); % Saves current
%                                                 % figure as "my_figure.png"
%
% Author: Jack Delcaro
% Tested in MATLAB 2021a
% Last revision: 01/01/2024

function savefig_nobackground(varargin)
    
    %% CHECK INPUTS
    
    % Default values
    fig = gcf;
    filename = [];
    default_extension = "svg";
    allowed_extensions = ["svg", "png", "pdf", "emf", "eps"];
    
    % Check inputs
    for i = 1:nargin
        if class(varargin{i}) == "matlab.ui.Figure"
            fig = varargin{i};
        elseif isstring(varargin{i}) || ischar(varargin{i})
            filename = string(varargin{i});
        end
    end
    
    % If no name was specified, generate an "untitled" name
    if isempty(filename)
        filename = generate_untitled_name(pwd, default_extension);
    end

    % Check if the extension is not empty and set it to default if it is
    % empty
    [~, ~, extension] = fileparts(filename);
    extension = strrep(extension, ".", "");
    if isempty(extension) || strlength(extension) == 0
        if endsWith(filename, ".")
            tmp = char(filename);
            filename = string(tmp(1:end-1));
        end
        filename = filename + "." + default_extension;
        extension = default_extension;
    end
    
    % Check if extension is valid
    if all(extension ~= allowed_extensions)
        error("Unknown figure extension! Allowed extensions: " + strjoin(allowed_extensions, ', '));
    end
        
    %% SAVE FIGURE
    
    if extension == "svg"
        fig.Color = 'none';
        fig.InvertHardcopy = 'off';
        saveas(fig, filename);
        fig.InvertHardcopy = 'on';
        fig.Color = [0.94 0.94 0.94];
    elseif extension == "pdf" || extension == "eps" || extension == "emf"
        exportgraphics(fig, filename,...
            'ContentType','vector',...
            'BackgroundColor','none');
    elseif extension == "png"
        % For png it saves a temporary svg figure and then uses inkscape to
        % convert it to png. This allows us to have a transparent
        % background
        [path, name, ~] = fileparts(filename);
        fig.Color = 'none';
        fig.InvertHardcopy = 'off';
        tmp_file = path + filesep + name + "___tmp.svg";
        saveas(fig, tmp_file);
        fig.InvertHardcopy = 'on';
        fig.Color = [0.94 0.94 0.94];
        try
            inkscape_format_converter(tmp_file, 300, "png");
        catch exception
            delete(tmp_file);
            error("Could not convert to png using inkscape!" + newline + "Error: " + string(exception.message));
        end        
        movefile(path + filesep + name + "___tmp.png", filename);
        delete(tmp_file);
    end
    
end

% Function used to generate an untitled name
function filename = generate_untitled_name(folder_path, extension)

    % Get a list of all files in the specified folder
    files = dir(fullfile(folder_path, "untitled*." + string(extension)));

    % Count the number of existing untitled files
    numFiles = numel(files);

    % Generate the new filename based on the count
    if numFiles == 0
        filename = "untitled." + string(extension);
    else
        filename = sprintf("untitled%d." + string(extension), numFiles - 1);
    end
end
    