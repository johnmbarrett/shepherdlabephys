classdef mapalyzer < handle
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
        Figure = open([fileparts(which('mapalyzer')) '\mapalyzer.fig']);
    end
    
    methods
        function self = mapalyzer(varargin)
            toBeRecoloured = findobj(self.Figure,'-regexp','Style','listbox|popupmenu|checkbox|edit');
            
            if ispc
                backgroundColour = 'white';
            else
                backgroundColour = get(0,'defaultUicontrolBackgroundColor');
            end
            
            set(toBeRecoloured,'BackgroundColor',backgroundColour);
        end

        function lstbxTraceType_Callback(hObject, eventdata, handles)
            str = get(hObject, 'String');
            val = get(hObject, 'Value');
            if strcmp(str{val}, 'excitation profile')
                str = get(handles.lstbxSelectionType, 'String');
                for n = 1:size(str,1)
                    if findstr(str{n}, 'single map')
                        set(handles.lstbxSelectionType, 'Value', n);
                    end
                end    
            elseif strcmp(str{val}, 'general physiology traces')
                str = get(handles.lstbxSelectionType, 'String');
                for n = 1:size(str,1)
                    if findstr(str{n}, 'selected traces')
                        set(handles.lstbxSelectionType, 'Value', n);
                    end
                end    
            elseif strcmp(str{val}, 'input map')
                str = get(handles.lstbxSelectionType, 'String');
                for n = 1:size(str,1)
                    if findstr(str{n}, 'multiple maps, select manually')
                        set(handles.lstbxSelectionType, 'Value', n);
                    end
                end    
            end
        end

        function popFilterType_Callback(hObject, eventdata, handles)
            str = get(handles.popFilterType, 'String');
            val = get(handles.popFilterType, 'Value');
            handles.data.analysis.popFilterType = str{val};
            guidata(hObject,handles);
        end

        function filterValue_Callback(hObject, eventdata, handles)
            handles.data.analysis.filterValue = str2double(get(handles.filterValue, 'String'));
            guidata(hObject,handles);
        end

        function bsBaselineStart_Callback(hObject, eventdata, handles)
            handles.data.analysis.bsBaselineStart = str2double(get(handles.bsBaselineStart, 'String'));
            guidata(hObject,handles);
        end

        function bsBaselineEnd_Callback(hObject, eventdata, handles)
            handles.data.analysis.bsBaselineEnd = str2double(get(handles.bsBaselineEnd, 'String'));
            guidata(hObject,handles);

            % ---------------------------------------------------------
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

        function somaX_Callback(hObject, eventdata, handles)
            handles.data.acq.somaX = str2double(get(handles.somaX, 'String'));
            guidata(hObject,handles);
        end

        function somaY_Callback(hObject, eventdata, handles)
            handles.data.acq.somaY = str2double(get(handles.somaY, 'String'));
            guidata(hObject,handles);
        end

        function somaZ_Callback(hObject, eventdata, handles)
            handles.data.acq.somaZ = str2double(get(handles.somaZ, 'String'));
            guidata(hObject,handles);
        end

        function cellType_Callback(hObject, eventdata, handles)
            handles.data.analysis.cellType = get(handles.cellType, 'String');
            guidata(hObject,handles);
        end

        function Vrest_Callback(hObject, eventdata, handles)
            handles.data.analysis.Vrest = str2double(get(handles.Vrest, 'String'));
            guidata(hObject,handles);
        end

        function Vhold_Callback(hObject, eventdata, handles)
            handles.data.analysis.Vhold = str2double(get(handles.Vhold, 'String'));
            guidata(hObject,handles);
        end

        function animalAge_Callback(hObject, eventdata, handles)
            handles.data.analysis.animalAge = str2double(get(handles.animalAge, 'String'));
            guidata(hObject,handles);
        end

        function exptCondition_Callback(hObject, eventdata, handles)
            handles.data.analysis.exptCondition = get(handles.exptCondition, 'String');
            guidata(hObject,handles);
        end

        function notes_Callback(hObject, eventdata, handles)
            handles.data.analysis.notes = get(handles.notes, 'String');
            guidata(hObject,handles);
        end

        function fieldAName_Callback(hObject, eventdata, handles)
            handles.data.analysis.fieldAName = get(handles.fieldAName, 'String');
            guidata(hObject,handles);
        end

        function fieldAVal_Callback(hObject, eventdata, handles)
            handles.data.analysis.fieldAVal = get(handles.fieldAVal, 'String');
            guidata(hObject,handles);
        end

        function fieldBName_Callback(hObject, eventdata, handles)
            handles.data.analysis.fieldBName = get(handles.fieldBName, 'String');
            guidata(hObject,handles);
        end

        function fieldBVal_Callback(hObject, eventdata, handles)
            handles.data.analysis.fieldBVal = get(handles.fieldBVal, 'String');
            guidata(hObject,handles);
        end

        function fieldCName_Callback(hObject, eventdata, handles)
            handles.data.analysis.fieldCName = get(handles.fieldCName, 'String');
            guidata(hObject,handles);
        end

        function fieldCVal_Callback(hObject, eventdata, handles)
            handles.data.analysis.fieldCVal = get(handles.fieldCVal, 'String');
            guidata(hObject,handles);
        end

        function fieldDName_Callback(hObject, eventdata, handles)
            handles.data.analysis.fieldDName = get(handles.fieldDName, 'String');
            guidata(hObject,handles);
        end

        function fieldDVal_Callback(hObject, eventdata, handles)
            handles.data.analysis.fieldDVal = get(handles.fieldDVal, 'String');
            guidata(hObject,handles);
        end

        function fieldEName_Callback(hObject, eventdata, handles)
            handles.data.analysis.fieldEName = get(handles.fieldEName, 'String');
            guidata(hObject,handles);
        end

        function fieldEVal_Callback(hObject, eventdata, handles)
            handles.data.analysis.fieldEVal = get(handles.fieldEVal, 'String');
            guidata(hObject,handles);
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

        function rstepOn_Callback(hObject, eventdata, handles)
            handles.data.analysis.rstepOn = str2double(get(handles.rstepOn, 'String'));
            guidata(hObject,handles);
        end

        function rstepDur_Callback(hObject, eventdata, handles)
            handles.data.analysis.rstepDur = str2double(get(handles.rstepDur, 'String'));
            guidata(hObject,handles);
        end

        function rstepAmp_Callback(hObject, eventdata, handles)
            handles.data.analysis.rstepAmp = str2double(get(handles.rstepAmp, 'String'));
            guidata(hObject,handles);
        end

        function rseriesAvg_Callback(hObject, eventdata, handles)
            handles.data.map.mapAvg.rseriesAvg = str2double(get(hObject, 'String'));
            guidata(hObject,handles);
        end

        function cmembraneAvg_Callback(hObject, eventdata, handles)
            handles.data.map.mapAvg.cmembraneAvg = str2double(get(hObject, 'String'));
            guidata(hObject,handles);
        end

        function rmembraneAvg_Callback(hObject, eventdata, handles)
            handles.data.map.mapAvg.rmembraneAvg = str2double(get(hObject, 'String'));
            guidata(hObject,handles);
        end

        function tauAvg_Callback(hObject, eventdata, handles)
            handles.data.map.mapAvg.tauAvg = str2double(get(hObject, 'String'));
            guidata(hObject,handles);
        end

        function pbCellParameters_Callback(hObject, eventdata, handles)
            set(handles.figure1,'Pointer','Watch');
            handles.data.analysis.skipCm = 0;
            handles = calcCellParameters(handles);
            plotCellParameters(handles);
            guidata(hObject,handles);
            set(handles.figure1,'Pointer','Arrow');
        end

        function RsSkipVal_Callback(hObject, eventdata, handles)
            handles.data.analysis.RsSkipVal = str2double(get(handles.RsSkipVal, 'String'));
            guidata(hObject,handles);

            % ============= MAP DISPLAY =================
        end

        function arrayTracesAsInputMap_Callback(hObject, eventdata, handles)
            for m = 1 : handles.data.analysis.numberOfMaps
                string = (['handles.data.map.map' num2str(m)]);
                eval(['handles.data.map.mapActive = ' string ';']);
                handles = arrayTracesAsInputMap(handles);
                eval([string ' = handles.data.map.mapActive;']);
            end
            arrayTracesOfMultipleMaps(handles);
        end

        function traceMapShowStart_Callback(hObject, eventdata, handles)
            handles.data.analysis.traceMapShowStart = str2double(get(handles.traceMapShowStart, 'String'));
            guidata(hObject,handles);
        end

        function traceMapShowStop_Callback(hObject, eventdata, handles)
            handles.data.analysis.traceMapShowStop = str2double(get(handles.traceMapShowStop, 'String'));
            guidata(hObject,handles);
        end

        function traceMapYFactor_Callback(hObject, eventdata, handles)
            handles.data.analysis.traceMapYFactor = str2double(get(handles.traceMapYFactor, 'String'));
            guidata(hObject,handles);
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

        function stimOnEP_Callback(hObject, eventdata, handles)
            handles.data.analysis.stimOnEP = str2double(get(handles.stimOnEP, 'String'));
            guidata(hObject,handles);
        end

        function baselineStartEP_Callback(hObject, eventdata, handles)
            handles.data.analysis.baselineStartEP = str2double(get(handles.baselineStartEP, 'String'));
            guidata(hObject,handles);
        end

        function baselineEndEP_Callback(hObject, eventdata, handles)
            handles.data.analysis.baselineEndEP = str2double(get(handles.baselineEndEP, 'String'));
            guidata(hObject,handles);
        end

        function responseStartEP_Callback(hObject, eventdata, handles)
            handles.data.analysis.responseStartEP = str2double(get(handles.responseStartEP, 'String'));
            guidata(hObject,handles);
        end

        function responseDurEP_Callback(hObject, eventdata, handles)
            handles.data.analysis.responseDurEP = str2double(get(handles.responseDurEP, 'String'));
            guidata(hObject,handles);
        end

        function apThreshold_Callback(hObject, eventdata, handles)
            handles.data.analysis.apThreshold = str2double(get(handles.apThreshold, 'String'));
            guidata(hObject,handles);

            a = handles.data.analysis.apThreshold;
        end
        
        function eventPolarityAP_Callback(hObject, eventdata, handles)
            str = get(handles.eventPolarityAP, 'String');
            val = get(handles.eventPolarityAP, 'Value');
            handles.data.analysis.eventPolarityAP = str{val};
            guidata(hObject,handles);
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

        function stimOn_Callback(hObject, eventdata, handles)
            handles.data.analysis.stimOn = str2double(get(handles.stimOn, 'String'));
            guidata(hObject,handles);
        end

        function baselineStart_Callback(hObject, eventdata, handles)
            handles.data.analysis.baselineStart = str2double(get(handles.baselineStart, 'String'));
            guidata(hObject,handles);
        end

        function directWindowStart_Callback(hObject, eventdata, handles)
            handles.data.analysis.directWindowStart = str2double(get(handles.directWindowStart, 'String'));
            guidata(hObject,handles);
        end

        function baselineEnd_Callback(hObject, eventdata, handles)
            handles.data.analysis.baselineEnd = str2double(get(handles.baselineEnd, 'String'));
            guidata(hObject,handles);
        end

        function directWindow_Callback(hObject, eventdata, handles)
            handles.data.analysis.directWindow = str2double(get(handles.directWindow, 'String'));
            guidata(hObject,handles);
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

        function synapticWindow_Callback(hObject, eventdata, handles)
            handles.data.analysis.synapticWindow = str2double(get(handles.synapticWindow, 'String'));
            guidata(hObject,handles);
        end

        function fourthWindowStart_Callback(hObject, eventdata, handles)
            handles.data.analysis.fourthWindowStart = str2double(get(handles.fourthWindowStart, 'String'));
            guidata(hObject,handles);
        end

        function fourthWindow_Callback(hObject, eventdata, handles)
            handles.data.analysis.fourthWindow = str2double(get(handles.fourthWindow, 'String'));
            guidata(hObject,handles);
        end

        function eventPolaritySyn_Callback(hObject, eventdata, handles)
            str = get(handles.eventPolaritySyn, 'String');
            val = get(handles.eventPolaritySyn, 'Value');
            handles.data.analysis.eventPolaritySyn = str{val};
            guidata(hObject,handles);
        end

        function synDuration_Callback(hObject, eventdata, handles)
            handles.data.analysis.synDuration = str2double(get(handles.synDuration, 'String'));
            guidata(hObject,handles);
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

        function stimOnGen_Callback(hObject, eventdata, handles)
            handles.data.analysis.stimOnGen = str2double(get(handles.stimOnGen, 'String'));
            guidata(hObject,handles);
        end

        function pbGenericBrowse_Callback(hObject, eventdata, handles)
            traceBrowserGeneric(handles);

            % --- HELP -----------------------------------------------------------------
        end

        function helpOverview_Callback(hObject, eventdata, handles)
            type helpOverview;
        end

        function helpLoading_Callback(hObject, eventdata, handles)
            type helpLoading;
        end

        function helpVideo_Callback(hObject, eventdata, handles)
            type helpVideo;
        end

        function helpParameters_Callback(hObject, eventdata, handles)
            type helpParameters;
        end

        function helpInformation_Callback(hObject, eventdata, handles)
            type helpInformation;
        end

        function helpInputMapAnalysis_Callback(hObject, eventdata, handles)
            type helpInputMapAnalysis;
        end

        function helpExcitationProfile_Callback(hObject, eventdata, handles)
            type helpExcitationProfile;
        end

        function helpDisplay_Callback(hObject, eventdata, handles)
            type helpDisplay;
        end

        function helpGeneric_Callback(hObject, eventdata, handles)
            type helpGeneric;
        end

        function helpCurrentFrequencyAnalysis_Callback(hObject, eventdata, handles)
            type helpCurrentFrequencyAnalysis;
        end

        function dataMFiles_Callback(hObject, eventdata, handles)
            type helpDataMFiles;
        end

        function General_Callback(hObject, eventdata, handles)
            type helpMapAnalysis;

            % ========== Current-Frequency Analysis =================================
        end

        function currentStepStart_Callback(hObject, eventdata, handles)
            handles.data.analysis.currentStepStart = str2double(get(handles.currentStepStart, 'String'));
            guidata(hObject,handles);
        end

        function currentStepDuration_Callback(hObject, eventdata, handles)
            handles.data.analysis.currentStepDuration = str2double(get(handles.currentStepDuration, 'String'));
            guidata(hObject,handles);
        end

        function spikeThreshold_Callback(hObject, eventdata, handles)
            handles.data.analysis.spikeThreshold = str2double(get(handles.spikeThreshold, 'String'));
            guidata(hObject,handles);
        end

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

        function somaXnew_Callback(hObject, eventdata, handles)
            handles.data.acq.somaXnew = str2double(get(handles.somaXnew, 'String'));
            guidata(hObject,handles);
        end

        function somaYnew_Callback(hObject, eventdata, handles)
            handles.data.acq.somaYnew = str2double(get(handles.somaYnew, 'String'));
            guidata(hObject,handles);
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
