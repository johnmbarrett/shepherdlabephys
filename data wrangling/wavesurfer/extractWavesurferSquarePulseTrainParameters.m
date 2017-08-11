function [amplitude,width,start,number,interval] = extractWavesurferSquarePulseTrainParameters(dataFile,sweeps,channels)
    stimulusLibrary = dataFile.header.Stimulation.StimulusLibrary;
    
    if nargin < 2 || isempty(sweeps) || any(isnan(sweeps(:)))
        sweeps = 1;
    end
    
    if nargin < 3
        channels = 1;
    elseif ischar(channels)
        channels = {channels};
    end
    
    nSweeps = numel(sweeps);
    nChannels = numel(channels);
    
    amplitude = nan(nSweeps,nChannels);
    width = nan(nSweeps,nChannels);
    start = nan(nSweeps,nChannels);
    number = nan(nSweeps,nChannels);
    interval = nan(nSweeps,nChannels);
    
    sampleRate = dataFile.header.Acquisition.SampleRate;
    
    if isfield(stimulusLibrary,'SelectedOutputable')
        % it's a sequence!  I think
        sequence = stimulusLibrary.SelectedOutputable;
        nMaps = numel(fieldnames(sequence.Maps)); % ._.
        maps = arrayfun(@(ii) sequence.Maps.(sprintf('element%d',ii)),1:nMaps,'UniformOutput',false);
    else
        % it must be a map?
        assert(strcmp(stimulusLibrary.SelectedOutputableClassName,'ws.StimulusMap'),'ShepherdLab:extractWavesurferSquarePulseTrainParameters:UnknownOutputable','Unknown Outputable class: %s\n',stimulusLibrary.SelectedOutputableClassName);
        maps = {stimulusLibrary.Maps.(sprintf('element%d',stimulusLibrary.SelectedOutputableIndex))};
        nMaps = 1;
    end
        
    for ii = 1:numel(sweeps)
        i = sweeps(ii); % I normally like to avoid using i as a variable but the reason for this will become apparent momentarily

        map = maps{mod(i-1,nMaps)+1}; % TODO : is this right? each sweep it moves on to the next map? how does that interact with the i parameter in each stimulus?  does it increment every sweep or every run through the sequence?

        if iscell(channels)
            % have to use strncmp instead of ismember because
            % Wavesurfer pads all the channel names to the same length
            % FOR NO GOD DAMN REASON
            channelIndices = cell2mat(cellfun(@(channel) find(strncmp(channel,map.ChannelNames,numel(channel))),channels,'UniformOutput',false));
        else
            channelIndices = channels;
        end

        t = (1/sampleRate):(1/sampleRate):map.Duration; %#ok<NASGU> % TODO : start from 0 or 1/sr?

        for jj = 1:numel(channelIndices)
            if iscell(channels)
                % in case not all named channels are found in all maps
                columnIndex = find(cellfun(@(channel) strncmp(channel,map.ChannelNames(channelIndices(jj)),numel(channel)),channels));
            else
                columnIndex = jj;
            end

            stimulus = map.Stimuli.(sprintf('element%d',channelIndices(jj)));

            if ~strncmpi(stimulus.TypeString,'SquarePulse',11)
                warning('Stimulus %s on channel %s during sweep %d is not a square pulse train\n',stimulus.Name,map.ChannelNames(channelIndices(jj)),ii);
            end

            % TODO : what if one of these evaluates to a non-scalar?
            amplitude(ii,jj) = eval(stimulus.Amplitude);
            start(ii,jj) = eval(stimulus.Delay);

            if ~strcmp(stimulus.TypeString,'SquarePulseTrain')
                width(ii,jj) = eval(stimulus.Duration);

                if width(ii,jj) + start(ii,jj) > map.Duration
                    width(ii,jj) = map.Duration-start(ii,jj);
                end

                number(ii,jj) = 1;
                interval(ii,jj) = Inf;
                continue
            end

            width(ii,columnIndex) = eval(stimulus.PulseDuration);
            interval(ii,columnIndex) = eval(stimulus.Period);
            number(ii,columnIndex) = ceil(min(map.Duration,eval(stimulus.Duration))/interval(ii,columnIndex));
        end
    end
end