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
        FigurePath = [fileparts(which('mapAnalysis.mapalyzer')) '\mapalyzer.fig'];
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
        recordingActive
        mapAvg = struct('baselineSD',[],'cmembrane',[],'rmembrane',[],'rseries',[],'spontEventRate',[],'synThreshpAmV',[],'tau',[]);
        recordings
        patchChannel
        sampleRate
        traceBrowsers
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
            
            % TODO : can I alter the figure itself to have these always be
            % the default callbacks?
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
        
        function help(~,menuItem,varargin)
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
            
            type([fileparts(which('mapalyzer')) '\helpFiles\' helpFile]);
        end

        function setLoadMethodFromTraceType(self,hObject,varargin)
            traceType = get(hObject, 'String');
            chosenTraceType = get(hObject, 'Value');
            
            switch traceType{chosenTraceType}
                case 'excitation profile' 
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
                    self.traceBrowsers(ii).raiseFigure();
                    self.traceBrowsers(ii).Map = theRecordings(ii);
                end
            end
        end
        
        % ============= EXCITATION PROFILE =================

        function analyzeEP_Callback(hObject, eventdata, handles)
            set(handles.figure1,'Pointer','Watch');
            handles = analyzeEPArray(handles);
            guidata(hObject, handles);
            set(handles.figure1,'Pointer','Arrow');
        end

        function detectAPs_Callback(hObject, eventdata, handles)
            set(handles.figure1,'Pointer','Watch');
            handles = analyzeEPArray_detectAPs(handles);
            guidata(hObject, handles);
            set(handles.figure1,'Pointer','Arrow');
        end

        function editEP_Callback(hObject, eventdata, handles)
            set(handles.figure1,'Pointer','Watch');
            handles = analyzeEPArray_editEP(handles);
            guidata(hObject, handles);
            set(handles.figure1,'Pointer','Arrow');
        end

        function reanalyzeEP_Callback(hObject, eventdata, handles)
            set(handles.figure1,'Pointer','Watch');
            handles = analyzeEPArray_afterEdit(handles);
            guidata(hObject, handles);
            set(handles.figure1,'Pointer','Arrow');

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

        function analyzeInputMap_Callback(hObject, eventdata, handles)
            set(handles.figure1,'Pointer','Watch');
            handles = analysisHandler(handles);
            guidata(hObject, handles);
            set(handles.figure1,'Pointer','Arrow');
        end

        function analyzeByTraceAveraging_Callback(hObject, eventdata, handles)
            % if get(handles.traceAveraging, 'Value')
            set(handles.figure1,'Pointer','Watch');
            handles = analysisHandlerForTraceAvg(handles);
            guidata(hObject, handles);
            set(handles.figure1,'Pointer','Arrow');
            % end
        end

        function pbGenericBrowse_Callback(self,varargin)
            self.checkForRecordings();
            
            if isempty(self.genericTraceBrowser) || ~isa(self.genericTraceBrowser,'mapAnalysis.genericTraceBrowser')
                self.genericTraceBrowser = mapAnalysis.genericTraceBrowser(self.recordingActive,self,self.genericBrowseType);
            else
                self.genericTraceBrowser.raiseFigure();
                self.genericTraceBrowser.IsBaselineSubtracted = self.genericBrowseType;
                self.genericTraceBrowser.Map = self.recordingActive;
            end
        end
        
        % ========== Current-Frequency Analysis =================================

        function specifyWhichTraces_Callback(hObject, eventdata, handles)
            tracesToAnalyze = inputdlg('Enter Matlab-format vector of which traces to analyze. Example: [1:6]');
            if ~isempty(tracesToAnalyze)
                handles.data.analysis.currentFrequencyAnalysis.tracesToAnalyze = str2num(tracesToAnalyze{1});
                disp(['These traces have been selected for analysis: ' ...
                        num2str(handles.data.analysis.currentFrequencyAnalysis.tracesToAnalyze)]);
            else
                disp('User cancelled.');
            end
            guidata(hObject, handles);
        end

        function setCurrentStepFamily_Callback(hObject, eventdata, handles)
            Isteps = inputdlg('Enter Matlab-format vector of current step amplitudes for the selected traces. Example: [0:100:500]');
            if ~isempty(Isteps)
                handles.data.analysis.currentFrequencyAnalysis.Isteps = str2num(Isteps{1});
                disp(['These current steps have been selected: ' ...
                        num2str(handles.data.analysis.currentFrequencyAnalysis.Isteps)]);
            else
                disp('User cancelled.');
            end
            guidata(hObject, handles);
        end

        function analyzeFI_Callback(hObject, eventdata, handles)
            handles = currentFrequencyAnalysis(handles);
            guidata(hObject, handles);
            % ====================================================================
        end

        function runUserFcn_Callback(hObject, eventdata, handles)
            try
                userFcnName = get(handles.userFcn, 'String');
                eval(['handles = ' userFcnName '(handles);']);
                guidata(hObject,handles);
            catch
                disp('Problem with userFcn.')
            end
        end

        function selectUserFcn_Callback(hObject, eventdata, handles)
            cd([fileparts(which('mapalyzer')) '\userFcn']);
            [f, p] = uigetfile; if f == 0; return; end
            [fpath, fname] = fileparts([p f]);
            set(handles.userFcn, 'String', fname);
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
