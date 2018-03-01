function [header,dataFile] = getWavesurferHeader(dataFile)
    if ischar(dataFile)
        dataFileName = dataFile;
        dataFile = ws.loadDataFile(dataFileName);
    else
        dataFileName = '';
    end
    
    if isfield(dataFile,'header')
        header = dataFile.header;
    elseif isfield(dataFile,'Acquisition')
        header = dataFile;
    else
        errorMessage = 'Unable to locate header';
        
        if ~isempty(dataFileName)
            errorMessage = [errorMessage ' in file: ' dataFileName];
        end
        
        error('ShepherdLabEphys:getWavesurferHeader:UnknownFileFormat',errorMessage);
    end
end