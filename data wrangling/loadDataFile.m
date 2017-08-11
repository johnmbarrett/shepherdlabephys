function [data,format] = loadDataFile(filename)
    format = getDataFormat(filename);
    
    switch format
        case 'xsg'
            data = load(filename,'-mat');
        case 'wavesurfer'
            data = ws.loadDataFile(filename);
        otherwise
            error('ShepherdLab:loadDataFile:UnknownFormat','Unknown file format for file %s\n',filename);
    end
end