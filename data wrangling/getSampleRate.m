function sampleRate = getSampleRate(dataFile)
%GETDATAFORMAT  Get sample rate for an electrophys data file
%   SAMPLERATE = GETSAMPLERATE(DATAFILE) returns the SAMPLERATE in Hz of
%   the Ephus or WaveSurfer file DATAFILE, which may be a string specifying
%   a path name or a struct representing a previously loaded file.

%   Written by John Barrett 2017-07-27 15:34 CDT
%   Last updated John Barrett 2017-08-15 18:06 CDT
    if isstruct(dataFile)
        format = getDataFormat(dataFile);
    else
        [dataFile,format] = loadDataFile(dataFile);
    end
    
    switch format
        case 'xsg'
            sampleRate = dataFile.header.ephys.ephys.sampleRate;
        case 'wavesurfer'
            sampleRate = dataFile.header.Acquisition.SampleRate;
        otherwise
            error('ShepherdLab:getSampleRate:UnknownFormat','Unknown file format');
    end
end
        
    