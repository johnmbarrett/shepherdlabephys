function [peaks,peakIndices,latencies,riseTimes,fallTimes,halfWidths,peak10IndexRising,peak90IndexRising,peak90IndexFalling,peak10IndexFalling,peak50IndexRising,peak50IndexFalling,fallIntercept] = calculateTemporalParameters(traces,sampleRate,varargin)
%CALCULATETEMPORALPARAMETERS    Calculate temporal parameters
%   [PEAKS,PEAKINDICES,LATENCIES,RISETIMES,FALLTIMES,HALFWIDTHS,...
%   PEAK10INDEXRISING,PEAK90INDEXRISING,PEAK90INDEXFALLING,...
%   PEAK10INDEXFALLING,PEAK50INDEXRISING,PEAK50INDEXFALLING, ...
%   FALLINTERCEPT] = CALCULATETEMPORALPARAMETERS(TRACES,SAMPLERATE)
%   calculates various temporal parameters of a response to a stimulus from
%   the electrophysiological data contained in TRACES, which is a matrix
%   where each column represents a recording of the response to one
%   stimulus, sampled at SAMPLERATE Hz.  Each returned value is a row 
%   vector (one element per column of TRACES) containing the following:
%
%       PEAKS               The amplitude of the response at the largest
%                           absolute deflection from baseline.
%       PEAKINDICES         The index of the sample containing the peak 
%                           response.
%       LATENCIES           The time of response onset.  This is calculated
%                           by finding when then reponse crosses 10% and
%                           90% of peak deviation from baseline, drawing a
%                           line through those points, and finding where
%                           that line intercepts the baseline.
%       RISETIMES           The time taken for the response to rise from
%                           10% to 90% of the peak deviation from baseline.
%       FALLTIMES           The time taken for the response to fall from
%                           90% to 10% of the peak deviation from baseline.
%       HALFWIDTHS          The full width at half maximum of the response,
%                           i.e. the time taken for the response to rise
%                           above 50% of the peak deviation from baseline,
%                           reach its peak, then fall back below this
%                           value.
%       PEAK10INDEXRISING   The index of the first sample greater than 10%
%                           of the peak deviation from baseline.
%       PEAK90INDEXRISING   The index of the first sample after 
%                           PEAK10INDEXRISING greater than 90% of the peak 
%                           deviation from baseline.
%       PEAK90INDEXFALLING  The index of the first sample after PEAKINDICES
%                           less than 90% of the peak deviation from
%                           baseline.
%       PEAK10INDEXFALLING  The index of the first sample after 
%                           PEAK90INDEXFALLING less than 10% of the peak 
%                           deviation from baseline.
%       PEAK50INDEXRISING   The index of the first sample greater than 50%
%                           of the peak deviation from baseline.
%       PEAK50INDEXFALLING  The index of the first sample after PEAKINDICES
%                           less than 50% of the peak deviation from
%                           baseline.
%       FALLINTERCEPT       The index at which a line passing through
%                           PEAK90INDEXFALLING and PEAK10INDEXFALLING
%                           crosses the baseline.
%
%   The above descriptions assume the peak is greater than the baseline.
%   For the case where the peak is below the baseline, swap 'greater than'
%   and 'less than' in the above.
%
%   [...] = CALCULATETEMPORALPARAMETERS(...,PARAM1,VAL1,PARAM2,VAL2,...) 
%   specifies one or more of the following name/value pairs, as well as the
%   standard options for specifying response and baseline windows (see
%   GETBASELINEANDRESPONSEWINDOWS):
%
%      'ResultsAsTime'  Logical scalar specifying whether to return the
%                       results as times in seconds from the beginning of 
%                       response window (true) or indices into the traces
%                       array (false). LATENCIES, RISETIMES, FALLTIMES, and
%                       HALFWIDTHS are always returned in seconds and
%                       regardless of the value of this parameter. Default
%                       is true.

%   Written by John Barrett 2017-07-27 19:01 CDT
%   Last updated John Barrett 2017-08-15 15:44 CDT
    [responseStartIndex,responseEndIndex,baselineStartIndex,baselineEndIndex] = getBaselineAndResponseWindows(traces,sampleRate,varargin{:});
    
    parser = inputParser;
    parser.KeepUnmatched = true;
    addParameter(parser,'ResultsAsTime',false,@(x) isscalar(x) && islogical(x));
    parser.parse(varargin{:});
    
    time = (1:size(traces,1))'/sampleRate;
    
    colons = repmat({':'},1,ndims(traces)-1);
    
    baselineTime = time(baselineStartIndex:baselineEndIndex,colons{:});
    baselineTraces = traces(baselineStartIndex:baselineEndIndex,colons{:});
    
    traces = traces(responseStartIndex:responseEndIndex,colons{:});

    [peaks,peakIndices] = peak(traces);
    
    peaks(std(traces) == 0) = NaN;
    peakIndices(std(traces) == 0) = NaN;
    
    if ~all(isnan(peaks(:))) && traces(find(~isnan(peakIndices),1)) < 0 % TODO : do we every want different polarities on different sweeps
        compareRising = @lt;
        compareFalling = @gt;
    else
        compareRising = @gt;
        compareFalling = @lt;
    end 
    
    % TODO : this function returns A LOT.  Is there a better way?
    latencies = nan(size(peaks));
    riseTimes = nan(size(peaks));
    fallTimes = nan(size(peaks));
    halfWidths = nan(size(peaks));
    peak10IndexRising = nan(size(peaks));
    peak90IndexRising = nan(size(peaks));
    peak90IndexFalling = nan(size(peaks));
    peak10IndexFalling = nan(size(peaks));
    peak50IndexRising = nan(size(peaks));
    peak50IndexFalling = nan(size(peaks));
    fallIntercept = nan(size(peaks));
    
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
        if isnan(peaks(ii))
            continue
        end
        
        if size(baselineTraces,1) <= 1
            baseline = [0 0];
        else
            baseline = polyfit(baselineTime,baselineTraces(:,ii),1);
        end
        
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

        fallIntercept(ii) = (fallLine(2)-baseline(2))/(-fallLine(1));

        fallTimes(ii) = (fallIntercept(ii)-peakIndices(ii))/sampleRate;
        
        peak50 = 0.5*peaks(ii);
        
        peak50IndexRising(ii) = defaultIfEmpty(1,find(compareRising(traces(:,ii),peak50),1,'first'));
        peak50IndexFalling(ii) = defaultIfEmpty(1,find(compareFalling(traces(peakIndices(ii):end,ii),peak50),1,'first')-1+peakIndices(ii));
        halfWidths(ii) = (peak50IndexFalling(ii)-peak50IndexRising(ii))/sampleRate;
    end
    
    if parser.Results.ResultsAsTime
        peakIndices = peakIndices/sampleRate;
        peak10IndexRising = peak10IndexRising/sampleRate;
        peak90IndexRising = peak90IndexRising/sampleRate;
        peak90IndexFalling = peak90IndexFalling/sampleRate;
        peak10IndexFalling = peak10IndexFalling/sampleRate;
        peak50IndexRising = peak50IndexRising/sampleRate;
        peak50IndexFalling = peak50IndexFalling/sampleRate;
        fallIntercept = fallIntercept/sampleRate;
    else
        offset = responseStartIndex-1;

        peakIndices = peakIndices + offset;
        peak10IndexRising = peak10IndexRising + offset;
        peak90IndexRising = peak90IndexRising + offset;
        peak90IndexFalling = peak90IndexFalling + offset;
        peak10IndexFalling = peak10IndexFalling + offset;
        peak50IndexRising = peak50IndexRising + offset;
        peak50IndexFalling = peak50IndexFalling + offset;
        fallIntercept = fallIntercept + offset;
    end
end