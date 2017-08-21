function loadSwitchyard(self,varargin)
    % loadSwitchyard
    %
    % Editing:
    % gs may 2005
    % --------------------------------------------------

    hWaitBar = waitbar(0.25, 'Loading, please wait.');

    traceType = self.lstbxTraceType;

    switch traceType
        case 'general physiology traces'
        case 'excitation profile'
            self.traceMapYFactor = 5;
        case 'input map'
            self.traceMapYFactor = 100;
        case 'ephys traces'
        otherwise
            error('ShepherdLab:mapalyzer:loadSwitchyard:UnknownTraceType','Unrecognized trace type %s\m',traceType); % or load method');
    end

    mode = get(findobj(self.Figure,'Tag','lstbxSelectionType'),'Value')-1; % TODO : check -1

    self.loadTraces(mode);
    
    if isempty(self.numberOfMaps) || self.numberOfMaps == 0
        close(hWaitBar);
        return
    end

    waitbar(0.8, hWaitBar, 'Filtering and Baseline-subtracting ...');

    for ii = 1:self.numberOfMaps
        [~,~,self.maps(ii).fArray,~,self.maps(ii).bsArray] = preprocess(...
            self.mapActive.dataArray, self.sampleRate, ...
            'Start',        self.bsBaselineStart,                       ...
            'Window',       self.bsBaselineEnd-self.bsBaselineStart,    ...
            'PreFilter',    true,                                       ...
            'FilterFun',    str2func(['nan' self.popFilterType])         ...
            );
    end

    self.mapActive = self.maps(1);

    self.chooseImageFile();

    close(hWaitBar);
end