function [amplitude,width,start,number,interval] = extractEphusSquarePulseTrainParameters(dataFile,stimIndex,varargin)
%EXTRACTEPHUSSQUAREPULSETRAINPARAMETERS  Extract square pulse train
%parameters.
%   AMPLITUDE = EXTRACTEPHUSSQUAREPULSETRAINPARAMETERS(DATAFILE,STIMINDEX)
%   returns the AMPLITUDE of the STIMINDEXth stimulator stimulus in the xsg
%   file DATAFILE.  The stimulus is assumed to be a square pulse train.
%   DATAFILE maybe specified as a filename string or as a struct containing
%   the header from a previously loaded xsg file.  AMPLITUDE is a scalar
%   with arbitrary dimensionality.
%   
%   [AMPLITUDE,WIDTH,START,NUMBER,INTERVAL] =
%   EXTRACTEPHUSSQUAREPULSETRAINPARAMETERS(...) additionally returns the
%   WIDTH, START, NUMBER and inter-stimulus INTERVAL of the square pulse
%   train (all scalar, all in seconds apart from NUMBER, which is
%   dimensionless).
%
%   [...] = EXTRACTEPHUSSQUAREPULSETRAINPARAMETERS(...,PARAM,VAL,...) 
%   specifies one or more of the following name/value pairs:
%
%       'Program'   Specifies which Ephus program to extract the stimulus
%                   parameters from.  Must be one of 'ephys' or
%                   'stimulator'.  Default is 'stimulator'.

%   Written by John Barrett 2017-07-28 11:42 CDT
%   Last updated John Barrett 2017-08-15 17:16 CDT
    if nargin < 2
        stimIndex = 1;
    end
    
    if ischar(dataFile)
        dataFile = load(dataFile,'-mat');
    end
    
    parser = inputParser;
    addParameter(parser,'Program','stimulator',@(x) any(strcmpi(x,{'ephys' 'pulseJacker' 'stimulator'})));
    parser.parse(varargin{:});
    
    program = lower(parser.Results.Program);
    
    switch program
        case {'ephys' 'stimulator'}
            stimData = dataFile.header.(program).(program).pulseParameters{1,stimIndex};
        case 'pulsejacker'
            pulseJacker = dataFile.header.pulseJacker.pulseJacker;
            stimData = pulseJacker.pulseDataMap{stimIndex,pulseJacker.currentPosition+1};
    end
    
    if isempty(stimData)
        start = NaN;
        width = NaN;
        interval = NaN;
        number = NaN;
        amplitude = NaN;
    else
        start = stimData.squarePulseTrainDelay;
        width = stimData.squarePulseTrainWidth;
        interval = stimData.squarePulseTrainISI;
        number = stimData.squarePulseTrainNumber;
        amplitude = stimData.amplitude;
    end
    
    if nargout <= 1 
        amplitude = struct('start',start,'width',width,'interval',interval,'number',number,'amplitude',amplitude);
    end
end 