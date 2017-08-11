function [data,sampleRate,traceNames] = concatenateWavesurferTraces(files,sweeps,channels)
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
            data = zeros([size(dataFile.(allSweeps{1}).analogScans) 0]);
            traceNames = cell(1,size(dataFile.(allSweeps{1}).analogScans,2),0);
        end
        
        for jj = 1:numel(sweepIndices)
            sweep = allSweeps{sweepIndices(jj)};
            traces = dataFile.(sweep).analogScans;
            data(:,:,end+1) = traces; %#ok<AGROW>
            traceNames(1,:,end+1) = cellfun(@(ch) sprintf('File %s %s channel %s',files{ii},strrep(sweep,'_',' '),ch),dataFile.header.Acquisition.ActiveChannelNames,'UniformOutput',false); %#ok<AGROW>
        end
    end
    
    data = permute(data,[1 3 2]); % time, sweep, channel
    
    if nargin < 3 || isempty(channels) || any(isnan(channels))
        return
    end
    
    % we have to load all the data in anyway, so probably just quicker to
    % throw them away at the end
    data = data(:,:,channels);
end