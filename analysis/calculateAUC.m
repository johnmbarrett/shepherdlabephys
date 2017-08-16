function AUC = calculateAUC(data,sampleRate,varargin)
%CALCULATEAUC   Calculate area under the curver
%   AUC = CALCULATEAUC(DATA,SAMPLERATE) calculates the area under the curve
%   for the electrophysiology traces in the matrix DATA (one trace per 
%   column, sampled at SAMPLERATE).  The returned value is always positive:
%   if the maximum absolute value of data is negative, the integral is 
%   multiplied by -1 to get the area under the curve.
%
%   AUC = CALCULATEAUC(...,PARAM1,VAL1,PARAM2,VAL2,...) specifies one or 
%   more of the following name/value pairs:
%
%       'WindowStart'   Scalar specifying the start of the window over
%                       which to calculate the AUC.  If negative, it is
%                       relative to the end of the trace, otherwise it is
%                       relative to the beginning.  Default is 0.
%       'WindowLength'  Scalar specifying the length of window over which
%                       to calculate the AUC.  Default is the entire length
%                       of the trace.
%       'Baseline'      Value which will be subtracted from each trace 
%                       before calculating the AUC.  May be a scalar or a
%                       matrix with one value for every sweep in DATA.  The
%                       default is 0.
%       'Threshold'     Values less than this after baseline subtraction
%                       (and sign-reversal for negative peaks) will 
%                       truncated to zero.

%   Written by John Barrett 2017-08-16 14:40 CDT
%   Last updated John Barrett 2017-08-16 14:56 CDT
    parser = inputParser;
    
    isRealFiniteNumericScalar = @(x) validateattributes(x,{'numeric'},{'real' 'finite' 'scalar'});
    addParameter(parser,'WindowStart',0,isRealFiniteNumericScalar);
    addParameter(parser,'WindowLength',Inf,isRealFiniteNumericScalar);
    addParameter(parser,'Baseline',0,@(x) validateattributes(x,{'numeric'},{'real' 'finite'}));
    addParameter(parser,'Threshold',0,isRealFiniteNumericScalar);
    parser.parse(varargin{:});
    
    [startIndex,endIndex] = getWindowIndices(parser.Results.WindowStart,parser.Results.WindowLength,sampleRate,size(data,1));
    
    colons = repmat({':'},1,ndims(data)-1);
    
    data = data(startIndex:endIndex,colons{:});
    
    baseline = parser.Results.Baseline;
    baselineSize = size(data);
    baselineSize = baselineSize(2:end);
    
    assert(isscalar(baseline) || isequal(size(squeeze(baseline)),baselineSize),'ShepherdLab:calculateAUC:InvalidBaselineSize','Baseline must be a scalar or a matrix with one value for every sweep in data');
    
    if ~isscalar(baseline)
        baseline = reshape(baseline,[1 baselineSize]);
    end
    
    data = bsxfun(@minus,data,baseline);
    
    data = bsxfun(@times,data,sign(peak(data)));
    
    data = max(parser.Results.Threshold,data);
    
    AUC = trapz(data)/sampleRate;
end