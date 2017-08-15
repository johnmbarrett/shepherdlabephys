function [data,sampleRate,traceNames] = concatenateTraces(files,varargin)
%CONCATENATETRACES  Concatenate traces from .xsg or WaveSurfer files
%   DATA = CONCATENATETRACES(FILES) extracts and concatenates traces from
%   the .xsg or WaveSurfer files specified in the cell array of strings
%   FILES.  The traces are returned as an NxMxP matrix DATA, where N is the
%   length of the longest trace, M is the number of traces extracted, and P
%   is the number of channels (currently fixed at 1 for .xsg files).
%
%   [DATA,SAMPLERATE] = CONCATENATETRACES(FILES) also returns the rate at 
%   which the data was sampled in Hz.
%
%   [DATA,SAMPLERATE,TRACENAMES] = CONCATENATETRACES(FILES) also
%   returns a 1xMxP cell array containing a human-readable name for each
%   trace.
%
%   [...] = CONCATENATETRACES(FILES,SWEEPS,CHANNELS) only returns data from
%   the sweeps specified in SWEEPS and the channels specified in CHANNELS.
%   These options are ignored for Ephus files at present.  See
%   documentation for CONCATENATEWAVESURFERTRACES for how to use these
%   options.

%   Written by John Barrett 2017-08-09 17:39 CDT
%   Last updated John Barrett 2017-08-15 18:01 CDT
    switch getDataFormat(files{1}) % TODO : files as dir struct
        case 'xsg'
            [data,sampleRate,traceNames] = concatenateEphusTraces(files,varargin{:});
        case 'wavesurfer'
            [data,sampleRate,traceNames] = concatenateWavesurferTraces(files,varargin{:});
        otherwise
            error('ShepherdLab:concatenateTraces:UnknownFileFormat','Unknown file format for file %s\n',files{1});
    end
end