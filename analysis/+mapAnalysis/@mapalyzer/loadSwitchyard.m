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
        case 'video map'
        otherwise
            error('ShepherdLab:mapalyzer:loadSwitchyard:UnknownTraceType','Unrecognized trace type %s\n',traceType); % or load method');
    end

    mode = get(findobj(self.Figure,'Tag','lstbxSelectionType'),'Value')-1; % TODO : check -1

    self.loadTraces(mode,traceType);
    
    if isempty(self.recordings)
        close(hWaitBar);
        return
    end

    if ~strcmp(traceType,'video map')
        waitbar(0.8, hWaitBar, 'Filtering and Baseline-subtracting ...');

        for ii = 1:numel(self.recordings)
            [~,~,filteredData,~,baselineSubtractedData] = preprocess(...
                self.recordings(ii).Raw.Data', self.sampleRate, ...
                'Start',        self.bsBaselineStart,                       ...
                'Window',       self.bsBaselineEnd-self.bsBaselineStart,    ...
                'PreFilter',    true,                                       ...
                'FilterFun',    str2func(['nan' self.popFilterType])         ...
                );

            self.recordings(ii).BaselineSubtracted = mapAnalysis.Map(baselineSubtractedData',self.recordings(ii).Raw.Pattern);
            self.recordings(ii).Filtered = mapAnalysis.Map(filteredData',self.recordings(ii).Raw.Pattern);
        end
    end

    self.recordingActive = self.recordings(1);

    self.chooseImageFile();

    close(hWaitBar);
end