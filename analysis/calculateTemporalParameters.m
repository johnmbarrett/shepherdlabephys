function [peaks,peakIndices,latencies,riseTimes,fallTimes,halfWidths,peak10IndexRising,peak90IndexRising,peak90IndexFalling,peak10IndexFalling,peak50IndexRising,peak50IndexFalling,fallIntercept] = calculateTemporalParameters(traces,sampleRate,varargin)
    parser = inputParser;
    
    if verLessThan('matlab','2013b')
        addParameter = @(varargin) addParamValue(varargin{:});
    end
    
    isRealFinitePositiveNumericScalar = @(x) validateattributes(x,{'numeric'},{'real' 'finite' 'nonnegative' 'scalar'});
    addParameter(parser,'Start',0,isRealFinitePositiveNumericScalar);
    addParameter(parser,'Window',size(traces,1)/sampleRate,isRealFinitePositiveNumericScalar);
    parser.parse(varargin{:});
    
    startIndex = max(1,parser.Results.Start*sampleRate);
    endIndex = min(size(traces,1),startIndex+parser.Results.Window*sampleRate);
    
    time = (1:size(traces,1))'/sampleRate;
    
    baselineTime = time(1:max(1,startIndex-1),:,:);
    baselineTraces = traces(1:max(1,startIndex-1),:,:);
    
    time = time(startIndex:endIndex);
    traces = traces(startIndex:endIndex,:,:);

    [peaks,peakIndices] = peak(traces);
    
    if traces(peakIndices) < 0
        compareRising = @lt;
        compareFalling = @gt;
    else
        compareRising = @gt;
        compareFalling = @lt;
    end 
    
    % TODO : this function returns A LOT.  Is there a better way?
    latencies = zeros(size(peaks));
    riseTimes = zeros(size(peaks));
    fallTimes = zeros(size(peaks));
    halfWidths = zeros(size(peaks));
    peak10IndexRising = zeros(size(peaks));
    peak90IndexRising = zeros(size(peaks));
    peak90IndexFalling = zeros(size(peaks));
    peak10IndexFalling = zeros(size(peaks));
    peak50IndexRising = zeros(size(peaks));
    peak50IndexFalling = zeros(size(peaks));
    
    % TODO : this is a bit of a kludge
    function a = defaultIfEmpty(a,b)
        if ~isempty(b)
            a = b;
        end
    end
    
    % TODO : this method is VERY repetitive and could probably be
    % refactored into even smaller methods
    sizeTraces = size(traces);
    for ii = 1:prod(sizeTraces(2:end))
        baseline = polyfit(baselineTime,baselineTraces(:,ii),1);
        
        peak10 = 0.1*(peaks(ii)-baseline(2))+baseline(2);
        peak90 = 0.9*(peaks(ii)-baseline(2))+baseline(2);

        peak10IndexRising(ii) = defaultIfEmpty(1,find(compareRising(traces(:,ii),peak10),1,'first'));
        peak90IndexRising(ii) = defaultIfEmpty(1,find(compareRising(traces(peak10IndexRising(ii):end,ii),peak90),1,'first'))+peak10IndexRising(ii)-1;
        
        riseLine = polyfit((peak10IndexRising(ii):peak90IndexRising(ii))',traces(peak10IndexRising(ii):peak90IndexRising(ii),ii),1);

        riseIntercept = (riseLine(2)-baseline(2))/(-riseLine(1));

        latencies(ii) = riseIntercept/sampleRate; % latency in ms
        
        riseTimes(ii) = (peakIndices(ii)-riseIntercept)/sampleRate;

        peak90IndexFalling(ii) = defaultIfEmpty(1,find(compareFalling(traces(peakIndices(ii):end,ii),peak90),1,'first'))+peakIndices(ii)-1;
        peak10IndexFalling(ii) = defaultIfEmpty(1,find(compareFalling(traces(peak90IndexFalling(ii):end,ii),peak10),1,'first'))+peak90IndexFalling(ii)-1;
        
        fallLine = polyfit((peak90IndexFalling(ii):peak10IndexFalling(ii))',traces(peak90IndexFalling(ii):peak10IndexFalling(ii),ii),1);

        fallIntercept = (fallLine(2)-baseline(2))/(-fallLine(1));

        fallTimes(ii) = (fallIntercept-peakIndices(ii))/sampleRate;
        
        peak50 = 0.5*peaks(ii);
        
        peak50IndexRising(ii) = defaultIfEmpty(1,find(compareRising(traces(:,ii),peak50),1,'first'));
        peak50IndexFalling(ii) = defaultIfEmpty(1,find(compareFalling(traces(peak50IndexRising(ii):end,ii),peak50),1,'first')-1+peak50IndexRising(ii));
        halfWidths(ii) = (peak50IndexFalling(ii)-peak50IndexRising(ii))/sampleRate;
    end
    
    offset = startIndex-1;
    
    peakIndices = peakIndices + offset;
    peak10IndexRising = peak10IndexRising + offset;
    peak90IndexRising = peak90IndexRising + offset;
    peak90IndexFalling = peak90IndexFalling + offset;
    peak10IndexFalling = peak10IndexFalling + offset;
    peak50IndexRising = peak50IndexRising + offset;
    peak50IndexFalling = peak50IndexFalling + offset;
end