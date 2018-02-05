function [data,sampleRate,traceNames,isEmpty] = concatenateWavesurferTraces(files,sweeps,channels)
%CONCATENATEWAVESURFERTRACES    Concatenate traces from WaveSurfer files
%   DATA = CONCATENATEWAVESURFERTRACES(FILES) extracts every trace from
%   every channel in the WaveSurfer-exported HDF5 files specified by the
%   cell array of filename strings FILES and concatenates them into an 
%   NxMxP matrix DATA, where N is the length of each trace, M is the total
%   number of sweeps, and P is the number of channels.  FILES must be a
%   cell array of strings containing the path to each file.
%
%   [DATA,SAMPLERATE] = CONCATENATEWAVESURFERTRACES(FILES) also returns the
%   rate at which the data was sampled in Hz.
%
%   [DATA,SAMPLERATE,TRACENAMES] = CONCATENATEWAVESURFERTRACES(FILES) also
%   returns a 1xMxP cell array containing a human-readable name for each
%   trace, including the name of the file each trace was extracted from,
%   the sweep number, and he channel.
%
%   [DATA,SAMPLERATE,TRACENAMES,ISEMPTY] = ...
%   CONCATENATEWAVESURFERTRACES(FILES) returns a logical array of size 
%   [1,numel(FILES)] where every element is false.  This is mostly for
%   compatibility with CONCATENATEEPHUSTRACES.
%
%   [...] = CONCATENATEWAVESURFERTRACES(FILES,SWEEPS) extracts only those
%   traces specifed in the vector of sweep numbers SWEEPS.  Any sweep
%   numbers not found in any of the files are silently ignored.  If SWEEPS
%   is empty or contains any NaN values, all sweeps in all files are
%   returned.
%
%   [...] = CONCATENATEWAVESURFERTRACES(FILES,SWEEPS,CHANNELS) extracts the
%   sweeps specifed in SWEEPS from the channels specified in CHANNELS.
%   CHANNELS must be a vector of integers in the range [1,P].  If CHANNELS
%   is empty or contains any NaN values, all channels are included.

%   Written by John Barrett 2017-07-28 12:11 CDT
%   Last updated John Barrett 2017-08-15 17:34 CDT
    if ischar(files)
        files = {files};
    end

    if nargin < 2
        sweeps = [];
    end
    
    for ii = 1:numel(files)
        dataFile = loadDataFile(files{ii});
        
        fields = fieldnames(dataFile);
        
        allSweeps = fields(strncmpi('sweep_',fields,6));
        
        sweepNumbers = str2double(cellfun(@(s) s(7:end),allSweeps,'UniformOutput',false));
        
        if isempty(sweeps) || any(isnan(sweeps))
            sweepIndices = 1:numel(sweepNumbers);
        else
            sweepIndices = find(ismember(sweepNumbers,sweeps));
        end
        
        if ii == 1
            sampleRate = getSampleRate(dataFile);
            data = nan([size(dataFile.(allSweeps{1}).analogScans) 0]);
            traceNames = cell(1,size(dataFile.(allSweeps{1}).analogScans,2),0);
        end
        
        for jj = 1:numel(sweepIndices)
            sweep = allSweeps{sweepIndices(jj)};
            traces = dataFile.(sweep).analogScans;
            
            traceLength = size(traces,1);
            dataLength = size(data,1);
            
            if traceLength > dataLength
                data(end+(1:(traceLength-dataLength)),:,:) = NaN;
            end
            
            if traceLength < dataLength
                traces(end+(1:(dataLength-traceLength)),:) = NaN;
            end
            
            data(:,:,end+1) = traces; %#ok<AGROW>
            traceNames(1,:,end+1) = cellfun(@(ch) sprintf('File %s %s channel %s',files{ii},strrep(sweep,'_',' '),ch),dataFile.header.Acquisition.ActiveChannelNames,'UniformOutput',false); %#ok<AGROW>
        end
    end
    
    data = permute(data,[1 3 2]); % time, sweep, channel
    traceNames = permute(traceNames,[1 3 2]);
    
    if nargout > 3
        isEmpty = false(1,numel(files)); % TODO : can WaveSurfer files ever be empty?
    end
    
    if nargin < 3 || isempty(channels) || any(isnan(channels))
        return
    end
    
    % we have to load all the data in anyway, so probably just quicker to
    % throw them away at the end
    data = data(:,:,channels);
    traceNames = traceNames(:,:,channels);
end