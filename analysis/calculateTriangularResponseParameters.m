function [latency,riseTime,fallTime,halfWidth,peak10IndexRising,peak90IndexRising,peak90IndexFalling,peak10IndexFalling,peak50IndexRising,peak50IndexFalling,fallIntercept] = calculateTriangularResponseParameters(trace,peakIndex,sampleRate,baseline)
%CALCULATETRIANGULARRESPONSEPARAMETERS    Calculate response parameters for
%a response with a roughly triangular shepe
%   [LATENCY,RISETIME,FALLTIME,HALFWIDTH,PEAK10INDEXRISING,...
%   PEAK90INDEXRISING,PEAK90INDEXFALLING,PEAK10INDEXFALLING,...
%   PEAK50INDEXRISING,PEAK50INDEXFALLING,FALLINTERCEPT] = ...
%   CALCULATETRIANGULARRESPONSEPARAMETERS(TRACE,PEAKINDEX,SAMPLERATE) 
%   calculates various temporal parameters of a response to a stimulus from
%   the electrophysiological data contained in the timeseries vector TRACE,
%   which is sampled at SAMPLERATE Hz and has a previously-identified peak 
%   at PEAKINDEX.  Each returned value is a scalar representing the 
%   following:
%
%       LATENCY             The time of response onset.  This is calculated
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
%   [...] = CALCULATETEMPORALPARAMETERS(...,BASELINE) calculates the above
%   with respect to a user-specified BASELINE, which may be a scalar (for a
%   flat baseline) or a two-element vector (for a baseline that varies 
%   linearly over time).

%   Written by John Barrett 2019-03-15 16:25 CDT
%   Last updated John Barrett 2019-03-15 16:25 CDT
    
    if ~isnan(trace(peakIndex)) && trace(peakIndex) < 0 % TODO : do we every want different polarities on different sweeps
        compareRising = @lt;
        compareFalling = @gt;
    else
        compareRising = @gt;
        compareFalling = @lt;
    end 
    
    % TODO : this is a bit of a kludge
    function a = defaultIfEmpty(a,b)
        if ~isempty(b)
            a = b;
        end
    end

    % TODO : full arg checking
    if nargin < 4
        baseline = [0 0];
    elseif isscalar(baseline)
        baseline = [0 baseline];
    else
        assert(numel(baseline) == 2,'shepherdlabephys:calculateTriangularResponseParameters:InvalidBaseline','Baseline must be a scalar or a two-element vector representing an order 1 polynomial.');
    end

    peak10 = 0.1*(trace(peakIndex)-baseline(2))+baseline(2);
    peak90 = 0.9*(trace(peakIndex)-baseline(2))+baseline(2);

    peak10IndexRising = defaultIfEmpty(1,find(compareRising(trace,peak10),1,'first'));
    peak90IndexRising = defaultIfEmpty(1,find(compareRising(trace(peak10IndexRising:end),peak90),1,'first'))+peak10IndexRising-1;

    riseLine = polyfit([peak10IndexRising;peak90IndexRising],trace([peak10IndexRising;peak90IndexRising]),1);

    riseIntercept = (riseLine(2)-baseline(2))/(-riseLine(1));

    latency = riseIntercept/sampleRate; % latency in ms

    riseTime = (peakIndex-riseIntercept)/sampleRate;

    peak90IndexFalling = defaultIfEmpty(1,find(compareFalling(trace(peakIndex:end),peak90),1,'first'))+peakIndex-1;
    peak10IndexFalling = defaultIfEmpty(1,find(compareFalling(trace(peak90IndexFalling:end),peak10),1,'first'))+peak90IndexFalling-1;

    fallLine = polyfit([peak90IndexFalling;peak10IndexFalling],trace([peak90IndexFalling;peak10IndexFalling]),1);

    fallIntercept = (fallLine(2)-baseline(2))/(-fallLine(1));

    fallTime = (fallIntercept-peakIndex)/sampleRate;

    peak50 = 0.5*trace(peakIndex);

    peak50IndexRising = defaultIfEmpty(1,find(compareRising(trace,peak50),1,'first'));
    peak50IndexFalling = defaultIfEmpty(1,find(compareFalling(trace(peakIndex:end),peak50),1,'first')-1+peakIndex);
    halfWidth = (peak50IndexFalling-peak50IndexRising)/sampleRate;
end