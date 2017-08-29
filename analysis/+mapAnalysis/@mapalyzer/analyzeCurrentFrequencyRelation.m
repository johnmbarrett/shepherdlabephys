function analyzeCurrentFrequencyRelation(self,varargin)
%
% traces: data array in which  rows are  samples and  cols are traces.
% Isteps: vector containing amplitudes of steps.
% startVal and endVal: indices (equivalently, sample number) for the 
%    beginning and end of the analysis window (i.e., the current step).
%    Defaults are startVal = 1000, endVal = 6000.
% threshVal: threshold for event detection, in mV. Default is threshVal = 5.
% sr: sample rate. Default is sr = 10000.
% 
% Typical usage (as of July 2005)
% - For a family of current step responses, first load the traces as 
%   trace type 'general physiology traces', load method 'selected traces'.
% - In Generic Trace Analysis, browse the traces and check which ones you 
%   would like to analyze (e.g. traces 1 to 11, or whatever).
% - Send the handles variable to the workspace, using the pushbutton.
% - Define the Isteps from the command line (see above)
% - Optional: define the startVal and endVal (in samples), threshVal (in mV), 
%   and sr -- if left out, these values will default to values listed above.
%
% Example:
% (First load the traces and send 'handles' variable to the workspace.)
% startVal = 1000; endVal = 6000; threshVal = 5; sr = 10000;
% traceVector = [1:7];
% traces = handles.data.map.mapActive.bsArray(:, traceVector); figure; plot(traces);
% Isteps = (0:100:1000);
% data = currentFrequencyAnalysis(traces, Isteps, startVal, endVal, threshVal, sr);
% 
% Display:
% First plot: traces
% Middle plot:
%
% Editing:
% adapted from Leopoldo's spikeFinder
% gs june 2005 -- added calculation
% gs july 2005 -- made it more user friendly and generic
% gs july 2005 -- incorporated into mapAnalysis
% ----------------------------------------------------------------------------
    sr = self.sampleRate;
    traces = self.recordingActive.Filtered.Data(self.tracesToAnalyze,:)';
    Isteps = self.Isteps;
    startVal = self.currentStepStart;
    startInd = round(startVal * sr);
    currentStepDuration = self.currentStepDuration;
    endVal = startVal + currentStepDuration;
    endInd = round(endVal * sr);
    threshVal = self.spikeThreshold;

    numTraces = size(traces,2);

    if numTraces < size(Isteps,2)
        Isteps = Isteps(1:numTraces);
    end
    
    instRate1and2 = nan(numTraces,1);
    meanSpikeRate = zeros(numTraces,1);
    spikeAmplitude = cell(numTraces,1);
    spikeIndex = cell(numTraces,1);
    spikeTimes = cell(numTraces,1);
    
    for ii = 1:numTraces
        traceData = traces(startInd:endInd, ii);
        
        [spikeIndices,~,polarity] = findThresholdCrossings(traceData,[threshVal threshVal],'both');
        
        if isempty(spikeIndices)
            continue
        end

        spikeStart = spikeIndices(polarity == 1);
        spikeEnd = spikeIndices(polarity == -1);
        
        spikeEnd(spikeEnd < spikeStart(1)) = [];
        spikeEnd(end+(1:max(0,numel(spikeStart)-numel(spikeEnd))),1) = size(traceData,1);
        
        assert(numel(spikeStart) == numel(spikeEnd) && all(spikeStart < spikeEnd),'Every spike should have a beginning and an end and the beginning should be before the end');
        
        n = length(spikeStart);
        
        spikeAmplitude{ii} = zeros(n,1);
        spikeIndex{ii} = zeros(n,1);
        
        for jj = 1:n
            [spikeAmplitude{ii}(jj),peakIndex] = max(traceData(spikeStart(jj):spikeEnd(jj)));
            spikeIndex{ii}(jj) = peakIndex+spikeStart(jj)-1;
        end
        
        spikeTimes{ii} = spikeIndex{ii}/sr;
        
        meanSpikeRate(ii) = n/currentStepDuration;

        if n >= 2
            instRate1and2(ii) = 1/(spikeTimes{ii}(2)-spikeTimes{ii}(1));
        end
    end

    figure('Color', 'w', 'Position', [79   228   767   443]);

    ax = subplot(1,3,1);
    plotTraces(ax,traces,sr,'RecordingMode','IC','Title','Traces');

    subplot(1,3,2);
    plot(Isteps, meanSpikeRate, 'bo-');
    title('Mean spike rate');
    xlabel('Current step amplitude (pA)');
    ylabel('Mean spike rate (Hz)');

    subplot(1,3,3);
    plot(Isteps, instRate1and2, 'bo-');
    title('Initial instantaneous rate');
    xlabel('Current step amplitude (pA)');
    ylabel('Rate (Hz)');
end