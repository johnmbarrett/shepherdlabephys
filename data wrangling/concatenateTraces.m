function [data,sampleRate,traceNames] = concatenateTraces(files,varargin)
    switch getDataFormat(files{1}) % TODO : files as dir struct
        case 'xsg'
            [data,sampleRate,traceNames] = concatenateEphusTraces(files,varargin{:});
        case 'wavesurfer'
            [data,sampleRate,traceNames] = concatenateWavesurferTraces(files,varargin{:});
        otherwise
            error('ShepherdLab:concatenateTraces:UnknownFileFormat','Unknown file format for file %s\n',files{1});
    end
end