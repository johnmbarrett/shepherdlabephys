function Rs = calculateSeriesResistance(traces,sampleRate,varargin)
    parser = inputParser;
    
    % TODO : a lot of these parameters in these functions are very similar,
    % can we factor out the common code?
    isRealFiniteNonnegativeNumericScalar = @(x) validateattributes(x,{'numeric'},{'real' 'finite' 'nonnegative' 'scalar'});
    parser.addParameter('Start',0,isRealFiniteNonnegativeNumericScalar);
    parser.addParameter('Window',0.05,isRealFiniteNonnegativeNumericScalar);
    parser.addParameter('VoltageStep',-5,@(x) validateattributes(x,{'numeric'},{'real' 'finite' 'scalar'}));
    parser.parse(varargin{:});
    
    startIndex = max(1,parser.Results.Start*sampleRate);
    endIndex = min(size(traces,1),startIndex+parser.Results.Window*sampleRate);
    
    Rs = 1000*parser.Results.VoltageStep./min(traces(startIndex:endIndex,:,:));
end