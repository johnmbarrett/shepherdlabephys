function dir = dirAbove(dirs,nAbove)
%DIRABOVE   Return path to folder above
%
%   DIR = DIRABOVE returns the path to the folder above the current working
%   directory.
%
%   DIR = DIRABOVE(PATH) returns the path to the folder above the file or
%   folder specified by PATH.
%
%   DIR = DIRABOVE(PATH,N) returns the path to the folder N above the
%   file or folder specified by PATH.  If PATH is empty or an unqualified
%   file name, the results is the folder N above the current working
%   directory.

%   Created by John Barrett 2017-09-05 14:55 CDT
%   Last modified by John Barrett 2017-09-05 14:55 CDT
    if nargin < 1
        dirs = pwd;
    end

    if nargin < 2
        nAbove = 1;
    end
    
    if ischar(dirs)
        dirs = splitDirs(dirs);
    end
    
    if ispc
        joiner = '\';
    else
        joiner = '/';
    end
    
    dir = strjoin(dirs(1:end-nAbove),joiner);
end