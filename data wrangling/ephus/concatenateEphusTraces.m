function [data,sampleRate,traceNames] = concatenateEphusTraces(files)
%CONCATENATEEPHUSTRACES Concatenate traces from .xsg files
%   DATA = CONCATENATEEPHUSTRACES(FILES) extracts the first trace from each
%   xsg file in the cell array of filename strings FILES and concatenates 
%   them into an NxM matrix DATA, where N is the length of the longest 
%   trace and M equals numel(FILES).  Traces shorter than the longest trace
%   are NaN-padded.
%
%   [DATA,SAMPLERATE] = CONCATENATEEPHUSTRACES(FILES) also returns the
%   rate at which the data was sampled in Hz.
%
%   [DATA,SAMPLERATE,TRACENAMES] = CONCATENATEEPHUSTRACES(FILES) also
%   returns a 1xM cell array containing a human-readable name for each
%   trace, including the name of the file each trace was extracted from and
%   the name of the amplifier used for recording.  (Currently this function
%   only retrieves data from one ephys channel.)

%   Written by John Barrett 2017-07-27 14:14 CDT
%   Last updated John Barrett 2017-08-15 16:56 CDT
    missing = false(1,numel(files));
    traceNames = cell(1,numel(files));
    
    for ii = 1:numel(files)
        dataStruct = load(files{ii},'-mat'); % TODO : specify files as dir(...) struct
        
        if ii == 1
            sampleRate = getSampleRate(dataStruct);
        end
        
        if ~isstruct(dataStruct) || ~isfield(dataStruct,'data') || ~isstruct(dataStruct.data) || ~isfield(dataStruct.data,'ephys') || ~isstruct(dataStruct.data.ephys) || ~isfield(dataStruct.data.ephys,'trace_1')
            warning('Missing trace in file %s, ignoring...\n',files{ii});
            
            missing(ii) = true;
            
            continue
        end
        
        trace = dataStruct.data.ephys.trace_1;
        
        if ~exist('data','var')
            data = zeros(length(trace),numel(files));
            
        end
        
        if size(trace,1) < size(data,1)
            trace((end+1):size(data,1),:) = NaN;
        end
        
        if size(trace,1) > size(data,1)
            data((end+1):size(trace,1),:) = NaN;
        end
        
        data(:,ii) = trace; % TODO : multiple channels
        traceNames{ii} = sprintf('Trace %s channel %s',files{ii},dataStruct.data.ephys.amplifierName_1);
    end
    
    data(:,missing) = [];
end