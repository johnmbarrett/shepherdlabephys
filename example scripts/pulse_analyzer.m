function analyzedData = pulse_analyzer(initialTrace,traces,holdingVolt,stimType,recordMode,msWin)
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
for a=1:length(traces);
    q = traces(a);
    if q < 10
        if strcmp(stimType,'LED')
            filename = strcat(initialTrace,'AAAA000',int2str(q),'.xsg');
        elseif strcmp(stimType,'Laser')
            filename = strcat(initialTrace,'FAAA000',int2str(q),'.xsg');
        end
    else
        if strcmp(stimType,'LED')
            filename = strcat(initialTrace,'AAAA00',int2str(q),'.xsg');
        elseif strcmp(stimType,'Laser')
            filename = strcat(initialTrace,'FAAA00',int2str(q),'.xsg');
        end
    end
    tempData = load(filename,'-mat');
    data(:,a)= tempData.data.ephys.trace_1;
    q = q+1;      
end
% Save the raw traces
analyzedData.rawTraces = data;

% Pull stimulation data from file (assume stimulation parameters are the
% same for each trial in the data series)
RsStart = tempData.header.ephys.ephys.pulseParameters{1,1}.squarePulseTrainDelay;
if strcmp(analyzedData.stimType,'Laser') % Laser stim info is in stimulator
    stimData = tempData.header.stimulator.stimulator.pulseParameters{1,6};
else
    stimData = tempData.header.stimulator.stimulator.pulseParameters{1,1};
end
stimStart = stimData.squarePulseTrainDelay;
stimWidth = stimData.squarePulseTrainWidth;
stimISI = stimData.squarePulseTrainISI;
stimNum = stimData.squarePulseTrainNumber;
stimAmp = stimData.amplitude;
analyzedData.RsStart = RsStart;
analyzedData.stimStart = stimStart;
analyzedData.stimWidth = stimWidth;
analyzedData.stimAmp = stimAmp;
analyzedData.stimISI = stimISI;
analyzedData.stimNum = stimNum; 
% Find sampling rate 
SR = tempData.header.ephys.ephys.sampleRate;
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

% Find the baseline of each trace (let the baseline be all of the trace
% that is 5ms before the first stimulation)
baseline = nanmean(data(1:SR*(stimStart-.005),:),1);
analyzedData.baseline = baseline;
% Subtract baseline from traces
data_zeroed = zeros(length(data(:,1)),length(traces));
for a = 1:length(traces)
    data_zeroed(:,a) = data(:,a)-baseline(1,a);
end
analyzedData.data_zeroed = data_zeroed;
% Plot baseline subtraced traces
sh(2) = subplot(3,3,2);
hold on;
title('Baseline Subtracted Traces');
xlabel('time (s)');
if strcmp(analyzedData.recordMode,'VC')
    ylabel('pA');
elseif strcmp(analyzedData.recordMode,'IC')
    ylabel('mV');
else
    disp('Check the recordMode field');
end
plot(time,data_zeroed);
lim = axis;
plot([stimStart,stimStart],[lim(3),lim(4)],'-.k');
hold off;

% Compute average trace
meanTrace = nanmean(data_zeroed,2);
analyzedData.meanTrace= meanTrace;
% Plot average trace
sh(3) = subplot(3,3,3);
hold on;
title('Mean Trace');
xlabel('time (s)');
if strcmp(analyzedData.recordMode,'VC')
    ylabel('pA');
elseif strcmp(analyzedData.recordMode,'IC')
    ylabel('mV');
else
    disp('Check the recordMode field');
end
plot(time,meanTrace);
lim = axis;
plot([stimStart,stimStart],[lim(3),lim(4)],'-.k');
hold off;

% Median filter average trace
filteredTrace =colfilt(meanTrace,[3,1],'sliding',@median);
analyzedData.filteredTrace = filteredTrace;
analyzedData.filter_n = 3;
% Plot filtered trace
sh(4) = subplot(3,3,4);
hold on;
title('Filtered Trace');
xlabel('time (s)');
if strcmp(analyzedData.recordMode,'VC')
    ylabel('pA');
elseif strcmp(analyzedData.recordMode,'IC')
    ylabel('mV');
else
    disp('Check the recordMode field');
end
plot(time,filteredTrace);
lim = axis;
plot([stimStart,stimStart],[lim(3),lim(4)],'-.k');
hold off;

%*************************************************************************
% Separate out data for each stim (collect 5ms before each stim to 45ms
% after each stim to get 50ms segments of data)
window = msWin*SR/1000; % number of points needed for 50ms window selection
ISI = stimISI*SR; % convert ISI to number of data points
Start = stimStart*SR-(5*SR/1000); % convert beginning of stimulation into the location of a datapoint and go back 5ms
stimOnset = 0.005; % onset of stimulation is 5ms after the begining of each splitData
splitData = zeros(window,stimNum);
for a = 1:stimNum
    splitData(:,a) = filteredTrace((Start+ISI*(a-1)):(Start+ISI*(a-1)+window-1),:);
end
analyzedData.splitData = splitData;
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
plot(newTime,splitData);
lim = axis;
plot([stimOnset,stimOnset],[lim(3),lim(4)],'-.k');
hold off;

% Determine stim time points (Iholds), median, 5ms before each stim
Iholds = zeros(1,stimNum);
for a = 1:stimNum
    Iholds(1,a) = median(splitData(1:5*SR/1000,a));
end
analyzedData.Iholds = Iholds;
% Subtract Iholds from the splitData
alignedData = zeros(length(splitData(:,1)),stimNum);
for a = 1:stimNum
    alignedData(:,a) = splitData(:,a)-Iholds(1,a);
end
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
Peaks = zeros(1,stimNum);
peakInd = zeros(1,stimNum);
meanPeaks = zeros(1,stimNum);
for a = 1:stimNum
    if strcmp(analyzedData.holdingVolt,'-70')&&strcmp(analyzedData.recordMode,'VC')
        [~,peakInd(1,a)] = min(alignedData(round(5*SR/1000):length(alignedData(:,1)),a)); % We should avoid looking at the first 5ms of the data for peaks because that is during the stim period
        peakInd(1,a) = peakInd(1,a)+5*SR/1000; % add back the time we decided to not look at
        meanPeaks(1,a) = mean(alignedData(5*SR/1000:window,a));
        if length(alignedData(:,a))<peakInd(1,a)+5
            Peaks(1,a) = median(alignedData(peakInd(1,a)-5:end,a));
        elseif peakInd(1,a)<=5
            Peaks(1,a) = median(alignedData(1:peakInd(1,a)+5,a));
        else
            Peaks(1,a) = median(alignedData(peakInd(1,a)-5:peakInd(1,a)+5,a));
        end
    else
        [~,peakInd(1,a)] = max(alignedData(round(5*SR/1000):length(alignedData(:,1)),a));
        peakInd(1,a) = peakInd(1,a)+5*SR/1000;
        meanPeaks(1,a) = mean(alignedData(5*SR/1000:window,a));
        if length(alignedData(:,a))<peakInd(1,a)+5
            Peaks(1,a) = median(alignedData(peakInd(1,a)-5:end,a));
        elseif peakInd(1,a)<=5
            Peaks(1,a) = median(alignedData(1:peakInd(1,a)+5,a));
        else
            Peaks(1,a) = median(alignedData(peakInd(1,a)-5:peakInd(1,a)+5,a));
        end
    end
end
analyzedData.Peaks = Peaks;
analyzedData.peakInd = peakInd;
analyzedData.meanPeaks = meanPeaks;
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
PPR = abs(Peaks./Peaks(1));
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
stp_duration=0.05; % in ms
stp_duration=stp_duration*SR; % multiplied by sampling rate
% find peak cap current witinin 5ms
capacitative_current = zeros(1,length(traces));
for k = 1:length(traces)
    RsS = RsStart;
    RsS = RsS*SR;
    RsEnd = RsS+stp_duration;
    capacitative_current(:,k)= min(data(RsS:RsEnd,k));
end 
Rs = zeros(1,length(traces));
for k=1:length(traces)
    Rs(:,k) = 1000*voltage_stp/capacitative_current(:,k);
end
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

peak10 = 0.1*Peaks; % actually use 50% of the peak
peak90 = 0.9*Peaks;
lineBase = polyfit((1:SR*stimOnset)',alignedData(1:SR*stimOnset,1),1); % use the time before the onset of stimulation as the baseline estimate
if strcmp(stimType,'LED')&& stimNum==1 && strcmp(holdingVolt,'-70') && strcmp(recordMode,'VC')    
    peak10Ind = find(alignedData<peak10,1,'first');
    peak90Ind = find(alignedData<peak90,1,'first');
    linePeak = polyfit((peak10Ind:peak90Ind)',alignedData(peak10Ind:peak90Ind,1),1);
    xIntercept = (linePeak(2)-lineBase(2))/(-linePeak(1));
    Latency = xIntercept/SR-stimOnset; % latency in ms
    analyzedData.Latency = Latency;
elseif strcmp(stimType,'LED')&&stimNum==1&&strcmp(recordMode,'IC')
    peak10Ind = find(alignedData>peak10,1,'first');
    peak90Ind = find(alignedData>peak90,1,'first');
    linePeak = polyfit((peak10Ind:peak90Ind)',alignedData(peak10Ind:peak90Ind,1),1);
    xIntercept = (linePeak(2)-lineBase(2))/(-linePeak(1));
    Latency = xIntercept/SR-stimOnset; % latency in ms
    analyzedData.Latency = Latency;
end

% Find the half-wdith
peak50 = 0.5*Peaks;
if strcmp(stimType,'LED')&&stimNum==1&&strcmp(recordMode,'IC')
    riseInd = find(alignedData>peak50,1,'first');
    fallInd = find(alignedData(riseInd:end)<peak50,1,'first')-1+riseInd;
    halfWidth = (fallInd-riseInd)/SR;
    analyzedData.halfWidth = halfWidth;
end

% Find the rise time
riseTime = (peakInd-xIntercept)/SR;
analyzedData.riseTime = riseTime;

% Find the fall time
if strcmp(stimType,'LED')&&stimNum==1&&strcmp(recordMode,'IC')
    fallpeak90_Ind = find(alignedData(peakInd:end)<peak90,1,'first')+peakInd;
    fallpeak10_Ind = find(alignedData(peakInd:end)<peak10,1,'first')+peakInd;
    lineFall = polyfit((fallpeak90_Ind:fallpeak10_Ind)',alignedData(fallpeak90_Ind:fallpeak10_Ind,1),1);
    fallIntercept = (lineBase(2)-lineFall(2))/lineFall(1); % Assume baseline is flat
    fallTime = (fallIntercept - peakInd)/SR;
    analyzedData.fallTime = fallTime;
end

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