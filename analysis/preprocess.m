function [filteredAverageTrace,averageFilteredTrace,filteredTraces,averageTrace,baselineSubtractedTraces,baseline] = preprocess(traces,sampleRate,varargin)
    % TODO : this function needs a better name
    parser = inputParser;
    
    % TODO : more options
    addParameter(parser,'Start',0,@(x) validateattributes(x,{'numeric'},{'scalar' 'real' 'finite'}));
    addParameter(parser,'Window',0,@(x) validateattributes(x,{'numeric'},{'scalar' 'real' 'finite' 'nonnegative'}));
    addParameter(parser,'AverageFun',@nanmean,@(x) isa(x,'function_handle'));
    addParameter(parser,'FilterLength',3,@(x) validateattributes(x,{'numeric'},{'scalar' 'real' 'finite' 'positive' 'integer'}));
    addParameter(parser,'FilterFun',@nanmedian,@(x) isa(x,'function_handle'));
    addParameter(parser,'PreFilter',false,@(x) islogical(x) && isscalar(x));
    addParameter(parser,'PreFilterLength',NaN,@(x) validateattributes(x,{'numeric'},{'scalar' 'real' 'finite' 'positive' 'integer'}));
    addParameter(parser,'PreFilterFun',NaN,@(x) isa(x,'function_handle'));
    addParameter(parser,'PostFilter',true,@(x) islogical(x) && isscalar(x));
    addParameter(parser,'PostFilterLength',NaN,@(x) validateattributes(x,{'numeric'},{'scalar' 'real' 'finite' 'positive' 'integer'}));
    addParameter(parser,'PostFilterFun',NaN,@(x) isa(x,'function_handle'));
    parser.parse(varargin{:});

    average = parser.Results.AverageFun; % TODO : do we ever want a different function to calculate the baseline and to average the traces?
    
    if parser.Results.Window > 0
        % TODO : this or something very similar is in a lot of functions.
        % Introduce method?
        startIndex = max(1,parser.Results.Start*sampleRate);
        endIndex = startIndex + max(0,parser.Results.Window*sampleRate);
    
        baseline = average(traces(startIndex:endIndex,:,:),1);
    
    % Subtract baseline from traces
        baselineSubtractedTraces = bsxfun(@minus,traces,baseline);
    else
        baseline = 0;
        baselineSubtractedTraces = traces;
    end
    
    % Compute average trace
    averageTrace = average(baselineSubtractedTraces,2);
    
    % TODO : this and the post filter are very repetitive
    if parser.Results.PreFilter
        if ~isa(parser.Results.PreFilterFun,'function_handle')
            preFilterFun = parser.Results.FilterFun;
        else
            preFilterFun = parser.Results.PreFilterFun;
        end
        
        if isnan(parser.Results.PreFilterLength)
            preFilterLength = parser.Results.FilterLength;
        else
            preFilterLength = parser.Results.PreFilterLength;
        end
    
        filteredTraces = colfilt(baselineSubtractedTraces,[preFilterLength,1],'sliding',preFilterFun);
    else
        filteredTraces = baselineSubtractedTraces;
    end

    averageFilteredTrace = average(filteredTraces,2);
    
    if parser.Results.PostFilter
        if ~isa(parser.Results.PostFilterFun,'function_handle')
            postFilterFun = parser.Results.FilterFun;
        else
            postFilterFun = parser.Results.PostFilterFun;
        end
        
        if isnan(parser.Results.PostFilterLength)
            postFilterLength = parser.Results.FilterLength;
        else
            postFilterLength = parser.Results.PostFilterLength;
        end
        
        % Median filter average trace
        % TODO : do we always want colfilt here?
        filteredAverageTrace = colfilt(averageTrace,[postFilterLength,1],'sliding',postFilterFun);
    else
        filteredAverageTrace = averageTrace;
    end
end