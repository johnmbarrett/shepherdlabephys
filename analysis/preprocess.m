function [filteredAverageTrace,averageFilteredTrace,filteredTraces,averageTrace,baselineSubtractedTraces,baseline] = preprocess(traces,sampleRate,varargin)
%PREPROCESS Preprocess electrophysiology data
%   [FILTEREDAVERAGETRACE,AVERAGEFILTEREDTRACE,FILTEREDTRACES,...
%   AVERAGETRACE,BASELINESUBTRACTEDTRACES,BASELINE] = PREPROCESS(TRACES,...
%   SAMPLERATE) baseline-subtraces, filters, and averages a series of
%   electrophysiological recordings contained in the columns of the matrix
%   TRACES, sampled at SAMPLERATE Hz.  Returns a row vector BASELINE
%   containing the baseline value for each column of traces; matrices
%   BASELINESUBTRACTEDTRACES and FILTEREDTRACES the same size as TRACES
%   containing the baseline-subtracted traces before and after filtering,
%   respectively; and column vectors AVERAGETRACE, AVERAGEFILTEREDTRACE,
%   and FILTEREDAVERAGETRACE representing the average trace without
%   filtering, where the filtering is applied before averaging, and where
%   the filtering is applied after averaging, respectively.
%
%   [...] = PREPROCESS(...,PARAM1,VAL1,PARAM2,VAL2,...) 
%   specifies one or more of the following name/value pairs:
%
%       'Start'             Scalar specifying the start of the window for
%                           calculating the baseline.  Default is 0.
%       'Window'            Scalar specifying the length of the window for
%                           calculating the baseline.  Default is
%                           size(TRACES,1)/SAMPLERATE.
%       'AverageFun'        Function to use for averaging, taken as a
%                           function handle.  Must take a matrix as its
%                           first argument and a dimension to average along
%                           as its second argument (currently preprocess
%                           always averages along the second dimension).
%                           Default is @nanmean.
%       'FilterLength'      Size of the filter in samples.  Default is 3.
%       'FilterFun'         Function handle to a function to be passed to
%                           COLFILT in order to filter the data.  Default
%                           is @nanmedian.
%       'PreFilter'         Logical indicating whether or not to filter
%                           before averaging.  If false, FILTEREDTRACES is
%                           equal to BASELINESUBTRACTEDTRACES. Default is 
%                           false.
%       'PreFilterLength'   Size of the filter applied before averaging in
%                           samples.  If unspecified and PreFilter is true,
%                           the value of FilterLength is used instead.
%       'PreFilterFun'      Function to be passed to colfilt for filtering
%                           before averaging.  If unspecified and PreFilter
%                           is true, the value of FilterFun is used instead.
%       'PostFilter'        Logical indicating whether or not to filter
%                           after averaging.  If false,
%                           FILTEREDAVERAGETRACE is equal to AVERAGETRACE.
%                           Default is true.  If both PreFilter and 
%                           PostFilter are true, each filter is applied
%                           separately and the results returned in
%                           AVERAGEFILTEREDTRACE (for the pre-filter) and
%                           FILTEREDAVERAGETRACE (for the post-filter) - no
%                           return value contains the result of filtering
%                           before and after averaging.
%       'PreFilterLength'   Size of the filter applied after averaging in
%                           samples.  If unspecified and PreFilter is true,
%                           the value of FilterLength is used instead.
%       'PreFilterFun'      Function to be passed to colfilt for filtering
%                           after averaging.  If unspecified and PreFilter
%                           is true, the value of FilterFun is used instead.

%   Written by John Barrett 2017-07-27 15:42 CDT
%   Last updated John Barrett 2017-08-15 16:09 CDT

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