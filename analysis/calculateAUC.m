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
%       'Baseline'      Scalar value which will be subtracted from the
%                       trace before calculating the AUC.  Default is 0.
%       'Threshold'     Values less than this after baseline subtraction
%                       (and sign-reversal for negative peaks) will 
%                       truncated to zero.

%   Written by John Barrett 2017-08-16 14:40 CDT
%   Last updated John Barrett 2017-08-16 14:56 CDT
    parser = inputParser;
    
    isRealFiniteNumericScalar = @(x) validateattributes(x,{'numeric'},{'real' 'finite' 'scalar'});
    addParameter(parser,'WindowStart',0,isRealFiniteNumericScalar);
    addParameter(parser,'WindowLength',Inf,isRealFiniteNumericScalar);
    addParameter(parser,'Baseline',0,isRealFiniteNumericScalar);
    addParameter(parser,'Threshold',0,isRealFiniteNumericScalar);
    parser.parse(varargin{:});
    
    [startIndex,endIndex] = getWindowIndices(parser.Results.WindowStart,parser.Results.WindowLength,sampleRate,size(data,1));
    
    data = data(startIndex:endIndex,:,:);
    
    data = data-parser.Results.Baseline;
    
    data = bsxfun(@times,data,sign(peak(data)));
    
    data = max(parser.Results.Threshold,data);
    
    AUC = trapz(data)/sampleRate;
end