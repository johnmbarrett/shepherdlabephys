function sampleRate = getSampleRate(dataFile)
    if isstruct(dataFile)
        format = getDataFormat(dataFile);
    else
        [dataFile,format] = loadDataFile(dataFile);
    end
    
    switch format
        case 'xsg'
            sampleRate = dataFile.header.ephys.ephys.sampleRate;
        case 'wavesurfer'
            sampleRate = dataFile.header.Acquisition.SampleRate;
        otherwise
            error('ShepherdLab:getSampleRate:UnknownFormat','Unknown file format');
    end
end
        
    