function [data,sampleRate,traceNames,isEmpty,headers] = concatenateEphusTraces(files,sweeps,channels,varargin)
%CONCATENATEEPHUSTRACES Concatenate traces from .xsg files
%   DATA = CONCATENATEEPHUSTRACES(FILES) extracts all the traces from each
%   xsg file in the cell array of filename strings FILES and concatenates 
%   them into an NxM matrix DATA, where N is the length of the longest 
%   trace and M equals numel(FILES).  Traces shorter than the longest trace
%   are NaN-padded.
%
%   DATA = CONCATENATEEPHUSTRACES(FILES,SWEEPS,CHANNELS) extracts the
%   traces specified by the array of sweep indices SWEEPS from the channels
%   specified by the array of channel indices or cell array of channel
%   names CHANNELS from FILES.
%
%   [DATA,SAMPLERATE] = CONCATENATEEPHUSTRACES(...) also returns the rate
%   at which the data was sampled in Hz.
%
%   [DATA,SAMPLERATE,TRACENAMES] = CONCATENATEEPHUSTRACES(...) also
%   returns a 1xM cell array containing a human-readable name for each
%   trace, including the name of the file each trace was extracted from and
%   the name of the amplifier used for recording.  (Currently this function
%   only retrieves data from one ephys channel.)
%
%   [DATA,SAMPLERATE,TRACENAMES,ISEMPTY] = CONCATENATEEPHUSTRACES(...) also
%   returns a logical array in which each element is true if the
%   corresponding files was empty.
%
%   [DATA,SAMPLERATE,TRACENAMES,ISEMPTY,HEADERS] = ...
%   CONCATENATEEPHUSTRACES(...) also returns header structs HEADERS for
%   each file.
%
%   [...] = CONCATENATEEPHUSTRACES(...,PARAM1,VAL1,...) specifes one or
%   more of the following name-value pair options:
%
%       'DeleteEmptyFiles'  Boolean specifying whether to remove empty
%                           files from the DATA array (if true) or replace
%                           them with NaNs (if false).
%       'Program'           Specifies which program to load the data from. 
%                           Options are 'ephys' or 'acquirer'.  Default is 
%                           'acquirer'.

%   Written by John Barrett 2017-07-27 14:14 CDT
%   Last updated John Barrett 2018-02-08 15:29 CDT
    parser = inputParser();
    addParameter(parser,'DeleteEmptyFiles',false,@(x) isscalar(x) && islogical(x));
    addParameter(parser,'Program','ephys',@(x) ismember(x,{'ephys' 'acquirer'}));
    parser.parse(varargin{:});
    
    program = parser.Results.Program;
    
    if ischar(files)
        files = {files};
    end
    
    isEmpty = false(numel(files),1);

    for ii = 1:numel(files)
        if ~exist(files{ii},'file')
            warning('ShepherdLab:concatenateEphusTraces:NoFileFound','File %s not found, ignoring...\n',files{ii});
            
            continue
        end
        
        dataStruct = load(files{ii},'-mat'); % TODO : specify files as dir(...) struct
        
        if isstruct(dataStruct) && isfield(dataStruct,'header')
            headers(ii) = dataStruct.header; %#ok<AGROW>
        else
            warning('ShepherdLab:concatenateEphusTraces:NoHeaderFound','No header found in file %s, will return empty header struct for this file\n',files{ii});
        end 
        
        if ii == 1
            sampleRate = getSampleRate(dataStruct);
        end
        
        if ~isstruct(dataStruct) || ~isfield(dataStruct,'data') || ~isstruct(dataStruct.data) || ~isfield(dataStruct.data,program) || ~isstruct(dataStruct.data.(program))
            warning('ShepherdLab:concatenateEphusTraces:NoTracesFound','No traces found in file %s, ignoring...\n',files{ii});
            
            isEmpty(ii) = true;
            
            continue
        end
        
        programStruct = dataStruct.data.(program);
        
        fields = fieldnames(programStruct);
        
        traceFields = fields(strncmpi('trace_',fields,6));
        
        if isempty(traceFields)
            warning('ShepherdLab:concatenateEphusTraces:NoTracesFound','No traces found in file %s, ignoring...\n',files{ii});
            
            isEmpty(ii) = true;
            
            continue
        end
        
        nChannels = numel(traceFields);
        
        % need to check for every file because they might have different
        % sets of channels if the user is doing something really weird
        if nargin < 3 || isempty(channels) || (isnumeric(channels) && any(isnan(channels(:))))
            channels = 1:nChannels;
        elseif ischar(channels)
            channels = {channels};
        end
        
        switch program
            % TODO : is this correct?
            case 'acquirer'
                channelPrefix = 'channelName_';
            case 'ephys'
                channelPrefix = 'amplifierName_';
        end
        
        channelFields = fields(strncmpi(channelPrefix,fields,numel(channelPrefix)));
        channelNames = cellfun(@(f) programStruct.(f),channelFields,'UniformOutput',false);
        
        if iscellstr(channels)
            channelIndices = find(ismember(channelNames,channels));
            
            badChannels = channels(~ismember(channels,channelNames));
        else
            channelIndices = channels(channels > 0 & channels <= nChannels);
            
            badChannels = num2cell(setdiff(channels,channelIndices));
        end
            
        if ~isempty(badChannels)
            if iscellstr(channels)
                specifier = 'name';
                format = 's';
            else
                specifier = 'number';
                format = 'd';
            end
            
            warningStr = ['Channel with ' specifier '(s) %' format repmat([', %' format],1,numel(badChannels)-1) ' not found in file %s - NaNs will be returned for these channels\n'];

            warning('ShepherdLab:concatenateEphusTraces:ChannelNotFound',warningStr,badChannels{:},files{ii});
        end
        
        timestampFields = fields(strncmpi('dataEventTimestamps_',fields,20));
        
        for jj = 1:numel(channelIndices)
            channelIndex = channelIndices(jj);
            
            timestamps = programStruct.(timestampFields{channelIndex});
            nTimestamps = numel(timestamps);
            
            % also check these every time just in case
            if nargin < 2 || isempty(sweeps) || ~isnumeric(sweeps) || any(isnan(sweeps(:)))
                sweeps = 1:nTimestamps;
            end
            
            sweepIndices = sweeps(isreal(sweeps) & isfinite(sweeps) & sweeps == round(sweeps) & sweeps > 0 & sweeps <= nTimestamps);
            
            badSweeps = num2cell(setdiff(sweeps,sweepIndices));
            
            channelName = channelNames{channelIndex};
            
            if ~isempty(badSweeps)
                warning('ShepherdLab:concatenateEphusTraces:SweepNotFound',['Sweep numbers %d' repmat(', %d',1,numel(badSweeps)-1) ' not found for channel %s in file %s - NaNs will be returned for these channels\n'],badSweeps{:},channelName,files{ii});
            end
            
            trace = programStruct.(traceFields{channelIndex});
            
            trace = reshape(trace,[],nTimestamps);
        
            if ~exist('data','var')
                data = nan(length(trace),numel(sweeps),numel(files),numel(channels));
                traceNames = cellfun(@(~) '',cell(1,numel(sweeps),numel(files),numel(channels)),'UniformOutput',false);
            end
        
            if size(trace,1) < size(data,1)
                trace((end+1):size(data,1),:) = NaN;
            end

            if size(trace,1) > size(data,1)
                data((end+1):size(trace,1),:) = NaN;
            end
        
            colIndices = arrayfun(@(kk) find(ismember(sweeps,kk),1),sweepIndices);
            
            if iscellstr(channels)
                hyperPageIndex = find(ismember(channels,channelName));
            else
                hyperPageIndex = find(ismember(channels,channelIndex));
            end
            
            data(:,colIndices,ii,hyperPageIndex) = trace(:,sweepIndices);
            
            % assign names to every trace, even ones that don't exist
            traceNames(1,:,ii,hyperPageIndex) = arrayfun(@(kk) sprintf('File %s sweep %d channel %s',files{ii},kk,channelName),1:size(traceNames,2),'UniformOutput',false);
        end
    end
    
    if ~exist('headers','var') % every file was missing its header
        headers = repmat(struct([]),1,numel(files));
    end
    
    if ~exist('data','var')
        data = [];
        traceNames = {};
        return
    end
    
    if parser.Results.DeleteEmptyFiles
        data(:,:,isEmpty,:) = [];
        headers(isEmpty) = [];
        traceNames(:,:,isEmpty,:) = [];
    else
        data(:,:,isEmpty,:) = NaN;
    end
    
    data = reshape(data,size(data,1),size(data,2)*size(data,3),size(data,4));
    traceNames = reshape(traceNames,1,size(traceNames,2)*size(traceNames,3),size(traceNames,4));
end