function names = selectFilesFromList(path, type)
% SELECTFILESFROMLIST   Select files from a folder
%
%   NAMES = SELECTFILESFROMLIST(PATH) allows the user to select from the
%   files located in PATH and returns to chosen file names.
%
%   NAMES = SELECTFILESFROMLIST(PATH,TYPE) restricts the selection to files
%   with the extension TYPE.

% Created by John Barrett 2017-08-18 11:44 CDT
% Last Modified by John Barrett 2017-08-18 11:44 CDT
% Based on code written by Gordon Shepherd April 2005
% -------------------------------------------------
    if nargin < 1
        path = pwd;
    end
    
    if nargin < 2
        type = '.tif';
    end

    d = dir(fullfile(path, ['/*' type]));
    
    if isempty(d)
        warning('ShepherdLab:mapalyzer:selectFilesFromList','No files with extension %s found in %s\n',type,path);
        names = {};
        return
    end
    
    str = sortrows({d.name}');

    s = listdlg('PromptString','Select a file:', 'OKString', 'OK',...
        'SelectionMode','multiple',...
        'ListString', str, 'Name', 'Select a File');
    
    names = str(s);
end