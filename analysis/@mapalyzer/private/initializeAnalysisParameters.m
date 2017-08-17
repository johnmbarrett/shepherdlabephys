function initializeAnalysisParameters(self)
% INITIALIZEANALYSISPARAMETERS  Initialises mapalyzer analysis parameters

% Created by John Barrett 2017-08-17 17:41 CDT
% Last Modified by John Barrett 2017-08-17 17:39 CDT
% gs april 2005
% -------------------------------------------------

% LOAD -------------------------------------------------

% TODO : hard coded paths???? where's the config file????????????
self.defaultDataDir = 'C:\_Data\Gordon';

self.defaultDataMFileDir = 'C:\_Cartography\matlab\expts';

% FILTERING -------------------------------------------------

set(findobj(self.Figure,'Tag','popFilterType'),'Value',1); % = 'mean'

% TODO : this would be so much easier with a config file.  Might be time to
% break out the perl
set(findobj(self.Figure,'Tag','filterValue'),'String',num2str(11));

% BASELINE SUBTRACTION -------------------------------------------------

set(findobj(self.Figure,'Tag','bsBaselineStart'),'String',num2str(0.001));

set(findobj(self.Figure,'Tag','bsBaselineEnd'),'String',num2str(0.099));

% CELL PARAMETERS -------------------------------------------------

% test pulse start
set(findobj(self.Figure,'Tag','rstepOn'),'String',num2str(0.6));

% test pulse dur
set(findobj(self.Figure,'Tag','rstepDur'),'String',num2str(0.05));

% test pulse amp
set(findobj(self.Figure,'Tag','rstepAmp'),'String',num2str(-5));

% skip val
set(findobj(self.Figure,'Tag','RsSkipVal'),'String',num2str(9));

% Rs
set(findobj(self.Figure,'Tag','rseriesAvg'),'String','');

% Ri (= Rm)
set(findobj(self.Figure,'Tag','rmembraneAvg'),'String','');

% Cm
set(findobj(self.Figure,'Tag','cmembraneAvg'),'String','');

% tau
set(findobj(self.Figure,'Tag','tauAvg'),'String','');

% INFO -------------------------------------------------

% cellType
set(findobj(self.Figure,'Tag','cellType'),'String','neuron');

% Vrest
set(findobj(self.Figure,'Tag','Vrest'),'String','');

% Vhold
set(findobj(self.Figure,'Tag','Vhold'),'String','');

% animalAge
set(findobj(self.Figure,'Tag','animalAge'),'String','');

% exptCondition
set(findobj(self.Figure,'Tag','exptCondition'),'String','');

% notes
set(findobj(self.Figure,'Tag','notes'),'String','');

% fieldAName
set(findobj(self.Figure,'Tag','fieldAName'),'String','fieldA');

% fieldAVal
set(findobj(self.Figure,'Tag','fieldAVal'),'String','');

% fieldBName
set(findobj(self.Figure,'Tag','fieldBName'),'String','fieldB');

% fieldBVal
set(findobj(self.Figure,'Tag','fieldBVal'),'String','');

% fieldCName
set(findobj(self.Figure,'Tag','fieldCName'),'String','fieldC');

% fieldCVal
set(findobj(self.Figure,'Tag','fieldCVal'),'String','');

% fieldDName
set(findobj(self.Figure,'Tag','fieldDName'),'String','fieldD');

% fieldDVal
set(findobj(self.Figure,'Tag','fieldDVal'),'String','');

% fieldEName
set(findobj(self.Figure,'Tag','fieldEName'),'String','fieldE');

% fieldEVal
set(findobj(self.Figure,'Tag','fieldEVal'),'String','');

% fieldFName
set(findobj(self.Figure,'Tag','fieldFName'),'String','fieldF');

% fieldFVal
set(findobj(self.Figure,'Tag','fieldFVal'),'String','');

% fieldGName
set(findobj(self.Figure,'Tag','fieldGName'),'String','fieldG');

% fieldGVal
set(findobj(self.Figure,'Tag','fieldGVal'),'String','');

% fieldHName
set(findobj(self.Figure,'Tag','fieldHName'),'String','fieldH');

% fieldHVal
set(findobj(self.Figure,'Tag','fieldHVal'),'String','');

% INPUT MAP -------------------------------------------------

% traceMapShowStart
set(findobj(self.Figure,'Tag','traceMapShowStart'),'String',num2str(0.099));

% traceMapShowStop
set(findobj(self.Figure,'Tag','traceMapShowStop'),'String',num2str(0.25));

% traceMapYFactor
set(findobj(self.Figure,'Tag','traceMapYFactor'),'String',num2str(100));

% stimOn
set(findobj(self.Figure,'Tag','stimOn'),'String',num2str(0.1));

% baselineStart
set(findobj(self.Figure,'Tag','baselineStart'),'String',num2str(0.001));

% baselineEnd
set(findobj(self.Figure,'Tag','baselineEnd'),'String',num2str(0.1));

% directWindowStart
set(findobj(self.Figure,'Tag','directWindowStart'),'String',num2str(0.1));

% directWindow
set(findobj(self.Figure,'Tag','directWindow'),'String',num2str(0.007));

% synapticWindowStart
set(findobj(self.Figure,'Tag','synapticWindowStart'),'String',num2str(0.007));

% synapticWindow
set(findobj(self.Figure,'Tag','synapticWindow'),'String',num2str(0.05));

% synThreshold
set(findobj(self.Figure,'Tag','synThreshold'),'String',num2str(3));

% fourthInputWindowStart
set(findobj(self.Figure,'Tag','fourthWindowStart'),'String',num2str(0.1));

% fourthInputWindow
set(findobj(self.Figure,'Tag','fourthWindow'),'String',num2str(0.003));

% eventPolaritySyn
set(findobj(self.Figure,'Tag','eventPolaritySyn'),'Value',2); % = 'down'

% synDuration
set(findobj(self.Figure,'Tag','synDuration'),'String',num2str(0.1));



% EXCITATION PROFILE -------------------------------------------------

% stimOnEP
set(findobj(self.Figure,'Tag','stimOnEP'),'String',num2str(.1));

% baselineStartEP
set(findobj(self.Figure,'Tag','baselineStartEP'),'String',num2str(0.001));

% baselineEndEP
set(findobj(self.Figure,'Tag','baselineEndEP'),'String',num2str(0.1));

% responseStartEP
set(findobj(self.Figure,'Tag','responseStartEP'),'String',num2str(0.1));

% responseDurEP
set(findobj(self.Figure,'Tag','responseDurEP'),'String',num2str(0.1));

% apThreshold
set(findobj(self.Figure,'Tag','apThreshold'),'String',num2str(0.5));

% eventPolarityAP
set(findobj(self.Figure,'Tag','eventPolarityAP'),'Value',1); % = 'up'

% MISCELLANEOUS STUFF -------------------------------------------------

self.colorOrder = ['k'; 'b'; 'g'; 'r'; 'c'; 'm'; 'y'];

% GENERIC TRACE ANALYSIS -------------------------------------------------

% stimOn
set(findobj(self.Figure,'Tag','stimOnGen'),'String',num2str(0.1));

% CURRENT FREQUENCY ANALYSIS -------------------------------------------------

% currentStepStart
set(findobj(self.Figure,'Tag','currentStepStart'),'String',num2str(0.1));

% currentStepDuration
set(findobj(self.Figure,'Tag','currentStepDuration'),'String',num2str(0.1));

% spikeThreshold
set(findobj(self.Figure,'Tag','spikeThreshold'),'String',num2str(5));

