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
        FigurePath = [fileparts(which('mapalyzer')) '\mapalyzer.fig'];
    end
    
    properties
        Figure;
    end
    
    methods
        function self = mapalyzer(varargin)
            self.Figure = open(mapalyzer.FigurePath); % TODO : figure out a neat way to do the singleton pattern
            
            uicontrols = findobj(self.Figure,'Style','listbox','-or','Style','popupmenu','-or','Style','checkbox','-or','Style','edit');
            
            if ispc
                backgroundColour = 'white';
            else
                backgroundColour = get(0,'defaultUicontrolBackgroundColor');
            end
            
            set(uicontrols,'BackgroundColor',backgroundColour);
            
            for ii = 1:numel(uicontrols)
                prop = addprop(self,get(uicontrols(ii),'Tag'));
                
                prop.Dependent = true;
                prop.GetAccess = 'public';
                
                switch get(uicontrols(ii),'Style')
                    case 'checkbox'
                        prop.GetMethod = @(varargin) self.getCheckboxValue(uicontrols(ii));
                    case 'edit'
                        prop.GetMethod = @(varargin) self.getEditValue(uicontrols(ii));
                    case 'listbox'
                        prop.GetMethod = @(varargin) self.getPopupMenuValue(uicontrols(ii));
                    case 'popupmenu'
                        prop.GetMethod = @(varargin) self.getPopupMenuValue(uicontrols(ii));
                    otherwise
                        prop.GetMethod = @(varargin) NaN;
                end
                
                prop.SetAccess = 'protected';
                prop.SetMethod = @(varargin) self.setUIControlValue();
                
                set(uicontrols(ii),'Callback','');
            end
            
            set(findobj(self.Figure,'Tag','lstbxTraceType'),'Callback',@self.setLoadMethodFromTraceType);
            
            set(get(findobj(self.Figure,'Tag','Help'),'Children'),'Callback',@self.help);
        end
        
        function out = getCheckboxValue(~,checkbox)
            out = get(checkbox,'Value');
        end
        
        function out = getEditValue(~,edit)
            out = get(edit, 'String'); % TODO : is there a neat way of determining which ones should numeric and which should be text?
%             out = str2double(get(edit, 'String'));
        end

        function out = getPopupMenuValue(~,popupmenu)
            str = get(popupmenu, 'String');
            val = get(popupmenu, 'Value');
            out = str{val};
        end
        
        function setUIControlValue(~,varargin)
            error('ShepherdLab:mapalyzer:CantSetUIDependentPropery','You can not set a property whose value is dependent on a uicontrol');
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
        
        function pbLoad_Callback(hObject, eventdata, handles)
            handles = loadSwitchyard(handles);
            guidata(hObject,handles);

            % ================= VIDEO IMAGES ===================================
        end

        function selectVideoImage_Callback(hObject, eventdata, handles)
            handles = chooseImageFile(handles);
            guidata(hObject,handles);
        end

        function displayVideoimages_Callback(hObject, eventdata, handles)
            handles = displayVideoImages(handles);

            % ================= INFO ===================================
        end

        function handles2ws_Callback(hObject, eventdata, handles)
            assignin('base', 'handles', handles);
            disp('Handles variable created in workspace (or overwritten).');

            % ============= DATA M FILE =================
        end

        function createDataMFile_Callback(hObject, eventdata, handles)
            createDataMFile(handles);

            % function evalMfile_Callback(hObject, eventdata, handles)
            % evalin('base', ['currentDataMfile = ' handles.data.analysis.experimentName]);
            % % disp('Evaluated in workspace as ''currentDataMfile'' (contents displayed above).');
            % % disp(' ');
            % get weird error using this -- unable to find file

            % ================= CELL PARAMETERS ========================
        end

        function pbCellParameters_Callback(hObject, eventdata, handles)
            set(handles.figure1,'Pointer','Watch');
            handles.data.analysis.skipCm = 0;
            handles = calcCellParameters(handles);
            plotCellParameters(handles);
            guidata(hObject,handles);
            set(handles.figure1,'Pointer','Arrow');
        end

            % ============= MAP DISPLAY =================

        function arrayTracesAsInputMap_Callback(hObject, eventdata, handles)
            for m = 1 : handles.data.analysis.numberOfMaps
                string = (['handles.data.map.map' num2str(m)]);
                eval(['handles.data.map.mapActive = ' string ';']);
                handles = arrayTracesAsInputMap(handles);
                eval([string ' = handles.data.map.mapActive;']);
            end
            arrayTracesOfMultipleMaps(handles);
        end

        function pbTraceBrowser_Callback(hObject, eventdata, handles)
            % traceBrowser(handles);
            for m = 1 : handles.data.analysis.numberOfMaps
                string = (['handles.data.map.map' num2str(m)]);
                eval(['handles.data.map.mapActive = ' string ';']);
                traceBrowser(handles);
            %     eval([string ' = handles.data.map.mapActive;']); % TODO: get rid of this line?
            end
            % TODO: multi-map traceBrowser
            % traceBrowserOfMultipleMaps(handles);
            try
                handles.data.map.mapActive = handles.data.map.traceAvg;
            %     h = handles.data.map.mapActive.baseName
                traceBrowser(handles);
            catch
            %     disp('mapAnalysis3p4: no trace-averaged data found for display; skipping');
            end

            % ============= EXCITATION PROFILE =================
        end

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

            % =============== MISCELLANEOUS ====================================

            % ============= GENERIC TRACE ANALYSIS =================
        end

        function pbGenericBrowse_Callback(hObject, eventdata, handles)
            traceBrowserGeneric(handles);
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

        function showAutoNotes_Callback(hObject, eventdata, handles)
            % hObject    handle to showAutoNotes (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            showAutoNotesForCurrentExpt(handles);

            % --- Executes on selection change in headerGUIlistbox.
        end
    end
end
