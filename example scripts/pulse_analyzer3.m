% function analyzedData = pulse_analyzer3(initialTrace,traces,holdingVolt,stimType,recordMode,msWin)
% The pulse_analyzer function is used to process the data to find PPR among
% other things
%
% Inputs: 
%        initialTrace = string of the starting file (ie 'KG0328')
%        traces = vector array of the traces that should be included
%        holdingVolt = '10' or '-70' mV if in VC mode
%        stimType = 'Laser' or 'LED'
%        recordMode = 'VC' or 'IC'
%        msWin = the window size (in ms) that we will use for analysis of a peak
% Outputs: 
%         analyzedData = structure of processed data

% Acquire header information from user (This section is no longer
% necessary)
%mouseType = 'Gad2'; %input('Input mouse line (Sepw, Tlx, WT, Gad2xSepw, etc.): ','s');
%mouseNum = '5'; %input('Input the mouse number ID: ','s');
%slice = '2'; %input('Input brain slice number: ','s');
%yFrac = '0.79'; %input('Input cell yFrac: ','s');
%Vm = '-53'; %input('Input resting membrane potential: ','s');
%cellNum = 'KG0539'; %input('Input Cell number: ','s');
%cellPos = 'ipsi_L6'; %input('Input location of the cell (i.e. ipsi_L23 or contra_L5): ','s');
%cellDepth = '-61'; %input('Input cell depth in um: ','s');
%cellType = 'CT'; % Presumed cell type based on labeling an morphology during patching ('Pyramidal' or 'Internueron')
%temperature = '34'; %input('Input temperature of experiment (32 or 34): ','s');
%internal = 'Cs'; %input('Input internal solution used (K or Cs): ','s');
%drugs = 'TTX,4AP,CPP,ZD'; %input('Input drugs used for experiment (none, CPP, TTX, 4AP): ','s');
% Place header into output
%analyzedData.mouseType = mouseType;
%analyzedData.mouseNum = mouseNum;
%analyzedData.slice = slice;
%analyzedData.yFrac = yFrac;
%analyzedData.Vm = Vm;
%analyzedData.cellNum = cellNum;
%analyzedData.cellPos = cellPos;
%analyzedData.cellDepth = cellDepth;
%analyzedData.cellType = cellType;
%analyzedData.temperature = temperature;
%analyzedData.internal = internal;
%analyzedData.drugs = drugs;
%analyzedData.traces = traces;
%analyzedData.traceNum = length(traces);

analyzedData.holdingVolt = holdingVolt;
analyzedData.recordMode = recordMode;
analyzedData.stimType = stimType;

% Load raw data traces
switch stimType 
    case 'LED'
        firstCharacter = 'A';
    case 'Laser'
        firstCharacter = 'F';
    otherwise
        firstCharacter = 'A';
end
    
filenames = arrayfun(@(trace) sprintf('%s%sAAA%04d.xsg',initialTrace,firstCharacter,trace),traces,'UniformOutput',false);

[data,SR] = concatenateEphusTraces(filenames);
% Save the raw traces
analyzedData.rawTraces = data;

% Pull stimulation data from file (assume stimulation parameters are the
% same for each trial in the data series)
tempData = load(filenames{1},'-mat');
[~,~,RsStart] = extractEphusSquarePulseTrainParameters(tempData);
[stimAmp,stimWidth,stimStart,stimNum,stimISI] = extractEphusSquarePulseTrainParameters(tempData,1+5*strcmp(analyzedData.stimType,'Laser'));
analyzedData.RsStart = RsStart;
analyzedData.stimStart = stimStart;
analyzedData.stimWidth = stimWidth;
analyzedData.stimAmp = stimAmp;
analyzedData.stimISI = stimISI;
analyzedData.stimNum = stimNum; 
% Find sampling rate 
analyzedData.SR = SR;

% Generate time array for raw traces
time = (1:length(data(:,1)))/SR;
analyzedData.time = time;
% Plot the raw traces
figure;
sh(1) = subplot(3,3,1);
plotTraces(sh(1),data,SR,'StimStart',stimStart,'RecordingMode',analyzedData.recordMode,'Title','Raw Traces');

analyzedData.filter_n = 3;
[filteredTrace,meanTrace,data_zeroed,baseline] = preprocess(data,SR,'StartTime',stimStart,'BaselineTime',0.005,'FilterLength',analyzedData.filter_n);

sh(2) = subplot(3,3,2);
plotTraces(sh(2),data_zeroed,SR,'StimStart',stimStart,'RecordingMode',analyzedData.recordMode,'Title','Baseline Subtracted Traces');

sh(3) = subplot(3,3,3);
plotTraces(sh(3),meanTrace,SR,'StimStart',stimStart,'RecordingMode',analyzedData.recordMode,'Title','Mean Trace');

sh(4) = subplot(3,3,4);
plotTraces(sh(4),filteredTrace,SR,'StimStart',stimStart,'RecordingMode',analyzedData.recordMode,'Title','Filtered Trace');

analyzedData.baseline = baseline;
analyzedData.data_zeroed = data_zeroed;
analyzedData.meanTrace= meanTrace;
analyzedData.filteredTrace = filteredTrace;

%*************************************************************************
% Separate out data for each stim (collect 5ms before each stim to 45ms
% after each stim to get 50ms segments of data)
window = msWin*SR/1000; % number of points needed for 50ms window selection
stimOnset = 0.005; % onset of stimulation is 5ms after the begining of each splitData
splitTraces = splitData(filteredTrace,SR,'Window',msWin/1000,'Interval',stimISI,'Start',stimStart-stimOnset,'N',stimNum);
analyzedData.splitData = splitTraces;
% Plot split data
sp(1) = subplot(3,3,5);
plotTraces(sp(1),splitTraces,SR,'StimStart',stimOnset,'RecordingMode',analyzedData.recordMode,'Title','Raw Traces');

[~,~,alignedData,Iholds] = preprocess(splitTraces,SR,'StartTime',0.01,'BaselineTime',0.005);
% Determine stim time points (Iholds), median, 5ms before each stim
analyzedData.Iholds = Iholds;
analyzedData.alignedData = alignedData;
% Plot the alignedData
sp(2) = subplot(3,3,6);
plotTraces(sp(2),alignedData,SR,'StimStart',stimOnset,'RecordingMode',analyzedData.recordMode,'Title','Raw Traces');

% Determine peaks of alignedData (median of 10 points around the median).
% Also determine the mean peaks of each set
[Peaks,peakInd,PPR] = findPeaks(alignedData,SR,~(strcmp(analyzedData.holdingVolt,'-70') && strcmp(analyzedData.recordMode,'VC')),'Start',0.005);
analyzedData.Peaks = Peaks;
analyzedData.peakInd = peakInd;
% analyzedData.meanPeaks = meanPeaks;
% Plot Iholds and peaks on alignedData
sp(3) = subplot(3,3,7);
ax = plotTraces(sp(3),alignedData,SR,'Peaks',Peaks,'PeakIndices',peakInd,'StimStart',stimOnset,'RecordingMode',analyzedData.recordMode,'Title','Raw Traces');
hold(ax,'on');
plot([0.001,0.005],[0,0],'k','linewidth',3);
plot([(peakInd(:)-5)/SR (peakInd(:)+5)/SR]',[Peaks(:) Peaks(:)]','Color','k','LineWidth',3);

% Calculate the PPR (later peaks divided by the first peak)
if stimNum > 1
    plotParams(subplot(3,3,8),PPR,'Ordinate',1,'Title','PPR','XLabel','Peak Number','XLim',[1 length(PPR)],'YLabel','PPR','YLim',[min(PPR)-1 max(PPR)+1]);
    analyzedData.PPR = PPR;
end

% Calculate the series resistance
voltage_stp=-5;
stp_duration=0.05;
Rs = calculateSeriesResistance(data,SR,'Start',RsStart,'Window',stp_duration,'VoltageStep',voltage_stp);
MeanRs = mean(Rs);
analyzedData.meanRS = MeanRs;
% Plot the meanRS
plotParams(subplot(3,3,9),MeanRs,'Title','mean Rs','YLabel','Rs','XLim',[0 2],'YLim',[MeanRs-1 MeanRs+1]);

% Find the distance between laser stim position and soma
if strcmp(stimType,'Laser')
    somaLoc = tempData.header.mapper.mapper.soma1Coordinates;
    laserLoc = tempData.header.mapper.mapper.beamCoordinates;
    soma_laser_distance = sqrt((somaLoc(1)-laserLoc(1))^2+(somaLoc(2)-laserLoc(2))^2);
    analyzedData.somaLoc = somaLoc;
    analyzedData.laserLoc = laserLoc;
    analyzedData.soma_laser_distance = soma_laser_distance;
end

% Find the latency between stim onset and input onset (only for LED stims)

[Peaks,peakInd,Latency,riseTime,fallTime,halfWidth] = calculateTemporalParameters(alignedData,SR,'Start',stimOnset,'Window',msWin/1000);
analyzedData.Latency = Latency;
analyzedData.riseTime = riseTime;
analyzedData.halfWidth = halfWidth;
analyzedData.fallTime = fallTime;

% plot what the latency, half-width, peak time, recovery time
if strcmp(stimType,'LED') && stimNum == 1
    sp(4) = subplot(3,3,8);
    
    if strcmp(recordMode,'IC')
        plotTraces(sp(4),alignedData,SR,'Peaks',[peak10 peak90 peak10 peak90],'PeakIndices',[peak10Ind peak90Ind fallpeak10_Ind fallpeak90_Ind]/SR,'StimStart',[stimOnset Latency+stimOnset peakInd/SR fallIntercep/SR],'Title','Latency');
        hold(sp(4),'on')
        plot([riseInd/SR,fallInd/SR],[peak50,peak50],'-.k');
    elseif strcmp(recordMode,'VC')
        plotTraces(sp(4),alignedData,SR,'StimStart',[stimOnset Latency+stimOnset],'Title','Latency');
    end
    
    hold(sp(4),'off');
end

linkaxes(sh,'x');
linkaxes(sp,'x');