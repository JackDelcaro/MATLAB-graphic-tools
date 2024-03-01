% INKSCAPE_FORMAT_CONVERTER Converts images from one format to another using Inkscape.
%
%   inkscape_format_converter(input_file, output_dpi, output_extension)
%
%   INPUTS:
%   - input_file: Path to the input image file.
%   - output_dpi: Desired dots per inch for the output image.
%   - output_extension: Desired output format for the image.
%
%   OUTPUT:
%   The converted image will be saved with the specified output extension in the
%   same directory as the input file.
%
%   EXAMPLE:
%   input_file = 'path/to/input/image.svg';
%   output_dpi = 300;
%   output_extension = 'png';
%   inkscape_format_converter(input_file, output_dpi, output_extension);
%
%   NOTES:
%   - Ensure that Inkscape is properly installed on your system and its executable is in the system's PATH.
%   - Supported input extensions: SVG, PDF, EPS, EMF, WMF.
%   - Supported output extensions: SVG, PDF, EPS, PNG.
%
% Author: Jack Delcaro
% Tested in MATLAB 2021a
% Last revision: 01/01/2024

function inkscape_format_converter(input_file, output_dpi, output_extension)
    
    % Check if inkscape is installed
    [~,program_x86] = system('echo %programfiles(x86)%');
    [~,program_x64] = system('echo %programfiles%');
    
    try_path(1) = string(sprintf('%s\\Inkscape\\inkscape.exe',program_x64(1:end-1)));
    try_path(2) = string(sprintf('%s\\Inkscape\\inkscape.exe',program_x86(1:end-1)));
    try_path(3) = string(sprintf('%s\\Inkscape\\bin\\inkscape.exe',program_x64(1:end-1)));
    try_path(4) = string(sprintf('%s\\Inkscape\\bin\\inkscape.exe',program_x86(1:end-1)));
    for i = 1:length(try_path)
        if exist(try_path(i), 'file')
            inkscape_path = try_path(i);
        end
    end
    if ~exist('inkscape_path', 'var')
        error('Inkscape not found in its default locations.')
    end
    
    % Check that input file exists and has an extension
    input_file = string(input_file);
    [~, ~, ext] = fileparts(input_file);
    ext = strrep(ext, ".", "");
    if isempty(ext) || strlength(ext) == 0
        error('Input file extension must be specified!');
    end        
    
    if ~isfile(input_file)
        error('Input file does not exist!');
    end
    
    % Check that input extension is supported
    if ~isempty(which(input_file))        
        input_file = string(fullfile(which(input_file)));
    else
        input_file = string(fullfile(input_file));
    end
    [filepath, name, ext] = fileparts(input_file);
    ext = strrep(ext, ".", "");
    allowed_input_extensions = ["svg", "pdf", "eps", "emf", "wmf"];
    if all(ext ~= allowed_input_extensions)
        error("Invalid input extension. Allowed extensions: " + strjoin(allowed_input_extensions, ', '));
    end
    
    % Check that output extension is supported
    allowed_output_extensions = ["svg", "pdf", "eps", "png"];
    if all(output_extension ~= allowed_output_extensions)
        error("Invalid input extension. Allowed extensions: " + strjoin(allowed_output_extensions, ', '));
    end

    output_filename = string(filepath) + filesep + string(name) + "." + string(output_extension);
    
    % Execute inkscape
    [~,~] = system(sprintf('"%s" --export-filename="%s" --export-dpi=%d "%s"', inkscape_path, output_filename, output_dpi, input_file));
    
end