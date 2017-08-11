function analyzedData = pulse_analyzer2(initialTrace,traces,holdingVolt,stimType,recordMode,msWin)
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
    
filenames = cellfun(@(trace) sprintf('%s%sAAA%04d',initialTrace,firstCharacter,trace),traces,'UniformOutput',false);

[data,SR] = concatentateEphusTraces(filenames);
% Save the raw traces
analyzedData.rawTraces = data;

% Pull stimulation data from file (assume stimulation parameters are the
% same for each trial in the data series)
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
hold on;
title('Raw Traces');
xlabel('time (s)');
if strcmp(analyzedData.recordMode,'VC')
    ylabel('pA');
elseif strcmp(analyzedData.recordMode,'IC')
    ylabel('mV');
else
    disp('Check the recordMode field');
end
plot(time,data);
lim = axis;
plot([stimStart,stimStart],[lim(3),lim(4)],'-.k');
hold off;

analyzedData.filter_n = 3;
[filteredTrace,meanTrace,data_zeroed,baseline] = preprocess(data,SR,'StartTime',stimStart,'BaselineTime',0.005,'MedianFilterLength',analyzedData.filter_n);
analyzedData.baseline = baseline;
analyzedData.data_zeroed = data_zeroed;
analyzedData.meanTrace= meanTrace;
analyzedData.filteredTrace = filteredTrace;

%*************************************************************************
% Separate out data for each stim (collect 5ms before each stim to 45ms
% after each stim to get 50ms segments of data)
window = msWin*SR/1000; % number of points needed for 50ms window selection
stimOnset = 0.005; % onset of stimulation is 5ms after the begining of each splitData
splitTraces = splitData(filteredTrace,SR,msWin/1000,stimISI,stimStart-stimOnset);
analyzedData.splitData = splitTraces;
% Plot split data
sp(1) = subplot(3,3,5);
hold on;
title('Split Trace');
xlabel('time (s)');
if strcmp(analyzedData.recordMode,'VC')
    ylabel('pA');
elseif strcmp(analyzedData.recordMode,'IC')
    ylabel('mV');
else
    disp('Check the recordMode field');
end
newTime = 1/SR:1/SR:window/SR;
plot(newTime,splitTraces);
lim = axis;
plot([stimOnset,stimOnset],[lim(3),lim(4)],'-.k');
hold off;

[~,~,alignedData,Iholds] = preprocess(splitTraces,SR,'StartTime',0.01,'BaselineTime',0.005);
% Determine stim time points (Iholds), median, 5ms before each stim
analyzedData.Iholds = Iholds;
analyzedData.alignedData = alignedData;
% Plot the alignedData
sp(2) = subplot(3,3,6);
hold on;
title('Aligned Data');
xlabel('time (ms)');
if strcmp(analyzedData.recordMode,'VC')
    ylabel('pA');
elseif strcmp(analyzedData.recordMode,'IC')
    ylabel('mV');
else
    disp('Check the recordMode field');
end;
plot(newTime,alignedData);
lim = axis;
plot([stimOnset,stimOnset],[lim(3),lim(4)],'-.k');
hold off;

% Determine peaks of alignedData (median of 10 points around the median).
% Also determine the mean peaks of each set
[Peaks,peakInd,PPR] = findPeaks(alignedData,SR,~(strcmp(analyzedData.holdingVolt,'-70')&&strcmp(analyzedData.recordMode,'VC')),'Start',0.005);
analyzedData.Peaks = Peaks;
analyzedData.peakInd = peakInd;
% analyzedData.meanPeaks = meanPeaks;
% Plot Iholds and peaks on alignedData
sp(3) = subplot(3,3,7);
hold on;
title('Peaks');
xlabel('time (s)');
if strcmp(analyzedData.recordMode,'VC')
    ylabel('pA');
elseif strcmp(analyzedData.recordMode,'IC')
    ylabel('mV');
else
    disp('Check the recordMode field');
end;
plot(newTime,alignedData);
plot([0.001,0.005],[0,0],'k','linewidth',3);
for a = 1:stimNum
    plot([(peakInd(1,a)-5)/SR,(peakInd(1,a)+5)/SR],[Peaks(1,a),Peaks(1,a)],'k','linewidth',3);
    plot(peakInd(1,a)/SR,Peaks(1,a),'ko','MarkerSize',10);
end
lim = axis;
plot([stimOnset,stimOnset],[lim(3),lim(4)],'-.k');
hold off;

% Calculate the PPR (later peaks divided by the first peak)
if stimNum > 1
analyzedData.PPR = PPR;
% Plot PPR
subplot(3,3,8);
hold on;
title('PPR');
xlabel('Peak Number');
ylabel('PPR');
axis([1,length(PPR),min(PPR)-1,max(PPR)+1]);
plot(1:length(PPR),PPR,'-ro');
plot(1:length(PPR),ones(1,length(PPR)),'-.k');
hold off;
end

% Calculate the series resistance
voltage_stp=-5;
stp_duration=0.05;
Rs = calculateSeriesResistance(data,SR,'Start',RsStart,'Window',stp_duration,'VoltageStep',voltage_stp);
MeanRs = mean(Rs);
analyzedData.meanRS = MeanRs;
% Plot the meanRS
subplot(3,3,9);
hold on;
title('mean Rs');
ylabel('Rs');
axis([0,2,MeanRs-1,MeanRs+1]);
plot(1,MeanRs,'ro');
hold off;

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

[Latency,riseTime,fallTime,halfWidth] = calculateTemporalParameters(alignedData,Peaks,peakInd,SR,stimOnset);
analyzedData.Latency = Latency;
analyzedData.riseTime = riseTime;
analyzedData.halfWidth = halfWidth;
analyzedData.fallTime = fallTime;

% plot what the latency, half-width, peak time, recovery time
if strcmp(stimType,'LED')&&stimNum==1&&strcmp(recordMode,'IC')
    subplot(3,3,8)
    hold on;
    title('Latency');
    plot(newTime,alignedData);
    plot([stimOnset,stimOnset],[lim(3),lim(4)],'-.k')
    plot([Latency+stimOnset,Latency+stimOnset],[lim(3),lim(4)],'-.k');
    plot(peak10Ind/SR,peak10,'ko');
    plot(peak90Ind/SR,peak90,'ko');
    plot([riseInd/SR,fallInd/SR],[peak50,peak50],'-.k');
    plot([peakInd/SR,peakInd/SR],[lim(3),lim(4)],'-.k');
    plot([fallIntercept/SR,fallIntercept/SR],[lim(3),lim(4)],'-.k');
    plot(fallpeak10_Ind/SR,peak10,'ko');
    plot(fallpeak90_Ind/SR,peak90,'ko');
    hold off;
elseif strcmp(stimType,'LED')&&stimNum==1&&strcmp(recordMode,'VC')
    subplot(3,3,8)
    hold on;
    title('Latency');
    plot(newTime,alignedData);
    plot([stimOnset,stimOnset],[lim(3),lim(4)],'-.k')
    plot([Latency+stimOnset,Latency+stimOnset],[lim(3),lim(4)],'-.k');
    hold off;
end

linkaxes(sh,'x');
linkaxes(sp,'x');