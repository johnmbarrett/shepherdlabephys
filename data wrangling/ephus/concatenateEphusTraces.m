function [data,sampleRate,traceNames] = concatenateEphusTraces(files)
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