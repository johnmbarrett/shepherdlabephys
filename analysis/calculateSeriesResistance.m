function Rs = calculateSeriesResistance(traces,sampleRate,varargin)
%CALCULATESERIESRESISTANCE  Calculate series resistance
%   RS = CALCULATESERIESRESISTANCE(TRACES,SAMPLERATE) calculates the series
%   resistance of a cell or cells based on the electrophysiological data
%   contained in TRACES, which is a matrix where each column represents a
%   current-clamp recording from a cell during a which a voltage step is
%   applied.  SAMPLERATE is a scalar that specifies the sampling rate of
%   TRACES in Hz.  Returns a scalar or row vector RS giving the series
%   resistance (voltage step/minimum current) calculated on each sweep.
%
%   RS = CALCULATESERIESRESISTANCE(...,PARAM1,VAL1,PARAM2,VAL2,...) 
%   specifies one or more of the following name/value pairs:
%
%      'Start'          Scalar specifying the start of the voltage step in
%                       seconds from the beginning of each sweep.  Default
%                       is 0.
%      'Window'         Scalar specifying the length of the voltage step in
%                       seconds.  Default is 0.05.
%      'VoltageStep'    Scalar specifying the size of the voltage step in
%                       volts.  Default is -5.

%   Written by John Barrett 2017-07-27 17:38 CDT
%   Last updated John Barrett 2017-08-15 15:17 CDT
    parser = inputParser;
    
    % TODO : a lot of these parameters in these functions are very similar,
    % can we factor out the common code?
    isRealFiniteNonnegativeNumericScalar = @(x) validateattributes(x,{'numeric'},{'real' 'finite' 'nonnegative' 'scalar'});
    addParameter(parser,'Start',0,isRealFiniteNonnegativeNumericScalar);
    addParameter(parser,'Window',0.05,isRealFiniteNonnegativeNumericScalar);
    addParameter(parser,'VoltageStep',-5,@(x) validateattributes(x,{'numeric'},{'real' 'finite' 'scalar'}));
    parser.parse(varargin{:});
    
    startIndex = max(1,parser.Results.Start*sampleRate);
    endIndex = min(size(traces,1),startIndex+parser.Results.Window*sampleRate);
    
    Rs = 1000*parser.Results.VoltageStep./min(traces(startIndex:endIndex,:,:));
end