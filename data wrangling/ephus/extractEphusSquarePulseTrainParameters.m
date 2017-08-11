function [amplitude,width,start,number,interval] = extractEphusSquarePulseTrainParameters(dataFile,stimIndex)
    if nargin < 2
        stimIndex = 1;
    end
    
    if ischar(dataFile)
        dataFile = load(dataFile,'-mat');
    end
   
    stimData = dataFile.header.stimulator.stimulator.pulseParameters{1,stimIndex};
    
    start = stimData.squarePulseTrainDelay;
    width = stimData.squarePulseTrainWidth;
    interval = stimData.squarePulseTrainISI;
    number = stimData.squarePulseTrainNumber;
    amplitude = stimData.amplitude;
end