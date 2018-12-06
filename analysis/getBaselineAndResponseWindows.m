function [responseStartIndex,responseEndIndex,baselineStartIndex,baselineEndIndex] = getBaselineAndResponseWindows(traces,sampleRate,varargin)
%GETBASELINEANDRESPONSEWINDOWS Get indices of baseline and response windows
%
%   [RSI,REI,BSI,BEI] = GETBASELINEANDRESPONSEWINDOWS(TRACES,SAMPLERATE,...
%   PARAM1,VALUE1...) returns indices [RSI,REI] where the response window
%   is located along the first dimension of TRACES (sampled at SAMPLERATE
%   Hz) and [BSI,BEI] where the baseline window is located. If no
%   parameters are passed, RSI = 1, REI = size(traces,1), BSI = 1, and BEI
%   = 0. More usually, you'd specify one or both windows using some
%   combination of the following options (all possible combinations should
%   be valid, but may not do what you expect---in particular, the 'Start'
%   and 'Window' parameters are an older syntax kept in for backwards
%   compatibility and may be removed in a future release. If a response
%   window is specified by not a baseline, the baseline is assumed to run
%   from the beginning of the trace until one sample before the response
%   window. Likewise, if a baseline is specified but not a response window,
%   the response window is assumed to start after the baseline and run
%   until the end of the trace.
%
%      'BaselineStartIndex' Index specifying the start of the baseline
%                           window.
%      'BaselineEndIndex'	Index specifying the end of the baseline
%                           window.
%      'BaselineStartTime'	Scalar specifying the start of the baseline
%                           window in seconds from the beginning of the
%                           trace.
%      'BaselineLength'     Scalar specifying the length of the response
%                           window in seconds.
%      'ResponseStartIndex' Index specifying the start of the response
%                           window.
%      'ResponseEndIndex'	Index specifying the end of the response
%                           window.
%      'ResponseStartTime'	Scalar specifying the start of the response
%                           window in seconds from the beginning of the
%                           trace.
%      'ResponseLength'     Scalar specifying the length of the baseline
%                           window in seconds.
%      'Start'              Equivalent to 'ResponseStartTime'
%      'Window'             Equivalent to 'ResponseLength'

    parser = inputParser;
    parser.KeepUnmatched = true;
    
    isValidTime = @(x) isnumeric(x) && isscalar(x) && isreal(x) && isfinite(x) && x >= 0 && x <= size(traces,1)/sampleRate;
    addParameter(parser,'Start',NaN,isValidTime);
    addParameter(parser,'Window',NaN,isValidTime);
    parser.parse(varargin{:});
    
    if ~any(ismember({'Start' 'Window'},parser.UsingDefaults)) && ~isempty(fieldnames(parser.Unmatched))
        warning('shepherdlabephys:getBaselineAndResponseWindows:MixedSyntax','The old Start and Window syntaxes should not be combined with the new, more flexible parameter options. The newer options will supercede the older ones.');
    end
    
    isValidIndex = @(x) isnumeric(x) && isscalar(x) && isreal(x) && isfinite(x) && x == round(x) && x >= 1 && x <= size(traces,1);
    addParameter(parser,'BaselineStartIndex',NaN,isValidIndex);
    addParameter(parser,'BaselineEndIndex',NaN,isValidIndex);
    addParameter(parser,'BaselineStartTime',NaN,isValidTime);
    addParameter(parser,'BaselineLength',NaN,isValidTime);
    addParameter(parser,'ResponseStartIndex',NaN,isValidIndex);
    addParameter(parser,'ResponseEndIndex',NaN,isValidIndex);
    addParameter(parser,'ResponseStartTime',NaN,isValidTime);
    addParameter(parser,'ResponseLength',NaN,isValidTime);
    parser.parse(varargin{:});
    
    passedParameters = varargin(1:2:end);
    if any(contains(passedParameters,'Index')) && (any(contains(passedParameters,'StartTime')) || any(contains(passedParameters,'Length')))
        warning('shepherdlabephys:getBaselineAndResponseWindows:MixedIndicesAndTime','Parameters have been defined using a mix of indices and times. Indices will supercede times.');
    end
    
    safeIndex = @(x) max(1,min(size(traces,1),x));
    safeTime = @(x) max(1,min(size(traces,1),x*sampleRate));
    
    % if no form of response start was specified, wait and see if a
    % baseline was specified...
    responseStartIndex = ternaryop(isnan(parser.Results.ResponseStartIndex),ternaryop(isnan(parser.Results.ResponseStartTime),ternaryop(isnan(parser.Results.Start),NaN,safeTime(parser.Results.Start)),safeTime(parser.Results.ResponseStartTime)),safeIndex(parser.Results.ResponseStartIndex));
    
    baselineStartIndex = ternaryop(isnan(parser.Results.BaselineStartIndex),ternaryop(isnan(parser.Results.BaselineStartTime),1,safeTime(parser.Results.BaselineStartTime)),safeIndex(parser.Results.BaselineStartIndex));
    baselineEndIndex = ternaryop(isnan(parser.Results.BaselineEndIndex),ternaryop(isnan(parser.Results.BaselineLength),ternaryop(isnan(responseStartIndex),0,safeIndex(responseStartIndex-1)),safeIndex(baselineStartIndex+parser.Results.BaselineLength*sampleRate)),safeIndex(parser.Results.BaselineEndIndex));
        
    if isnan(responseStartIndex)
        % ...then use one after the baseline ends as the startIndex
        responseStartIndex = baselineEndIndex+1;
    end
    
    % but because of the delayed evaluation of responseStartIndex, we need
    % to calculateResponseEndIndex here
    responseEndIndex = ternaryop(isnan(parser.Results.ResponseEndIndex),ternaryop(isnan(parser.Results.ResponseLength),ternaryop(isnan(parser.Results.Window),size(traces,1),safeIndex(responseStartIndex+parser.Results.Window*sampleRate)),safeIndex(responseStartIndex+parser.Results.ResponseLength*sampleRate)),safeIndex(parser.Results.ResponseEndIndex));
    
    if responseStartIndex <= baselineEndIndex && baselineEndIndex <= responseEndIndex...
    || baselineStartIndex <= responseEndIndex && responseEndIndex <= baselineEndIndex
        warning('shepherdlabephys:getBaselineAndResponseWindows:OverlappingWindows','Baseline and response windows overlap.');
    end
end