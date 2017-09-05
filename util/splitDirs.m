function dirs = splitDirs(path)
%SPLITDIRS  Splits a path into a cell array of folders
%
%   DIRS = SPLITDIRS(PATH) splits the path specified by PATH into a cell
%   array of folder names.  If PATH points to a file, its filename will not
%   be included in DIRS.

%   Created by John Barrett 2017-09-05 14:47 CDT
%   Last modified by John Barrett 2017-09-05 14:55 CDT
    if nargin > 0 && ~exist(path,'dir')
        path = fileparts(path);
    end
    
    if nargin < 1 || isempty(path)
        path = pwd;
    end

    dirs = strsplit(path,{'/' '\'});
    dirs = dirs(~cellfun(@isempty,dirs));
end