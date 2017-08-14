function [peaks,peakIndices,pairedPulseRatio] = findPeaks(traces,sampleRate,isMaxPeak,varargin)
    parser = inputParser;
    
    addParameter(parser,'Start',0,@(x) isnumeric(x) && isscalar(x) && isreal(x) && isfinite(x) && x >= 0 && x <= size(traces,1)/sampleRate);
    
    % TODO : add TimeBefore and TimeAfter as well?
    isRealFinitePositiveScalarInteger = @(x) validateattributes(x,{'numeric'},{'real' 'finite' 'positive' 'scalar' 'integer'});
    addParameter(parser,'PointsBefore',5,isRealFinitePositiveScalarInteger);
    addParameter(parser,'PointsAfter',5,isRealFinitePositiveScalarInteger);
    parser.parse(varargin{:});

    if isMaxPeak
        extremeFun = @max;
    else
        extremeFun = @min;
    end
    
    startIndex = max(1,round(parser.Results.Start*sampleRate));
    
    [~,peakIndices] = extremeFun(traces(startIndex:end,:));
    peakIndices = peakIndices + startIndex - 1;
    
    peaks = arrayfun(@(idx) median(traces(max(1,idx-parser.Results.PointsBefore):min(size(traces,1),idx+parser.Results.PointsBefore))),peakIndices);
    
    pairedPulseRatio = abs(peaks/peaks(1));
end