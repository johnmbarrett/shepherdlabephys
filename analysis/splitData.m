function splitTraces = splitData(traces,sampleRate,varargin)
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