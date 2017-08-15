function format = getDataFormat(file)
%GETDATAFORMAT  Get format of data file
%   FORMAT = GETDATAFORMAT(FILE) determines the format of the data file
%   FILE, which may be a string specifying the path to an Ephus or
%   Wavesurfer file, or a struct created by loading such a file.  The
%   returned FORMAT is the string 'xsg' for Ephus .xsg files, 'wavesurfer'
%   for WaveSurfer-exported HDF5 files, or 'unknown' if the file format can
%   not be determined.

%   Written by John Barrett 2017-07-27 14:36 CDT
%   Last updated John Barrett 2017-08-15 18:04 CDT
    if ischar(file)
        [~,~,extension] = fileparts(file);
        
        switch extension
            case '.xsg'
                format = 'xsg';
            case '.h5';
                format = 'wavesurfer';
            otherwise
                format = 'unknown';
        end
        
        return
    end
    
    if isstruct(file)
        if isfield(file,'header')
            header = file.header;
            
            if isfield(header,'xsg')
                format = 'xsg';
                return
            end
            
            if isfield(header,'Acquisition')
                format = 'wavesurfer';
                return
            end
            
            format = 'unknown';
            
            return
        end
        
        format = 'unknown';
        
        return
    end
    
    format = 'unknown';
end