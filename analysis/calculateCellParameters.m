function [Rs,Ri,tau,Cm] = calculateCellParameters(data,voltageStep,sampleRate,varargin)
%CALCULATECELLPARAMETERS    Calculate various cell parameters
%   [RS,RI,TAU,CM] = CALCULATECELLPARAMETERS(DATA,VOLTAGESTEP,SAMPLERATE)
%   calculates the series resistance, RS, the input resistance, RI, the
%   decay time, TAU, and the membrane capacitance, CM, from the ephys
%   trace(s) contained in the matrix DATA (one sweep per column, sampled at
%   SAMPLERATE), which contains a voltage step of amplitude VOLTAGESTEP
%   volts.
%
%   [...] = CALCULATECELLPARAMETERS(...,PARAM1,VAL1,PARAM2,VAL2,...) 
%   specifies one or more of the following name/value pairs:
%
%      'ResponseStart'      Scalar specifying the start of the voltage step
%                           in seconds from the beginning of each sweep (if
%                           zero or positive) or from the end of the sweep
%                           (if negative).  Default is 0.
%      'ResponseLength'     Scalar specifying the length of the voltage
%                           step in seconds.  Default is 0.01.
%      'SteadyStateStart'   Scalar specifying the start of the steady state
%                           response in seconds from the beginning of each 
%                           sweep (if zero or positive) or from the end of 
%                           the sweep (if negative).  Default is -0.02.
%      'SteadyStateLength'  Scalar specifying the length of the steady 
%                           state response in seconds.  Default is 0.
%      'AverageFun'         Function handle to the function used for
%                           averaging traces.  Default is @mean.

%   Written by John Barrett 2017-08-16 11:45 CDT
%   Last updated John Barrett 2017-08-15 11:47 CDT
%   Based on code written by Gordon Shepherd 2008-03-08

    parser = inputParser;
    
    isRealFiniteNumericScalar = @(x) validateattributes(x,{'numeric'},{'real' 'finite' 'scalar'});
    
    addParameter(parser,'ResponseStart',0,isRealFiniteNumericScalar);
    addParameter(parser,'ResponseLength',0.01,isRealFiniteNumericScalar);
    addParameter(parser,'SteadyStateStart',-0.02,isRealFiniteNumericScalar);
    addParameter(parser,'SteadyStateLength',0.02,isRealFiniteNumericScalar);
    addParameter(parser,'AverageFun',@mean,@(x) isa(x,'function_handle'));
    parser.parse(varargin{:});

    N = size(data,1);
    time = (0:N-1)/sampleRate;
    
    [responseStartIndex,responseEndIndex] = getWindowIndices(parser.Results.ResponseStart,parser.Results.ResponseLength,sampleRate,N);

    % TODO : what if we already got the peak?  option to pass it in instead
    % of calculating it again?
    [peakResponse, peakIndex] = peak(data(responseStartIndex:responseEndIndex,:));
    peakIndex = peakIndex + responseStartIndex - 1;

    [steadyStateStartIndex,steadyStateEndIndex] = getWindowIndices(parser.Results.SteadyStateStart,parser.Results.SteadyStateLength,sampleRate,N);
    
    steadyState = parser.Results.AverageFun(data(steadyStateStartIndex:steadyStateEndIndex,:));

    Rs = voltageStep./peakResponse; % V/pA = TOhm
    Ri = voltageStep./steadyState-Rs;

    steadyStateSubtractedData = bsxfun(@minus,data,steadyState);

    tau = zeros(size(peakResponse));
    
    for ii = 1:numel(tau)
        if peakResponse(ii) < 0
            compare = @ge;
        else
            compare = @le;
        end
        
        tau(ii) = time(find(compare(steadyStateSubtractedData(peakIndex(ii):end,ii),(peakResponse(ii)-steadyState(ii))/exp(1)),1));
    end
    
    Cm = (Rs + Ri) .* tau ./ (Rs .* Ri); % TOhm*s/(TOhm^2) = pF
    
    Rs = Rs*10^6; % convert to MOhms
    Ri = Ri*10^6; % convert to MOhms
end

% TODO : useful for other functions?
function [startIndex,endIndex] = getWindowIndices(start,length,sampleRate,maxLength)
    if start < 0
        startIndex = max(1,round(maxLength-start*sampleRate));
    else
        startIndex = max(1,min(maxLength,round(start*sampleRate)));
    end
    
    endIndex = min(maxLength,round(startIndex+length*sampleRate));
end