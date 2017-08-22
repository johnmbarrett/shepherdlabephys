function initializeAnalysisParameters(self)
% INITIALIZEANALYSISPARAMETERS  Initialises mapalyzer analysis parameters

% Created by John Barrett 2017-08-17 17:41 CDT
% Last Modified by John Barrett 2017-08-17 17:39 CDT
% gs april 2005
% -------------------------------------------------
    if ispc
        homeFolder = [getenv('HOMEDRIVE') getenv('HOMEPATH')];
    else
        homeFolder = getenv('HOME');
    end
    
    userINIFile = [homeFolder '\mapalyzer.ini'];
    
    if exist(userINIFile,'file')
        params = parseINIFile(userINIFile);
    else
        defaultINIFile = [fileparts(which('mapalyzer')) '\mapalyzer.ini'];
        
        if ~exist(defaultINIFile,'file')
            warning('ShepherdLab:mapalyzer:initializeAnalysisParameters:MissingINIFile','Can not find mapalyzer.ini file');
            return
        end
        
        params = parseINIFile(defaultINIFile);
    end
    
    fields = fieldnames(params);
    
    for ii = 1:numel(fields)
        field = fields{ii};
        value = params.(field);
        
        prop = findprop(self,field);
          
        if isempty(prop)
            warning('ShepherdLab:mapalyzer:initializeAnalysisParameters:UnknownParameter','Unknown parameter %s\n',field);
            continue
        end
        
        self.(prop.Name) = value;
    end
end