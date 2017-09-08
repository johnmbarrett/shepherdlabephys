classdef mapalyzer < dynamicprops
    % MAPALYZER M-file for mapalyzer.fig
    %      MAPALYZER, by itself, creates a new MAPALYZER or raises the existing
    %      singleton*.

    %      H = MAPALYZER returns the handle to a new MAPALYZER or the handle to
    %      the existing singleton*.

    %      MAPALYZER('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in MAPALYZER.M with the given input arguments.

    %      MAPALYZER('Property','Value',...) creates a new MAPALYZER or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before mapAnalysis_OpeningFunction gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to mapalyzer_OpeningFcn via varargin.

    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".

    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help mapalyzer

    % Last Modified by GUIDE v2.5 27-Jun-2008 15:15:38

    % Begin initialization code - DO NOT EDIT
    properties(Constant=true)
        codeFolder = fileparts(which('mapAnalysis.mapalyzer'));
        FigurePath = [mapAnalysis.mapalyzer.codeFolder '\mapalyzer.fig'];
    end
    
    properties % TODO : attributes
        Figure
        avgLaserIntensity = []
        colorOrder
        dataMfile
        defaultDataDir
        defaultDataMFileDir
        genericTraceBrowser
        image = struct('img',[],'imgDir','','imgName','','info',[]);
        imageXrange
        imageYrange
        isCurrentClamp
        Isteps
        recordingActive
        recordingAverage
        mapAvg = struct('baselineSD',[],'cmembrane',[],'rmembrane',[],'rseries',[],'spontEventRate',[],'synThreshpAmV',[],'tau',[]);
        recordings
        patchChannel
        sampleRate
        traceBrowsers
        tracesToAnalyze
        userFunction
        userFunctionFolder
    end
    
    methods
        function self = mapalyzer(varargin)
            self.Figure = open(mapAnalysis.mapalyzer.FigurePath); % TODO : figure out a neat way to do the singleton pattern
            
            uicontrols = findobj(self.Figure,'Style','listbox','-or','Style','popupmenu','-or','Style','checkbox','-or','Style','edit');
            
            if ispc
                backgroundColour = 'white';
            else
                backgroundColour = get(0,'defaultUicontrolBackgroundColor');
            end
            
            set(uicontrols,'BackgroundColor',backgroundColour);
            
            % TODO : the way information is stored in this class is
            % back-asswards.  a lot of the information in the uicontrols is
            % actually specific to the current map and should be stored
            % there (also maps should definitely be a class in their own
            % right), with the uicontrols just reflecting what's in the
            % current map.  also, an event-driven model would make this
            % much easier.
            for ii = 1:numel(uicontrols)
                prop = addprop(self,get(uicontrols(ii),'Tag'));
                
                prop.Dependent = true;
                prop.GetAccess = 'public';
                
                switch get(uicontrols(ii),'Style')
                    case 'checkbox'
                        prop.GetMethod = @(~) self.getCheckboxValue(uicontrols(ii));
                        prop.SetMethod = @(~,v) self.setCheckboxValue(uicontrols(ii),v);
                    case 'edit'
                        prop.GetMethod = @(~) self.getEditValue(uicontrols(ii));
                        prop.SetMethod = @(~,v) self.setEditValue(uicontrols(ii),v);
                    case 'listbox'
                        prop.GetMethod = @(~) self.getPopupMenuValue(uicontrols(ii));
                        prop.SetMethod = @(~,v) self.setPopupMenuValue(uicontrols(ii),v);
                    case 'popupmenu'
                        prop.GetMethod = @(~) self.getPopupMenuValue(uicontrols(ii));
                        prop.SetMethod = @(~,v) self.setPopupMenuValue(uicontrols(ii),v);
                    otherwise
                        % TODO : make these throw an error or at least a
                        % warning or something c'mon
                        prop.GetMethod = @(varargin) NaN;
                        prop.SetMethod = @(varargin) NaN;
                end
                
                prop.SetAccess = 'protected';
                
                set(uicontrols(ii),'Callback','');
            end
            
            self.initializeAnalysisParameters();
            
            % TODO : doing it this way until I can figure out what's
            % causing changes to the figure to blow up the file size in git
            set(findobj(self.Figure,'Tag','lstbxTraceType'),'String',{...
                'general physiology traces';    ...
                'excitation profile';           ...
                'input map';                    ...
                'ephys traces';                 ...
                'video map'                     ...
                });
            
            % TODO : can I alter the figure itself to have these always be
            % the default callbacks?
            % update 2017-08-30 - actually, I've saved the figure a bunch
            % of times and commited to the repository, so this might
            % already be the default callbacks.  must test at some point.
            set(findobj(self.Figure,'Tag','lstbxTraceType'),'Callback',@self.setLoadMethodFromTraceType);
            set(findobj(self.Figure,'Tag','handles2ws'),'Callback',@self.assignDataInWorkspace)
            set(findobj(self.Figure,'Tag','pbLoad'),'Callback',@self.loadSwitchyard);
            set(findobj(self.Figure,'Tag','selectVideoImage'),'Callback',@self.chooseImageFile);
            set(findobj(self.Figure,'Tag','displayVideoimages'),'Callback',@self.displayVideoImages);
            set(findobj(self.Figure,'Tag','createDataMFile'),'Callback',@(varargin) errordlg('I can''t let you do that, Dave...'));
            set(findobj(self.Figure,'Tag','pbCellParameters'),'Callback',@self.pbCellParameters_Callback); % TODO : rename this and other _Callback methods
            set(findobj(self.Figure,'Tag','showAutoNotes'),'Callback',@self.showAutoNotes);
            set(findobj(self.Figure,'Tag','pbTraceBrowser'),'Callback',@self.pbTraceBrowser_Callback);
            set(findobj(self.Figure,'Tag','arrayTracesAsInputMap'),'Callback',@self.arrayTracesAsInputMap_Callback);
            set(findobj(self.Figure,'Tag','pbGenericBrowse'),'Callback',@self.pbGenericBrowse_Callback);
            set(findobj(self.Figure,'Tag','analyzeInputMap'),'Callback',@self.analyzeInputMaps);
            set(findobj(self.Figure,'Tag','analyzeEP'),'Callback',@self.analyzeEP_Callback);
            set(findobj(self.Figure,'Tag','detectAPs'),'Callback',@self.detectAPs_Callback);
            set(findobj(self.Figure,'Tag','editEP'),'Callback',@self.editEP_Callback);
            set(findobj(self.Figure,'Tag','reanalyzeEP'),'Callback',@self.reanalyzeEP_Callback);
            set(findobj(self.Figure,'Tag','specifyWhichTraces'),'Callback',@self.specifyWhichTraces_Callback);
            set(findobj(self.Figure,'Tag','setCurrentStepFamily'),'Callback',@self.setCurrentStepFamily_Callback);
            set(findobj(self.Figure,'Tag','analyzeFI'),'Callback',@self.analyzeCurrentFrequencyRelation);
            set(findobj(self.Figure,'Tag','selectUserFcn'),'Callback',@self.selectUserFcn_Callback);
            set(findobj(self.Figure,'Tag','runUserFcn'),'Callback',@self.runUserFcn_Callback);
            set(findobj(self.Figure,'Tag','analyzeByTraceAveraging'),'Callback',@self.analyzeByTraceAveraging_Callback);
            
            set(get(findobj(self.Figure,'Tag','Help'),'Children'),'Callback',@self.help);
            
            set(get(self.Figure,'Children'),'Visible','on');
        end
        
        addMenu4DistanceMeasure(self,imgFigHandle)
        
        function out = getCheckboxValue(~,checkbox)
            out = get(checkbox,'Value');
        end
        
        function setCheckboxValue(~,checkbox,value)
            set(checkbox,'Value',logical(value));
        end
        
        function out = getEditValue(~,edit) % TODO : type safety
            str = get(edit,'String');
            
            if isempty(str)
                % until I can figure out a clean (or at least low-effort)
                % way to implement type safety, this is a compromise.  In
                % general, we can work out what type the edit box is
                % supposed to be by what is currently in it/what we're
                % trying to set it to.  The edge case is the empty string,
                % which could be an empty char array or an empty numeric
                % array.  Assuming numeric on the get side allows us to
                % cleanly handle cases like self.X(end+1) = Y, which is
                % common for numeric data but unlikely to happen for
                % strings.
                out = [];
                return
            end
            
            num = str2double(strsplit(str,','));
            
            if any(isnan(num))
                out = str;
            else
                out = num;
            end
        end
        
        function setEditValue(~,edit,value)
            if ischar(value)
                set(edit,'String',value);
            elseif isnumeric(value)
                set(edit,'String',strjoin(arrayfun(@num2str,value(:)','UniformOutput',false),','));
            else
                error('ShepherdLab:mapalyzer:setEditValue:InvalidValue','Edit box %s can only contain numeric or string values',get(edit,'Tag'));
            end
        end

        function out = getPopupMenuValue(~,popupmenu)
            str = get(popupmenu, 'String');
            
            if isempty(str)
                out = [];
                return
            end
            
            val = get(popupmenu, 'Value');
            out = str{val};
        end
        
        function setPopupMenuValue(~,popupmenu,value)
            if isnumeric(value)
                set(popupmenu,'Value',value);
            elseif ischar(value)
                set(popupmenu,'Value',find(ismember(get(popupmenu,'String'),value)));
            else
                error('ShepherdLab:mapalyzer:setPopupMenuValue:InvalidValue','Menu or list %s can only contain numeric or string values',get(popupmenu,'Tag'));
            end
        end
        
        function help(self,menuItem,varargin)
            tag = get(menuItem,'Tag');
            
            if strncmpi(tag,'help',4)
                helpFile = tag;
            elseif strcmp(tag,'dataMFiles');
                helpFile = 'helpDataMFiles';
            elseif strcmp(tag,'General')
                helpFile = 'helpMapAnalysis';
            else
                error('ShepherdLab:mapalyzer:UnknownHelpOption','Unknown help option %s\n',tag);
            end
            
            type([self.codeFolder '\helpFiles\' helpFile]);
        end

        function setLoadMethodFromTraceType(self,hObject,varargin)
            traceType = get(hObject, 'String');
            chosenTraceType = get(hObject, 'Value');
            
            switch traceType{chosenTraceType}
                case {'excitation profile' 'video map'}
                    selectionType = 'single map';
                case 'general physiology traces'
                    selectionType = 'selected traces';
                case 'input map'
                    selectionType = 'multiple maps, select manually';
                otherwise
                    return  
            end
            
            selectionTypeListBox = findobj(self.Figure,'Tag','lstbxSelectionType');
            
            selectionTypes = get(selectionTypeListBox,'String');
            
            set(selectionTypeListBox,'Value',find(strcmpi(selectionType,selectionTypes)));
        end

        function assignDataInWorkspace(self,varargin)
            handles = struct([]);
            
            % TODO : need some of the non-dynamic props as well
            props = cellfun(@(p) findprop(self,p),properties(self),'UniformOutput',false);
            props = props(cellfun(@(p) isa(p,'meta.DynamicProperty'),props));
            
            for ii = 1:numel(props)
                handles(1).(props{ii}.Name) = self.(props{ii}.Name);
            end
            
            assignin('base', 'handles', handles);
            disp('Handles variable created in workspace (or overwritten).');
        end

        % ================= CELL PARAMETERS ========================

        function pbCellParameters_Callback(self,varargin)
            set(self.Figure,'Pointer','Watch');
            self.calcCellParameters();
            self.plotCellParameters();
            set(self.Figure,'Pointer','Arrow');
        end

        % ============= MAP DISPLAY =================
        
        function checkForRecordings(self)
            if isempty(self.recordings)
                helpdlg('Please load some data first.');
            end
        end
        
        function arrayTracesAsInputMap_Callback(self,varargin)
            self.checkForRecordings();
            
            for ii = 1:numel(self.recordings)
                self.plotTracesAsInputMap(self.recordings(ii),ii);
            end
            
            self.plotTracesAsInputMap(self.recordings);
        end

        function pbTraceBrowser_Callback(self,varargin)
            self.checkForRecordings();
            
            theRecordings = self.recordings; % TODO : [self.recordings self.traceAvg];
            
            for ii = 1:numel(self.recordings) % TODO: +1
                % TODO : factory method?  pseudo-singleton pattern?
                if numel(self.traceBrowsers) < ii || ~isa(self.traceBrowsers(ii),'mapAnalysis.traceBrowser')
                    traceBrowser = mapAnalysis.mapTraceBrowser(theRecordings(ii),self);
                    
                    if isempty(self.traceBrowsers)
                        self.traceBrowsers = traceBrowser;
                    else
                        self.traceBrowsers(ii) = traceBrowser;
                    end
                else
                    self.traceBrowsers(ii).Recording = theRecordings(ii);
                end
            end
        end
        
        % ============= EXCITATION PROFILE =================

        % TODO : the map number is wrong in all of these; it should be
        % stored in the map itself
        function analyzeEP_Callback(self,varargin)
            set(self.Figure,'Pointer','Watch');
            self.analyzeInputMap(self.recordingActive,find(self.recordings == self.recordingActive),true); %#ok<FNDSB>
            set(self.Figure,'Pointer','Arrow');
        end

        function detectAPs_Callback(self,varargin)
            set(self.Figure,'Pointer','Watch');
            self.analyzeInputMap(self.recordingActive,find(self.recordings == self.recordingActive),true,true); %#ok<FNDSB>
            set(self.Figure,'Pointer','Arrow');
        end

        function editEP_Callback(self,varargin)
            set(self.Figure,'Pointer','Watch')
            
            prompt = {'Enter trace number:','Enter number of spikes:', 'Enter spike latency (first spike only):'};
            dialogTitle = 'Edit spike detection for excitation profile';
            answer = inputdlg(prompt,dialogTitle,1,{'10','5','0.03'},'on');

            traceNum = str2num(answer{1}); %#ok<ST2NM>
            numSpikes = str2num(answer{2}); %#ok<ST2NM>
            apDelay = str2num(answer{3}); %#ok<ST2NM>
            
            assert(numel(traceNum) == numel(numSpikes) && numel(numSpikes) == numel(apDelay),'You must provide one value for spike number and first-spike latency for each trace you specify.');
            
            if isempty(self.recordingActive.ActionPotentialNumber) % TODO : this assumes that all or none are set
                self.recordingActive.ActionPotentialNumber = self.recordingActive.Raw.derive(@(x) zeros(size(x,1),1));
                self.recordingActive.ActionPotentialLatency = self.recordingActive.Raw.derive(@(x) zeros(size(x,1),1));
                self.recordingActive.ActionPotentialDelayArray = self.recordingActive.Raw.derive(@(x) zeros(size(x,1),1));
                self.recordingActive.ActionPotentialOccurrence = self.recordingActive.Raw.derive(@(x) zeros(size(x,1),1));
            end

            self.recordingActive.ActionPotentialNumber.Data(traceNum) = numSpikes;
            self.recordingActive.ActionPotentialLatency.Data(traceNum) = apDelay;
            self.recordingActive.ActionPotentialDelayArray.Data(traceNum,:) = apDelay;
            self.recordingActive.ActionPotentialOccurrence.Data(traceNum) = numSpikes > 0;
            
            set(self.Figure,'Pointer','Arrow');
        end

        function reanalyzeEP_Callback(self,varargin)
            set(self.Figure,'Pointer','Watch');
            
            self.analyzeExcitationProfile(self.recordingActive);
            
            self.array2Dplot(self.recordingActive,find(self.recordings == self.recordingActive),true); %#ok<FNDSB>
            
            set(self.Figure,'Pointer','Arrow');

            % ============= SINGLE PATCH LSPS ANALYSIS =================
        end

        function synapticWindowStart_Callback(hObject, eventdata, handles)
            startVal = str2double(get(handles.synapticWindowStart, 'String'));
            endVal = str2double(get(handles.synapticWindow, 'String'));
            if startVal >= endVal
                warndlg('Value exceeds end of synaptic window', 'Synaptic Window Start');
                return
            else
                handles.data.analysis.synapticWindowStart = str2double(get(handles.synapticWindowStart, 'String'));
                guidata(hObject,handles);
            end
        end
        
        function synThreshold_Callback(hObject, eventdata, handles)
            handles.data.analysis.synThreshold = str2double(get(handles.synThreshold, 'String'));
            % update corresponding pA|mV value in text box
            newVal = handles.data.analysis.synThreshold * str2double(get(handles.baselineSD, 'String'));
            set(handles.synThreshpAmV, 'String', num2str(newVal));
            guidata(hObject,handles);
        end

        function analyzeByTraceAveraging_Callback(self,varargin)
            set(self.Figure,'Pointer','Watch');
            
            self.recordingAverage = mapAnalysis.Recording.average(self.recordings);
            
            self.analyzeInputMap(self.recordingAverage,0,false);
            
            set(self.Figure,'Pointer','Watch');
        end

        function pbGenericBrowse_Callback(self,varargin)
            self.checkForRecordings();
            
            if isempty(self.genericTraceBrowser) || ~isa(self.genericTraceBrowser,'mapAnalysis.genericTraceBrowser')
                self.genericTraceBrowser = mapAnalysis.genericTraceBrowser(self.recordingActive,self,self.genericBrowseType);
            else
                self.genericTraceBrowser.raiseFigure();
                self.genericTraceBrowser.IsBaselineSubtracted = self.genericBrowseType;
                self.genericTraceBrowser.Recording = self.recordingActive;
            end
        end
        
        % ========== Current-Frequency Analysis =================================

        function specifyWhichTraces_Callback(self,varargin)
            traces = inputdlg('Enter Matlab-format vector of which traces to analyze. Example: [1:6]');
            
            if isempty(traces)
                return
            end
            
            self.tracesToAnalyze = str2num(traces{1}); %#ok<ST2NM>
        end

        function setCurrentStepFamily_Callback(self,varargin)
            steps = inputdlg('Enter Matlab-format vector of current step amplitudes for the selected traces. Example: [0:100:500]');
            
            if isempty(steps)
                return
            end
            
            self.Isteps = str2num(steps{1}); %#ok<ST2NM>
        end
        
        % ====================================================================
        
        function runUserFcn_Callback(self,varargin)
            currentDir = pwd;
            
            cd(self.userFunctionFolder);
            
            try
                self.userFunction(self); % o.o

                cd(currentDir);
            catch err
                cd(currentDir);
                
                throw(err);
            end
        end

        function selectUserFcn_Callback(self,varargin)
            filterSpec = [self.codeFolder '\userFcn\*.m'];
            [filename, pathname] = uigetfile(filterSpec); 
            
            if ~ischar(filename)
                return
            end
            
            self.userFunctionFolder = pathname;
            
            [~,functionName,ext] = fileparts(filename);
            
            assert(strcmp(ext,'.m'),'You must choose an M-file');
            
            self.userFunction = str2func(functionName);
        end

        function qvTrace_Callback(hObject, eventdata, handles)
            try
                pname = handles.data.analysis.uncagingPathName;
            catch
                pname = '';
            end
            qvTrace('init', pname);
        end
    end
end
