function [amplitude,width,start,number,interval] = extractEphusSquarePulseTrainParameters(dataFile,stimIndex,varargin)
    if nargin < 2
        stimIndex = 1;
    end
    
    if ischar(dataFile)
        dataFile = load(dataFile,'-mat');
    end
    
    parser = inputParser;
    parser.addParameter('Program','stimulator',@(x) any(strcmpi(x,{'ephys' 'stimulator'})));
    parser.parse(varargin{:});
   
    program = lower(parser.Results.Program);
    
    stimData = dataFile.header.(program).(program).pulseParameters{1,stimIndex};
    
    start = stimData.squarePulseTrainDelay;
    width = stimData.squarePulseTrainWidth;
    interval = stimData.squarePulseTrainISI;
    number = stimData.squarePulseTrainNumber;
    amplitude = stimData.amplitude;
end