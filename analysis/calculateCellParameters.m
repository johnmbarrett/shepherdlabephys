function [Rs,Ri,tau,Cm,steadyState,Racc] = calculateCellParameters(data,voltageStep,sampleRate,varargin)
%CALCULATECELLPARAMETERS    Calculate various cell parameters
%   [RS,RI,TAU,CM,STEADYSTATE,RACC] = ...
%   CALCULATECELLPARAMETERS(DATA,VOLTAGESTEP,SAMPLERATE) calculates the 
%   series resistance, RS, the input resistance, RI, the decay time, TAU, 
%   the membrane capacitance, CM, the steady-state current STEADYSTATE, and
%   the access resistance, RACC, from the ephys trace(s) contained in the 
%   matrix DATA (one sweep per column, sampled at SAMPLERATE), which 
%   contains a voltage step of amplitude VOLTAGESTEP volts.
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
%      'TauMethod'          Method for calculating the membrane decay
%                           constant tau.  Options are:-
%
%                           * 'direct'  Find the first point at which the
%                                       response drops below 1/e of the
%                                       peak response above baseline.
%                           * 'fit'     Fit an exponential decay function
%                                       to the response and extract tau as
%                                       the rate parameter.
%
%                           The direct method is faster but the fit method
%                           may be more robust to noise.  Default is
%                           'direct'.

%   Written by John Barrett 2017-08-16 11:45 CDT
%   Last updated John Barrett 2017-08-16 13:36 CDT
%   Based on code written by Gordon Shepherd 2008-03-08

    parser = inputParser;
    
    isRealFiniteNumericScalar = @(x) validateattributes(x,{'numeric'},{'real' 'finite' 'scalar'});
    
    addParameter(parser,'ResponseStart',0,isRealFiniteNumericScalar);
    addParameter(parser,'ResponseLength',0.01,isRealFiniteNumericScalar);
    addParameter(parser,'SteadyStateStart',-0.02,isRealFiniteNumericScalar);
    addParameter(parser,'SteadyStateLength',0.02,isRealFiniteNumericScalar);
    addParameter(parser,'AverageFun',@mean,@(x) isa(x,'function_handle'));
    addParameter(parser,'TauMethod','direct',@(x) ismember(x,{'direct' 'fit'}));
    parser.parse(varargin{:});

    N = size(data,1);
    time = (0:N-1)'/sampleRate;
    
    [responseStartIndex,responseEndIndex] = getWindowIndices(parser.Results.ResponseStart,parser.Results.ResponseLength,sampleRate,N);

    % TODO : what if we already got the peak?  option to pass it in instead
    % of calculating it again?
    [peakResponse, peakIndex] = peak(data(responseStartIndex:responseEndIndex,:));
    peakIndex = peakIndex + responseStartIndex - 1;

    [steadyStateStartIndex,steadyStateEndIndex] = getWindowIndices(parser.Results.SteadyStateStart,parser.Results.SteadyStateLength,sampleRate,N);
    
    steadyState = parser.Results.AverageFun(data(steadyStateStartIndex:steadyStateEndIndex,:));

    Rs = voltageStep./peakResponse; % V/pA = TOhm
    Ri = voltageStep./steadyState-Rs;
    Racc = voltageStep./(peakResponse-steadyState);

    steadyStateSubtractedData = bsxfun(@minus,data,steadyState);

    tau = zeros(size(peakResponse));
    
    for ii = 1:numel(tau)
        if peakResponse(ii) < 0
            compare = @ge;
        else
            compare = @le;
        end
        
        decayIndices = peakIndex(ii):responseEndIndex;
        decayTime = time(decayIndices)-time(decayIndices(1));
        responseAmplitude = (peakResponse(ii)-steadyState(ii));
        
        switch parser.Results.TauMethod
            case 'direct'
                tauII = decayTime(find(compare(steadyStateSubtractedData(decayIndices,ii),responseAmplitude/exp(1)),1));
                
                if isempty(tauII)
                    tauII = NaN;
                end
                
                tau(ii) = tauII;
            case 'fit'
                expfit = fit(decayTime,steadyStateSubtractedData(decayIndices,ii),@(a,b,x) a*exp(-x/b),'StartPoint',[responseAmplitude 1]);
                tau(ii) = expfit.b;
        end 
    end
    
    Cm = (Rs + Ri) .* tau ./ (Rs .* Ri); % TOhm*s/(TOhm^2) = pF
    
    Rs = Rs*10^6; % convert to MOhms
    Ri = Ri*10^6; % convert to MOhms
    Racc = Racc*10^6; % convert to MOhms
end