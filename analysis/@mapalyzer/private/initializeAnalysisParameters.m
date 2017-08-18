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
        
        uicontrol = findobj(self.Figure,'Tag',field);
        
        if ~isempty(uicontrol)
            switch get(uicontrol,'Style')
                case 'checkbox'
                    set(uicontrol,'Value',logical(value));
                case 'edit'
                    if isnumeric(value)
                        set(uicontrol,'String',num2str(value))
                    elseif ischar(value)
                        set(uicontrol,'String',value)
                    else
                        warning('ShepherdLab:mapalyzer:initializeAnalysisParameters:InvalidParameterValue','Invalid value for parameter %s\n',field);
                    end
                case {'listbox' 'popupmenu'}
                    if isnumeric(value)
                        set(uicontrol,'Value',value)
                    elseif ischar(value)
                        index = find(strcmpi(value,get(uicontrol,'String')));
                        
                        if isempty(index)
                            warning('ShepherdLab:mapalyzer:initializeAnalysisParameters:InvalidParameterValue','Invalid value for parameter %s\n',field);
                            continue
                        end
                        
                        set(uicontrol,'Value',index);
                    else
                        warning('ShepherdLab:mapalyzer:initializeAnalysisParameters:InvalidParameterValue','Invalid value for parameter %s\n',field);
                    end
                otherwise
                    warning('ShepherdLab:mapalyzer:initializeAnalysisParameters:UnknownParameter','Unknown parameter %s\n',field);
            end
            
            continue
        end
        
        prop = findprop(self,field);
          
        if isempty(prop)
            warning('ShepherdLab:mapalyzer:initializeAnalysisParameters:UnknownParameter','Unknown parameter %s\n',field);
            continue
        end
        
        self.(prop.Name) = value;
    end
end