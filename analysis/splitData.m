function splitTraces = splitData(traces,sampleRate,varargin)
%SPLITDATA  Split a trace (or traces) at regular intervals
%   SPLITTRACES = SPLITDATA(TRACES,SAMPLERATE,PARAM1,VAL1,PARAM2,VAL2,...)
%   splits the data in TRACES (a matrix with one recording per column, 
%   sampled at SAMPLERATE Hz) into a fixed number of chunks of equal size 
%   spaced at regular intervals.  The number, length, spacing, and start
%   time of each chunk can be controlled by specifying one or more of the 
%   following name/value pairs:
%
%       'Window'    Scalar specifying the length of each chunk in seconds.
%                   Default is 0.05.
%       'Interval'  Scalar specifying the time interval between the starts
%                   of successive chunks.  Default is one second.
%       'Start'     Scalar specifying the start time of the first chunk in
%                   seconds from the beginning of each sweep.  Default
%                   is 0.
%       'N'         Scalar specifying the number of chunks.  Default is 1.

%   Written by John Barrett 2017-07-27 16:36 CDT
%   Last updated John Barrett 2017-08-15 16:25 CDT
    parser = inputParser;
    
    % TODO : more options, for example this one:
%     parser.AddParameter('Indices',NaN,@(x) iscell(x) && all(cellfun(@(y) validateattributes(y,{'numeric'},{'real' 'finite' 'positive' 'integer' 'vector'}) && max(y(:)) <= size(traces,1),x)));
    
    isRealFinitePositiveNumericScalar = @(x) validateattributes(x,{'numeric'},{'real' 'finite' 'positive' 'scalar'});
    addParameter(parser,'Window',0.05,isRealFinitePositiveNumericScalar);
    addParameter(parser,'Interval',1,isRealFinitePositiveNumericScalar);
    addParameter(parser,'Start',0,isRealFinitePositiveNumericScalar);
    addParameter(parser,'N',1,@(x) validateattributes(x,{'numeric'},{'real' 'finite' 'positive' 'scalar' 'integer'}));
    parser.parse(varargin{:});
    
    starts = max(1,parser.Results.Start*sampleRate)+(0:(parser.Results.N-1))*parser.Results.Interval*sampleRate;
    window = max(0,parser.Results.Window*sampleRate);
    ends = starts+window-1;
    
    N = parser.Results.N;
    splitTraces = zeros(window,N,size(traces,2));
    
    for ii = 1:N
        splitTraces(:,ii,:) = traces(starts(ii):ends(ii),:);
    end
end