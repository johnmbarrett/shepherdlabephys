function [data,format] = loadDataFile(filename)
%LOADDATAFILE   Load an electrophys data file
%   DATA = LOADDATAFILE(FILENAME) loads the file DATAFILE and returns the
%   resulting struct DATA.  FILENAME is a path string pointing to an Ephus
%   or WaveSurfer data file.
%
%   [DATA,FORMAT] = LOADDATAFILE(FILENAME) additionally returns the FORMAT
%   of the file as returned by GETDATAFORMAT.

%   Written by John Barrett 2017-07-27 15:31 CDT
%   Last updated John Barrett 2017-08-15 18:09 CDT
    format = getDataFormat(filename);
    
    switch format
        case 'xsg'
            data = load(filename,'-mat');
        case 'wavesurfer'
            data = ws.loadDataFile(filename);
        otherwise
            error('ShepherdLab:loadDataFile:UnknownFormat','Unknown file format for file %s\n',filename);
    end
end