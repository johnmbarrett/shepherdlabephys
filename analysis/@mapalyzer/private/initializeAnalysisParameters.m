function handles = initializeAnalysisParameters(handles)
% initializeAnalysisParameters

% gs april 2005
% -------------------------------------------------

% LOAD -------------------------------------------------

% lstbxTraceType

% lstbxSelectionType

% default data directory
handles.data.analysis.defaultDataDir = 'C:\_Data\Gordon';

% default data m-file directory:
handles.data.analysis.defaultDataMFileDir = 'C:\_Cartography\matlab\expts';

% FILTERING -------------------------------------------------

% chkFilter

% popFilterType
set(handles.popFilterType, 'Value', 1); % = 'mean'
str = get(handles.popFilterType, 'String');
val = get(handles.popFilterType, 'Value');
handles.data.analysis.popFilterType = str{val};

% filterValue
handles.data.analysis.filterValue = 11;
set(handles.filterValue, 'String', num2str(handles.data.analysis.filterValue));

% BASELINE SUBTRACTION -------------------------------------------------

% chkBaselineSubtract

% baseline settings
handles.data.analysis.bsBaselineStart = 0.001;
set(handles.bsBaselineStart, 'String', num2str(handles.data.analysis.bsBaselineStart));

handles.data.analysis.bsBaselineEnd = 0.099;
set(handles.bsBaselineEnd, 'String', num2str(handles.data.analysis.bsBaselineEnd));

% CELL PARAMETERS -------------------------------------------------

% test pulse start
handles.data.analysis.rstepOn = .6;
set(handles.rstepOn, 'String', num2str(handles.data.analysis.rstepOn));

% test pulse dur
handles.data.analysis.rstepDur = .05;
set(handles.rstepDur, 'String', num2str(handles.data.analysis.rstepDur));

% test pulse amp
handles.data.analysis.rstepAmp = -5;
set(handles.rstepAmp, 'String', num2str(handles.data.analysis.rstepAmp));

% skip val
handles.data.analysis.RsSkipVal = 8;
set(handles.RsSkipVal, 'String', num2str(handles.data.analysis.RsSkipVal));

% Rs
handles.data.map.mapAvg.rseriesAvg = [];
set(handles.rseriesAvg, 'String', num2str(handles.data.map.mapAvg.rseriesAvg));

% Ri (= Rm)
handles.data.map.mapAvg.rmembraneAvg = [];
set(handles.rmembraneAvg, 'String', num2str(handles.data.map.mapAvg.rmembraneAvg));

% Cm
handles.data.map.mapAvg.cmembraneAvg = [];
set(handles.cmembraneAvg, 'String', num2str(handles.data.map.mapAvg.cmembraneAvg));

% tau
handles.data.map.mapAvg.tauAvg = [];
set(handles.tauAvg, 'String', num2str(handles.data.map.mapAvg.tauAvg));

% INFO -------------------------------------------------

% cellType
handles.data.analysis.cellType = 'neuron';
set(handles.cellType, 'String', handles.data.analysis.cellType);

% Vrest
handles.data.analysis.Vrest = [];
set(handles.Vrest, 'String', num2str(handles.data.analysis.Vrest));

% Vhold
handles.data.analysis.Vhold = [];
set(handles.Vhold, 'String', num2str(handles.data.analysis.Vhold));

% animalAge
handles.data.analysis.animalAge = [];
set(handles.animalAge, 'String', num2str(handles.data.analysis.animalAge));

% exptCondition
handles.data.analysis.exptCondition = '';
set(handles.exptCondition, 'String', handles.data.analysis.exptCondition);

% notes
handles.data.analysis.notes = '';
set(handles.notes, 'String', handles.data.analysis.notes);

% fieldAName
handles.data.analysis.fieldAName = 'fieldA';
set(handles.fieldAName, 'String', handles.data.analysis.fieldAName);

% fieldAVal
handles.data.analysis.fieldAVal = '';
set(handles.fieldAVal, 'String', handles.data.analysis.fieldAVal);

% fieldBName
handles.data.analysis.fieldBName = 'fieldB';
set(handles.fieldBName, 'String', handles.data.analysis.fieldBName);

% fieldBVal
handles.data.analysis.fieldBVal = '';
set(handles.fieldBVal, 'String', handles.data.analysis.fieldBVal);

% fieldCName
handles.data.analysis.fieldCName = 'fieldC';
set(handles.fieldCName, 'String', handles.data.analysis.fieldCName);

% fieldCVal
handles.data.analysis.fieldCVal = '';
set(handles.fieldCVal, 'String', handles.data.analysis.fieldCVal);

% fieldDName
handles.data.analysis.fieldDName = 'fieldD';
set(handles.fieldDName, 'String', handles.data.analysis.fieldDName);

% fieldDVal
handles.data.analysis.fieldDVal = '';
set(handles.fieldDVal, 'String', handles.data.analysis.fieldDVal);

% fieldEName
handles.data.analysis.fieldEName = 'fieldE';
set(handles.fieldEName, 'String', handles.data.analysis.fieldEName);

% fieldEVal
handles.data.analysis.fieldEVal = '';
set(handles.fieldEVal, 'String', handles.data.analysis.fieldEVal);

% fieldFName
handles.data.analysis.fieldFName = 'fieldF';
set(handles.fieldFName, 'String', handles.data.analysis.fieldFName);

% fieldFVal
handles.data.analysis.fieldFVal = '';
set(handles.fieldFVal, 'String', handles.data.analysis.fieldFVal);

% fieldGName
handles.data.analysis.fieldGName = 'fieldG';
set(handles.fieldGName, 'String', handles.data.analysis.fieldGName);

% fieldGVal
handles.data.analysis.fieldGVal = '';
set(handles.fieldGVal, 'String', handles.data.analysis.fieldGVal);

% fieldHName
handles.data.analysis.fieldHName = 'fieldH';
set(handles.fieldHName, 'String', handles.data.analysis.fieldHName);

% fieldHVal
handles.data.analysis.fieldHVal = '';
set(handles.fieldHVal, 'String', handles.data.analysis.fieldHVal);

% INPUT MAP -------------------------------------------------

% traceMapShowStart
handles.data.analysis.traceMapShowStart = .099;
set(handles.traceMapShowStart, 'String', num2str(handles.data.analysis.traceMapShowStart));

% traceMapShowStop
handles.data.analysis.traceMapShowStop = .25;
set(handles.traceMapShowStop, 'String', num2str(handles.data.analysis.traceMapShowStop));

% traceMapYFactor
handles.data.analysis.traceMapYFactor = 100;
set(handles.traceMapYFactor, 'String', num2str(handles.data.analysis.traceMapYFactor));

% stimOn
handles.data.analysis.stimOn = .1;
set(handles.stimOn, 'String', num2str(handles.data.analysis.stimOn));

% baselineStart
handles.data.analysis.baselineStart = .001;
set(handles.baselineStart, 'String', num2str(handles.data.analysis.baselineStart));

% baselineEnd
handles.data.analysis.baselineEnd = .1;
set(handles.baselineEnd, 'String', num2str(handles.data.analysis.baselineEnd));

% directWindowStart
handles.data.analysis.directWindowStart = .1;
set(handles.directWindowStart, 'String', num2str(handles.data.analysis.directWindowStart));

% directWindow
handles.data.analysis.directWindow = .007;
set(handles.directWindow, 'String', num2str(handles.data.analysis.directWindow));

% synapticWindowStart
handles.data.analysis.synapticWindowStart = handles.data.analysis.directWindow;
set(handles.synapticWindowStart, 'String', num2str(handles.data.analysis.synapticWindowStart));

% synapticWindow
handles.data.analysis.synapticWindow = .05;
set(handles.synapticWindow, 'String', num2str(handles.data.analysis.synapticWindow));

% synThreshold
handles.data.analysis.synThreshold = 3;
set(handles.synThreshold, 'String', num2str(handles.data.analysis.synThreshold));

% fourthInputWindowStart
handles.data.analysis.fourthWindowStart = .1;
set(handles.fourthWindowStart, 'String', num2str(handles.data.analysis.fourthWindowStart));

% fourthInputWindow
handles.data.analysis.fourthWindow = .003;
set(handles.fourthWindow, 'String', num2str(handles.data.analysis.fourthWindow));

% eventPolaritySyn
set(handles.eventPolaritySyn, 'Value', 2); % = 'down'
str = get(handles.eventPolaritySyn, 'String');
val = get(handles.eventPolaritySyn, 'Value');
handles.data.analysis.eventPolaritySyn = str{val};

% synDuration
handles.data.analysis.synDuration = 0.1;
set(handles.synDuration, 'String', num2str(handles.data.analysis.synDuration));



% EXCITATION PROFILE -------------------------------------------------

% stimOnEP
handles.data.analysis.stimOnEP = .1;
set(handles.stimOnEP, 'String', num2str(handles.data.analysis.stimOnEP));

% baselineStartEP
handles.data.analysis.baselineStartEP = .001;
set(handles.baselineStartEP, 'String', num2str(handles.data.analysis.baselineStartEP));

% baselineEndEP
handles.data.analysis.baselineEndEP = .1;
set(handles.baselineEndEP, 'String', num2str(handles.data.analysis.baselineEndEP));

% responseStartEP
handles.data.analysis.responseStartEP = .1;
set(handles.responseStartEP, 'String', num2str(handles.data.analysis.responseStartEP));

% responseDurEP
handles.data.analysis.responseDurEP = .1;
set(handles.responseDurEP, 'String', num2str(handles.data.analysis.responseDurEP));

% apThreshold
handles.data.analysis.apThreshold = 0.5;
set(handles.apThreshold, 'String', num2str(handles.data.analysis.apThreshold));

% eventPolarityAP
set(handles.eventPolarityAP, 'Value', 1); % = 'up'
str = get(handles.eventPolarityAP, 'String');
val = get(handles.eventPolarityAP, 'Value');
handles.data.analysis.eventPolarityAP = str{val};

% handles.data.analysis.cellAttachedCheck = 0;


% MISCELLANEOUS STUFF -------------------------------------------------

handles.data.analysis.colorOrder = ['k'; 'b'; 'g'; 'r'; 'c'; 'm'; 'y'];


% GENERIC TRACE ANALYSIS -------------------------------------------------

% stimOn
handles.data.analysis.stimOnGen = .1;
set(handles.stimOnGen, 'String', num2str(handles.data.analysis.stimOnGen));

% CURRENT FREQUENCY ANALYSIS -------------------------------------------------

% currentStepStart
handles.data.analysis.currentStepStart = .1;
set(handles.currentStepStart, 'String', num2str(handles.data.analysis.currentStepStart));

% currentStepDuration
handles.data.analysis.currentStepDuration = .5;
set(handles.currentStepDuration, 'String', num2str(handles.data.analysis.currentStepDuration));

% spikeThreshold
handles.data.analysis.spikeThreshold = 5;
set(handles.spikeThreshold, 'String', num2str(handles.data.analysis.spikeThreshold));

