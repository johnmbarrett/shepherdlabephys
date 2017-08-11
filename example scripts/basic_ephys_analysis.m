function varargout = basic_ephys_analysis(varargin)
% BASIC_EPHYS_ANALYSIS MATLAB code for basic_ephys_analysis.fig
%      BASIC_EPHYS_ANALYSIS, by itself, creates a new BASIC_EPHYS_ANALYSIS or raises the existing
%      singleton*.
%
%      H = BASIC_EPHYS_ANALYSIS returns the handle to a new BASIC_EPHYS_ANALYSIS or the handle to
%      the existing singleton*.
%
%      BASIC_EPHYS_ANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BASIC_EPHYS_ANALYSIS.M with the given input arguments.
%
%      BASIC_EPHYS_ANALYSIS('Property','Value',...) creates a new BASIC_EPHYS_ANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before basic_ephys_analysis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to basic_ephys_analysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help basic_ephys_analysis

    % Last Modified by GUIDE v2.5 09-Aug-2017 17:46:23

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @basic_ephys_analysis_OpeningFcn, ...
                       'gui_OutputFcn',  @basic_ephys_analysis_OutputFcn, ...
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
end


% --- Executes just before basic_ephys_analysis is made visible.
function basic_ephys_analysis_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to basic_ephys_analysis (see VARARGIN)

    % Choose default command line output for basic_ephys_analysis
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes basic_ephys_analysis wait for user response (see UIRESUME)
    % uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = basic_ephys_analysis_OutputFcn(hObject, eventdata, handles)  %#ok<*INUSL>
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;
end

% --- Executes on button press in choosefilesbutton.
function choosefilesbutton_Callback(hObject, eventdata, handles) %#ok<*INUSD>
    % hObject    handle to choosefilesbutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    handles.filenames = uigetfile('*.xsg;*.h5','MultiSelect','on'); % TODO : will we ever want to combine files from multiple folders?  Might make sense to switch to uipickfiles
    
    if isnumeric(handles.filenames)
        return
    end
    
    if ischar(handles.filenames)
        handles.filenames = {handles.filenames};
    end
    
    [handles.traces,handles.sampleRate] = concatenateEphusTraces(handles.filenames);
    
    plotTraces(handles.dataaxis,handles.traces,handles.sampleRate);
end
