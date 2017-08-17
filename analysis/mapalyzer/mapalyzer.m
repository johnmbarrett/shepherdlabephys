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
    methods
        function self = mapalyzer(varargin)
            gui_Singleton = 1;
            gui_State = struct('gui_Name',       mfilename, ...
                               'gui_Singleton',  gui_Singleton, ...
                               'gui_OpeningFcn', @mapalyzer_OpeningFcn, ...
                               'gui_OutputFcn',  @mapalyzer_OutputFcn, ...
                               'gui_LayoutFcn',  [] , ...
                               'gui_Callback',   []);
            if nargin && ischar(varargin{1})
                gui_State.gui_Callback = str2func(varargin{1});
            end

            if nargout
                [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
            else
                gui_mainfcn(gui_State, varargin{:});
            end
            % End initialization code - DO NOT EDIT

            % --- Executes just before mapalyzer is made visible.
        end

        function mapalyzer_OpeningFcn(hObject, eventdata, handles, varargin)
            % This function has no output args, see OutputFcn.
            % hObject    handle to figure
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            % varargin   command line arguments to mapalyzer (see VARARGIN)

            % Choose default command line output for mapalyzer
            handles.output = hObject;

            % Update handles structure
            guidata(hObject, handles);

            % UIWAIT makes mapalyzer wait for user response (see UIRESUME)
            % uiwait(handles.figure1);

            % INITIALIZE the analysis parameters
            handles = initializeAnalysisParameters(handles);
            guidata(hObject, handles);

            % --- Outputs from this function are returned to the command line.
        end

        function varargout = mapalyzer_OutputFcn(hObject, eventdata, handles)
            % varargout  cell array for returning output args (see VARARGOUT);
            % hObject    handle to figure
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)

            % Get default command line output from handles structure
            varargout{1} = handles.output;

            % ================= LOAD OPTIONS ==========================
        end

        function lstbxTraceType_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
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

        function lstbxSelectionType_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function lstbxSelectionType_Callback(hObject, eventdata, handles)
        end

        function chkFilter_Callback(hObject, eventdata, handles)
        end

        function popFilterType_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function popFilterType_Callback(hObject, eventdata, handles)
            str = get(handles.popFilterType, 'String');
            val = get(handles.popFilterType, 'Value');
            handles.data.analysis.popFilterType = str{val};
            guidata(hObject,handles);
        end

        function filterValue_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function filterValue_Callback(hObject, eventdata, handles)
            handles.data.analysis.filterValue = str2double(get(handles.filterValue, 'String'));
            guidata(hObject,handles);
        end

        function chkBaselineSubtract_Callback(hObject, eventdata, handles)
        end

        function bsBaselineStart_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function bsBaselineStart_Callback(hObject, eventdata, handles)
            handles.data.analysis.bsBaselineStart = str2double(get(handles.bsBaselineStart, 'String'));
            guidata(hObject,handles);
        end

        function bsBaselineEnd_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
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

        function experimentName_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function experimentName_Callback(hObject, eventdata, handles)
        end

        function experimentDate_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function experimentDate_Callback(hObject, eventdata, handles)
        end

        function breakInTime_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function breakInTime_Callback(hObject, eventdata, handles)
        end

        function triggerTime_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function triggerTime_Callback(hObject, eventdata, handles)
        end

        function numberOfMaps_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function numberOfMaps_Callback(hObject, eventdata, handles)
        end

        function mapNumbers_CreateFcn(hObject, eventdata, handles)

            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function mapNumbers_Callback(hObject, eventdata, handles)
        end

        function clampMode_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function clampMode_Callback(hObject, eventdata, handles)
        end

        function laserIntensity_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function laserIntensity_Callback(hObject, eventdata, handles)
        end

        function mapSpacing_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function mapSpacing_Callback(hObject, eventdata, handles)
        end

        function somaX_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function somaX_Callback(hObject, eventdata, handles)
            handles.data.acq.somaX = str2double(get(handles.somaX, 'String'));
            guidata(hObject,handles);
        end

        function somaY_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function somaY_Callback(hObject, eventdata, handles)
            handles.data.acq.somaY = str2double(get(handles.somaY, 'String'));
            guidata(hObject,handles);
        end

        function somaZ_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function somaZ_Callback(hObject, eventdata, handles)
            handles.data.acq.somaZ = str2double(get(handles.somaZ, 'String'));
            guidata(hObject,handles);
        end

        function cellType_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function cellType_Callback(hObject, eventdata, handles)
            handles.data.analysis.cellType = get(handles.cellType, 'String');
            guidata(hObject,handles);
        end

        function Vrest_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function Vrest_Callback(hObject, eventdata, handles)
            handles.data.analysis.Vrest = str2double(get(handles.Vrest, 'String'));
            guidata(hObject,handles);
        end

        function Vhold_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function Vhold_Callback(hObject, eventdata, handles)
            handles.data.analysis.Vhold = str2double(get(handles.Vhold, 'String'));
            guidata(hObject,handles);
        end

        function animalAge_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function animalAge_Callback(hObject, eventdata, handles)
            handles.data.analysis.animalAge = str2double(get(handles.animalAge, 'String'));
            guidata(hObject,handles);
        end

        function exptCondition_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function exptCondition_Callback(hObject, eventdata, handles)
            handles.data.analysis.exptCondition = get(handles.exptCondition, 'String');
            guidata(hObject,handles);
        end

        function notes_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function notes_Callback(hObject, eventdata, handles)
            handles.data.analysis.notes = get(handles.notes, 'String');
            guidata(hObject,handles);
        end

        function fieldAName_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function fieldAName_Callback(hObject, eventdata, handles)
            handles.data.analysis.fieldAName = get(handles.fieldAName, 'String');
            guidata(hObject,handles);
        end

        function fieldAVal_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function fieldAVal_Callback(hObject, eventdata, handles)
            handles.data.analysis.fieldAVal = get(handles.fieldAVal, 'String');
            guidata(hObject,handles);
        end

        function fieldBName_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function fieldBName_Callback(hObject, eventdata, handles)
            handles.data.analysis.fieldBName = get(handles.fieldBName, 'String');
            guidata(hObject,handles);
        end

        function fieldBVal_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function fieldBVal_Callback(hObject, eventdata, handles)
            handles.data.analysis.fieldBVal = get(handles.fieldBVal, 'String');
            guidata(hObject,handles);
        end

        function fieldCName_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function fieldCName_Callback(hObject, eventdata, handles)
            handles.data.analysis.fieldCName = get(handles.fieldCName, 'String');
            guidata(hObject,handles);
        end

        function fieldCVal_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function fieldCVal_Callback(hObject, eventdata, handles)
            handles.data.analysis.fieldCVal = get(handles.fieldCVal, 'String');
            guidata(hObject,handles);
        end

        function fieldDName_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function fieldDName_Callback(hObject, eventdata, handles)
            handles.data.analysis.fieldDName = get(handles.fieldDName, 'String');
            guidata(hObject,handles);
        end

        function fieldDVal_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function fieldDVal_Callback(hObject, eventdata, handles)
            handles.data.analysis.fieldDVal = get(handles.fieldDVal, 'String');
            guidata(hObject,handles);
        end

        function fieldEName_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function fieldEName_Callback(hObject, eventdata, handles)
            handles.data.analysis.fieldEName = get(handles.fieldEName, 'String');
            guidata(hObject,handles);
        end

        function fieldEVal_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
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

        function rstepOn_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function rstepOn_Callback(hObject, eventdata, handles)
            handles.data.analysis.rstepOn = str2double(get(handles.rstepOn, 'String'));
            guidata(hObject,handles);
        end

        function rstepDur_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function rstepDur_Callback(hObject, eventdata, handles)
            handles.data.analysis.rstepDur = str2double(get(handles.rstepDur, 'String'));
            guidata(hObject,handles);
        end

        function rstepAmp_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function rstepAmp_Callback(hObject, eventdata, handles)
            handles.data.analysis.rstepAmp = str2double(get(handles.rstepAmp, 'String'));
            guidata(hObject,handles);
        end

        function rseriesAvg_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function rseriesAvg_Callback(hObject, eventdata, handles)
            handles.data.map.mapAvg.rseriesAvg = str2double(get(hObject, 'String'));
            guidata(hObject,handles);
        end

        function cmembraneAvg_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function cmembraneAvg_Callback(hObject, eventdata, handles)
            handles.data.map.mapAvg.cmembraneAvg = str2double(get(hObject, 'String'));
            guidata(hObject,handles);
        end

        function rmembraneAvg_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function rmembraneAvg_Callback(hObject, eventdata, handles)
            handles.data.map.mapAvg.rmembraneAvg = str2double(get(hObject, 'String'));
            guidata(hObject,handles);
        end

        function tauAvg_Callback(hObject, eventdata, handles)
            handles.data.map.mapAvg.tauAvg = str2double(get(hObject, 'String'));
            guidata(hObject,handles);
        end

        function tauAvg_CreateFcn(hObject, eventdata, handles)
            if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
                set(hObject,'BackgroundColor','white');
            end
        end

        function pbCellParameters_Callback(hObject, eventdata, handles)
            set(handles.figure1,'Pointer','Watch');
            handles.data.analysis.skipCm = 0;
            handles = calcCellParameters(handles);
            plotCellParameters(handles);
            guidata(hObject,handles);
            set(handles.figure1,'Pointer','Arrow');
        end

        function RsSkipVal_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
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

        function traceMapShowStart_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function traceMapShowStart_Callback(hObject, eventdata, handles)
            handles.data.analysis.traceMapShowStart = str2double(get(handles.traceMapShowStart, 'String'));
            guidata(hObject,handles);
        end

        function traceMapShowStop_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function traceMapShowStop_Callback(hObject, eventdata, handles)
            handles.data.analysis.traceMapShowStop = str2double(get(handles.traceMapShowStop, 'String'));
            guidata(hObject,handles);
        end

        function traceMapYFactor_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
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

        function stimOnEP_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function stimOnEP_Callback(hObject, eventdata, handles)
            handles.data.analysis.stimOnEP = str2double(get(handles.stimOnEP, 'String'));
            guidata(hObject,handles);
        end

        function baselineStartEP_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function baselineStartEP_Callback(hObject, eventdata, handles)
            handles.data.analysis.baselineStartEP = str2double(get(handles.baselineStartEP, 'String'));
            guidata(hObject,handles);
        end

        function baselineEndEP_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function baselineEndEP_Callback(hObject, eventdata, handles)
            handles.data.analysis.baselineEndEP = str2double(get(handles.baselineEndEP, 'String'));
            guidata(hObject,handles);
        end

        function responseStartEP_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function responseStartEP_Callback(hObject, eventdata, handles)
            handles.data.analysis.responseStartEP = str2double(get(handles.responseStartEP, 'String'));
            guidata(hObject,handles);
        end

        function responseDurEP_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function responseDurEP_Callback(hObject, eventdata, handles)
            handles.data.analysis.responseDurEP = str2double(get(handles.responseDurEP, 'String'));
            guidata(hObject,handles);
        end

        function apThreshold_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function apThreshold_Callback(hObject, eventdata, handles)
            handles.data.analysis.apThreshold = str2double(get(handles.apThreshold, 'String'));
            guidata(hObject,handles);

            a = handles.data.analysis.apThreshold;
        end

        function eventPolarityAP_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
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

        function stimOn_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function stimOn_Callback(hObject, eventdata, handles)
            handles.data.analysis.stimOn = str2double(get(handles.stimOn, 'String'));
            guidata(hObject,handles);
        end

        function baselineStart_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function baselineStart_Callback(hObject, eventdata, handles)
            handles.data.analysis.baselineStart = str2double(get(handles.baselineStart, 'String'));
            guidata(hObject,handles);
        end

        function directWindowStart_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function directWindowStart_Callback(hObject, eventdata, handles)
            handles.data.analysis.directWindowStart = str2double(get(handles.directWindowStart, 'String'));
            guidata(hObject,handles);
        end

        function baselineEnd_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function baselineEnd_Callback(hObject, eventdata, handles)
            handles.data.analysis.baselineEnd = str2double(get(handles.baselineEnd, 'String'));
            guidata(hObject,handles);
        end

        function directWindow_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function directWindow_Callback(hObject, eventdata, handles)
            handles.data.analysis.directWindow = str2double(get(handles.directWindow, 'String'));
            guidata(hObject,handles);
        end

        function synapticWindowStart_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
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

        function synapticWindow_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function synapticWindow_Callback(hObject, eventdata, handles)
            handles.data.analysis.synapticWindow = str2double(get(handles.synapticWindow, 'String'));
            guidata(hObject,handles);
        end

        function fourthWindowStart_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function fourthWindowStart_Callback(hObject, eventdata, handles)
            handles.data.analysis.fourthWindowStart = str2double(get(handles.fourthWindowStart, 'String'));
            guidata(hObject,handles);
        end

        function fourthWindow_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function fourthWindow_Callback(hObject, eventdata, handles)
            handles.data.analysis.fourthWindow = str2double(get(handles.fourthWindow, 'String'));
            guidata(hObject,handles);
        end

        function eventPolaritySyn_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function eventPolaritySyn_Callback(hObject, eventdata, handles)
            str = get(handles.eventPolaritySyn, 'String');
            val = get(handles.eventPolaritySyn, 'Value');
            handles.data.analysis.eventPolaritySyn = str{val};
            guidata(hObject,handles);
        end

        function synDuration_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function synDuration_Callback(hObject, eventdata, handles)
            handles.data.analysis.synDuration = str2double(get(handles.synDuration, 'String'));
            guidata(hObject,handles);
        end

        function methodInputMap_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function methodInputMap_Callback(hObject, eventdata, handles)
        end

        function synThreshold_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function synThreshold_Callback(hObject, eventdata, handles)
            handles.data.analysis.synThreshold = str2double(get(handles.synThreshold, 'String'));
            % update corresponding pA|mV value in text box
            newVal = handles.data.analysis.synThreshold * str2double(get(handles.baselineSD, 'String'));
            set(handles.synThreshpAmV, 'String', num2str(newVal));
            guidata(hObject,handles);
        end

        function synThreshpAmV_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function synThreshpAmV_Callback(hObject, eventdata, handles)
        end

        function baselineSD_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function baselineSD_Callback(hObject, eventdata, handles)
        end

        function spontEventRate_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function spontEventRate_Callback(hObject, eventdata, handles)
        end

        function analyzeInputMap_Callback(hObject, eventdata, handles)
            set(handles.figure1,'Pointer','Watch');
            handles = analysisHandler(handles);
            guidata(hObject, handles);
            set(handles.figure1,'Pointer','Arrow');
        end

        function chkShowHistoAnalysis_Callback(hObject, eventdata, handles)
        end

        function chkWithRsRm_Callback(hObject, eventdata, handles)
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

        function stimOnGen_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function stimOnGen_Callback(hObject, eventdata, handles)
            handles.data.analysis.stimOnGen = str2double(get(handles.stimOnGen, 'String'));
            guidata(hObject,handles);
        end

        function genericBrowseType_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function genericBrowseType_Callback(hObject, eventdata, handles)
            % Hints: contents = get(hObject,'String') returns genericBrowseType contents as cell array
            %        contents{get(hObject,'Value')} returns selected item from genericBrowseType
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

        function currentStepStart_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function currentStepStart_Callback(hObject, eventdata, handles)
            handles.data.analysis.currentStepStart = str2double(get(handles.currentStepStart, 'String'));
            guidata(hObject,handles);
        end

        function currentStepDuration_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function currentStepDuration_Callback(hObject, eventdata, handles)
            handles.data.analysis.currentStepDuration = str2double(get(handles.currentStepDuration, 'String'));
            guidata(hObject,handles);
        end

        function spikeThreshold_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
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

        function somaXnew_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function somaXnew_Callback(hObject, eventdata, handles)
            handles.data.acq.somaXnew = str2double(get(handles.somaXnew, 'String'));
            guidata(hObject,handles);
        end

        function somaYnew_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function somaYnew_Callback(hObject, eventdata, handles)
            handles.data.acq.somaYnew = str2double(get(handles.somaYnew, 'String'));
            guidata(hObject,handles);
        end

        function mapSpacingY_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function mapSpacingY_Callback(hObject, eventdata, handles)
        end

        function mapRot90_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function mapRot90_Callback(hObject, eventdata, handles)
        end

        function xPatternOffset_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function xPatternOffset_Callback(hObject, eventdata, handles)
        end

        function yPatternOffset_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function yPatternOffset_Callback(hObject, eventdata, handles)
        end

        function mapFlip_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function mapFlip_Callback(hObject, eventdata, handles)
        end

        function spatialRotation_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function spatialRotation_Callback(hObject, eventdata, handles)
        end

        function mapPatternName_CreateFcn(hObject, eventdata, handles)
            if ispc
                set(hObject,'BackgroundColor','white');
            else
                set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
            end
        end

        function mapPatternName_Callback(hObject, eventdata, handles)
        end

        function fourthWindowMaps_Callback(hObject, eventdata, handles)

            % -------------------------------------------------------------------------
        end

        function retainForNextCell_Callback(hObject, eventdata, handles)
        end

        function retainForNextCell_CreateFcn(hObject, eventdata, handles)

            % -------------------------------------------------------------------------
        end

        function userFcn_Callback(hObject, eventdata, handles)
        end

        function userFcn_CreateFcn(hObject, eventdata, handles)
            if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
                set(hObject,'BackgroundColor','white');
            end
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

        function runUserFcn_CreateFcn(hObject, eventdata, handles)
        end

        function selectUserFcn_Callback(hObject, eventdata, handles)
            cd([fileparts(which('mapalyzer')) '\userFcn']);
            [f, p] = uigetfile; if f == 0; return; end
            [fpath, fname] = fileparts([p f]);
            set(handles.userFcn, 'String', fname);
        end

        function fieldFName_Callback(hObject, eventdata, handles)
            % hObject    handle to fieldFName (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)

            % Hints: get(hObject,'String') returns contents of fieldFName as text
            %        str2double(get(hObject,'String')) returns contents of fieldFName as a double

            % --- Executes during object creation, after setting all properties.
        end

        function fieldFName_CreateFcn(hObject, eventdata, handles)
            % hObject    handle to fieldFName (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    empty - handles not created until after all CreateFcns called

            % Hint: edit controls usually have a white background on Windows.
            %       See ISPC and COMPUTER.
            if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
                set(hObject,'BackgroundColor','white');
            end
        end

        function fieldFVal_Callback(hObject, eventdata, handles)
            % hObject    handle to fieldFVal (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)

            % Hints: get(hObject,'String') returns contents of fieldFVal as text
            %        str2double(get(hObject,'String')) returns contents of fieldFVal as a double

            % --- Executes during object creation, after setting all properties.
        end

        function fieldFVal_CreateFcn(hObject, eventdata, handles)
            % hObject    handle to fieldFVal (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    empty - handles not created until after all CreateFcns called

            % Hint: edit controls usually have a white background on Windows.
            %       See ISPC and COMPUTER.
            if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
                set(hObject,'BackgroundColor','white');
            end
        end

        function fieldGName_Callback(hObject, eventdata, handles)
            % hObject    handle to fieldGName (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)

            % Hints: get(hObject,'String') returns contents of fieldGName as text
            %        str2double(get(hObject,'String')) returns contents of fieldGName as a double

            % --- Executes during object creation, after setting all properties.
        end

        function fieldGName_CreateFcn(hObject, eventdata, handles)
            % hObject    handle to fieldGName (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    empty - handles not created until after all CreateFcns called

            % Hint: edit controls usually have a white background on Windows.
            %       See ISPC and COMPUTER.
            if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
                set(hObject,'BackgroundColor','white');
            end
        end

        function fieldGVal_Callback(hObject, eventdata, handles)
            % hObject    handle to fieldGVal (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)

            % Hints: get(hObject,'String') returns contents of fieldGVal as text
            %        str2double(get(hObject,'String')) returns contents of fieldGVal as a double

            % --- Executes during object creation, after setting all properties.
        end

        function fieldGVal_CreateFcn(hObject, eventdata, handles)
            % hObject    handle to fieldGVal (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    empty - handles not created until after all CreateFcns called

            % Hint: edit controls usually have a white background on Windows.
            %       See ISPC and COMPUTER.
            if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
                set(hObject,'BackgroundColor','white');
            end
        end

        function fieldHName_Callback(hObject, eventdata, handles)
            % hObject    handle to fieldHName (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)

            % Hints: get(hObject,'String') returns contents of fieldHName as text
            %        str2double(get(hObject,'String')) returns contents of fieldHName as a double

            % --- Executes during object creation, after setting all properties.
        end

        function fieldHName_CreateFcn(hObject, eventdata, handles)
            % hObject    handle to fieldHName (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    empty - handles not created until after all CreateFcns called

            % Hint: edit controls usually have a white background on Windows.
            %       See ISPC and COMPUTER.
            if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
                set(hObject,'BackgroundColor','white');
            end
        end

        function fieldHVal_Callback(hObject, eventdata, handles)
            % hObject    handle to fieldHVal (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)

            % Hints: get(hObject,'String') returns contents of fieldHVal as text
            %        str2double(get(hObject,'String')) returns contents of fieldHVal as a double

            % --- Executes during object creation, after setting all properties.
        end

        function fieldHVal_CreateFcn(hObject, eventdata, handles)
            % hObject    handle to fieldHVal (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    empty - handles not created until after all CreateFcns called

            % Hint: edit controls usually have a white background on Windows.
            %       See ISPC and COMPUTER.
            if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
                set(hObject,'BackgroundColor','white');
            end
        end

        function edit86_Callback(hObject, eventdata, handles)
            % hObject    handle to edit86 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)

            % Hints: get(hObject,'String') returns contents of edit86 as text
            %        str2double(get(hObject,'String')) returns contents of edit86 as a double

            % --- Executes during object creation, after setting all properties.
        end

        function edit86_CreateFcn(hObject, eventdata, handles)
            % hObject    handle to edit86 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    empty - handles not created until after all CreateFcns called

            % Hint: edit controls usually have a white background on Windows.
            %       See ISPC and COMPUTER.
            if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
                set(hObject,'BackgroundColor','white');
            end
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

        function headerGUIlistbox_Callback(hObject, eventdata, handles)
            % hObject    handle to headerGUIlistbox (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)

            % Hints: contents = get(hObject,'String') returns headerGUIlistbox contents as cell array
            %        contents{get(hObject,'Value')} returns selected item from headerGUIlistbox

            % --- Executes during object creation, after setting all properties.
        end

        function headerGUIlistbox_CreateFcn(hObject, eventdata, handles)
            % hObject    handle to headerGUIlistbox (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    empty - handles not created until after all CreateFcns called

            % Hint: listbox controls usually have a white background on Windows.
            %       See ISPC and COMPUTER.
            if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
                set(hObject,'BackgroundColor','white');
            end
        end

        function headerGUItextbox_Callback(hObject, eventdata, handles)
            % hObject    handle to headerGUItextbox (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)

            % Hints: get(hObject,'String') returns contents of headerGUItextbox as text
            %        str2double(get(hObject,'String')) returns contents of headerGUItextbox as a double

            % --- Executes during object creation, after setting all properties.
        end

        function headerGUItextbox_CreateFcn(hObject, eventdata, handles)
            % hObject    handle to headerGUItextbox (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    empty - handles not created until after all CreateFcns called

            % Hint: edit controls usually have a white background on Windows.
            %       See ISPC and COMPUTER.
            if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
                set(hObject,'BackgroundColor','white');
            end

            % --- Executes on selection change in aiProgram.
        end

        function aiProgram_Callback(hObject, eventdata, handles)
            % hObject    handle to aiProgram (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)

            % Hints: contents = get(hObject,'String') returns aiProgram contents as cell array
            %        contents{get(hObject,'Value')} returns selected item from aiProgram

            % --- Executes during object creation, after setting all properties.
        end

        function aiProgram_CreateFcn(hObject, eventdata, handles)
            % hObject    handle to aiProgram (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    empty - handles not created until after all CreateFcns called

            % Hint: popupmenu controls usually have a white background on Windows.
            %       See ISPC and COMPUTER.
            if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
                set(hObject,'BackgroundColor','white');
            end

            % --- Executes on selection change in aiTraceNum.
        end

        function aiTraceNum_Callback(hObject, eventdata, handles)
            % hObject    handle to aiTraceNum (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)

            % Hints: contents = get(hObject,'String') returns aiTraceNum contents as cell array
            %        contents{get(hObject,'Value')} returns selected item from aiTraceNum

            % --- Executes during object creation, after setting all properties.
        end

        function aiTraceNum_CreateFcn(hObject, eventdata, handles)
            % hObject    handle to aiTraceNum (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    empty - handles not created until after all CreateFcns called

            % Hint: popupmenu controls usually have a white background on Windows.
            %       See ISPC and COMPUTER.
            if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
                set(hObject,'BackgroundColor','white');
            end
        end
end
