function [amplitude,width,start,number,interval] = extractWavesurferSquarePulseTrainParameters(dataFile,sweeps,channels) % TODO : unify interface between ephus and wavesurfer versions?
%EXTRACTWAVESURFERSQUAREPULSETRAINPARAMETERS  Extract square pulse train
%parameters.
%   AMPLITUDE = EXTRACTWAVESURFERSQUAREPULSETRAINPARAMETERS(DATAFILE)
%   returns the AMPLITUDE of the square pulse train presented on the first 
%   sweep of the first channel recorded in DATAFILE, which should be a
%   struct of the kind returned by ws.loadDataFile.
%   
%   [AMPLITUDE,WIDTH,START,NUMBER,INTERVAL] =
%   EXTRACTWAVESURFERSQUAREPULSETRAINPARAMETERS(...) additionally returns with
%   the WIDTH, START, NUMBER and inter-stimulus INTERVAL of the square 
%   pulse train (all scalar, all in seconds apart from NUMBER, which is
%   dimensionless).
%
%   [...] = EXTRACTWAVESURFERSQUAREPULSETRAINPARAMETERS(DATAFILE,SWEEPS)
%   returns the stimulus paramters for the sweeps specified in the array of
%   sweep indices SWEEPS.  If SWEEPS is empty or contains an NaN values,
%   only the stimulus parameters on the first sweep are returned.
%
%   [...] = EXTRACTWAVESURFERSQUAREPULSETRAINPARAMETERS(DATAFILE,SWEEPS,...
%   CHANNELS) returns the stimulus paramters on each channel specified in
%   CHANNELS, which may be an array of channel indices or a cell array of
%   channel names.  In the latter case, channel names that are not found
%   are silently ignored.

%   Written by John Barrett 2017-07-28 14:36 CDT
%   Last updated John Barrett 2017-08-15 17:41 CDT

    if ischar(dataFile)
        dataFile = ws.loadDataFile(dataFile);
    end
    
    if nargin < 2 || isempty(sweeps) || (isnumeric(sweeps) && any(isnan(sweeps(:))))
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
    
    [maps,stimulusLibrary,nMaps] = getSelectedOutputable(dataFile);
        
    for ii = 1:numel(sweeps)
        if isnumeric(sweeps)
            i = sweeps(ii); % I normally like to avoid using i as a variable but the reason for this will become apparent momentarily
        else
            i = sscanf(sweeps{ii},'sweep_%d');
        end

        map = maps{mod(i-1,nMaps)+1}; % TODO : is this right? each sweep it moves on to the next map? how does that interact with the i parameter in each stimulus?  does it increment every sweep or every run through the sequence?

        if iscell(channels)
            mapChannels = getUniqueChannelNamesInOutputable(map);
                
            % have to use strncmp instead of ismember because
            % Wavesurfer pads all the channel names to the same length
            % FOR NO GOD DAMN REASON
            channelIndices = cell2mat(cellfun(@(channel) find(strncmp(channel,mapChannels,numel(channel))),channels,'UniformOutput',false));
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

            if isfield(map,'Stimuli')
                stimulus = map.Stimuli.(sprintf('element%d',channelIndices(jj)));
            else
                % TODO : test this for multiple stimuli
                stimulus = stimulusLibrary.Stimuli.(sprintf('element%d',map.IndexOfEachStimulusInLibrary.(sprintf('element%d',1))));
            end

            if ~strncmpi(stimulus.TypeString,'SquarePulse',11)
                % TODO : fix warning
                warning('fuck you'); %Stimulus %s on channel %s during sweep %d is not a square pulse train\n',stimulus.Name,map.ChannelNames(channelIndices(jj)),ii);
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