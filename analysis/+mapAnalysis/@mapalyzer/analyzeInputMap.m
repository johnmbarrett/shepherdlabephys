function [synThreshpAmV,baselineSD,spontEventRate,histoN] = analyzeInputMap(self,recording,mapNumber) % TODO : get rid of mapnumber
% analyzeInputMapArray     Main engine for analyzing set of traces.
%
%
% gs april 2005 - Modified for mapAnalysis2p0 from old analyzeArray
% ------------------------------------------------------------------------------

    % ANALYSIS METHOD
    analysisMethod = str2double(self.methodInputMap);
    % method 1 -- old way: baseline-subtract using MEAN; divide baseline into baseline/response
    % method 2 -- new way: baseline-subtract using MEDIAN; simply calc SD of baselines

    % DATA etc
    dataArray = recording.Raw.Data'; % dataArray
    % should modify this to make it conditional ...

    sr = self.sampleRate;
    mapPattern = recording.Raw.Pattern;

    isCurrentClamp = ~isempty(self.isCurrentClamp) && self.isCurrentClamp;

    % CELL parameters
    if self.chkWithRsRm
        try
            self.calcCellParameters();
        catch err
            logMatlabError(err,'Encountered error the following error while calculating cell parameters, check you have the right window settings:-\n');
        end
    end
    
    baselineStartIndex = round(self.baselineStart*sr)+1;
    baselineEndIndex = round(self.baselineEnd*sr)+1;

    % BASELINE settings, mean, sd, baseline-subtracted array
    if analysisMethod == 1
        average = @mean;
    else
        average = @median;
    end
    
    baselineAverages = average(dataArray(baselineStartIndex:baselineEndIndex,:));
%     baselineSDs = std(dataArray(baselineStartIndex:baselineEndIndex,:));
        
    if analysisMethod == 1
        bsArray = recording.BaselineSubtracted.Data';
    else
        bsArray = bsxfun(@minus,dataArray,baselineAverages);
    end

    b0 = min(bsArray(1:500, :));
    b1 = min(bsArray(500:1000, :));
    r0 = min(bsArray(500:1000, :));
    r1 = min(bsArray(1101:1601, :));
    
    ampHistoBaselineData = -(r0-b0);
    recording.AmplitudeHistogramBaselineData = mapAnalysis.Map(ampHistoBaselineData',mapPattern);
    
    ampHistoSynapticData = -(r1-b1);
    recording.AmplitudeHistogramSynapticData = mapAnalysis.Map(ampHistoSynapticData',mapPattern);
        
    if analysisMethod == 1
        histoBaseSDs = std(ampHistoBaselineData);
    elseif analysisMethod == 2
        histoBaseSDs = mean(std(dataArray(baselineStartIndex:baselineEndIndex,:)));
    end

    % STIMULUS timing
    stimOn = self.stimOn;
    stimOnInd = round(stimOn*sr+1);

    % WINDOWS *******************************************************************
    directWindowStart = self.directWindowStart;
    directStartInd = round(directWindowStart * sr + 1);
    directWindow = self.directWindow;
%     directEndInd = directStartInd + round(directWindow * sr);

    synapticWindowStart = self.synapticWindowStart;
%     synapticWindowStartInd = round(synapticWindowStart * sr + 1);
    synapticWindow = self.synapticWindow;
    synEndInd = directStartInd + round(synapticWindow * sr); % TODO : bug? surely should be synapticWindowStartInd?

    fourthWindowStart = self.fourthWindowStart;
    fourthWindowStartInd = round(fourthWindowStart * sr + 1);
    fourthWindow = self.fourthWindow;
    fourthWindowEndInd = fourthWindowStartInd + round(fourthWindow * sr);

%     synDuration = self.synDuration;

    % THRESHOLDS ****************************************************************
    % NB: these are vectors
    synLevel = self.synThreshold; 
%     dirLevel = synLevel; 
    
    if analysisMethod == 1 % method 1 -- based on baseline mean
%         dirPosThresh = baselineMeans + dirLevel * histoBaseSDs;
%         dirNegThresh = baselineMeans - dirLevel * histoBaseSDs;
        synPosThresh = baselineMeans + synLevel * histoBaseSDs;
        synNegThresh = baselineMeans - synLevel * histoBaseSDs;
    elseif analysisMethod == 2 % method 1 -- based on baseline median
%         dirPosThresh = dirLevel * histoBaseSDs;
%         dirNegThresh = -dirLevel * histoBaseSDs;
        synPosThresh = synLevel * histoBaseSDs;
        synNegThresh = -synLevel * histoBaseSDs;
    end

    synThreshpAmV = synLevel * histoBaseSDs;
    baselineSD = histoBaseSDs;

    % RESPONSES *****************************************************************
    % strategy: measure response params over entire post-stim window (direct + syn)
    % aftwerward, determine whether responses were direct or syn

    % MEAN
    recording.MeanResponseAmplitude = mapAnalysis.Map(mean(bsArray(stimOnInd:synEndInd,:))',mapPattern);

    % MIN
    [genMinAmp, genMinPkLatInd] = min(bsArray(stimOnInd:synEndInd,:));
    recording.MinimumResponseAmplitude = mapAnalysis.Map(genMinAmp',mapPattern);
    
    genLatOfMin = (genMinPkLatInd-1)/sr;
    recording.MinimumResponseLatency = mapAnalysis.Map(genLatOfMin',mapPattern);

    % MAX
    [genMaxAmp, genMaxPkLatInd] = max(bsArray(stimOnInd:synEndInd,:));
    recording.MaximumResponseAmplitude = mapAnalysis.Map(genMaxAmp',mapPattern);
    
    genLatOfMax = (genMaxPkLatInd-1)/sr;
    recording.MaximumResponseLatency = mapAnalysis.Map(genLatOfMax',mapPattern);

    % INTEGRAL
%     genIntegral = trapz(bsArray(stimOnInd:synEndInd,:))/sr;

    % 'FOURTH WINDOW'
    recording.FourthWindowMeanResponseAmplitude = mapAnalysis.Map(mean(bsArray(fourthWindowStartInd:fourthWindowEndInd,:))',mapPattern);
    recording.FourthWindowMinimumResponseAmplitude = mapAnalysis.Map(min(bsArray(fourthWindowStartInd:fourthWindowEndInd,:))',mapPattern);
    recording.FourthWindowMaximumResponseAmplitude = mapAnalysis.Map(max(bsArray(fourthWindowStartInd:fourthWindowEndInd,:))',mapPattern);

    % THRESHOLDED MIN, MAX
    [timeIndicesOfEvents,~,polarityOfEvents] = findThresholdCrossings(dataArray(stimOnInd:synEndInd,:),cat(3,synPosThresh,synNegThresh),'both');
    
    latencies = inf(2,size(dataArray,2));
    
    for ii = 1:2
        timeIndicesPolarised = cellfun(@(t,p) t(p == 3-2*ii),timeIndicesOfEvents,polarityOfEvents,'UniformOutput',false);
        tracesWithEvents = ~cellfun(@isempty,timeIndicesPolarised);
        latencies(ii,tracesWithEvents) = cellfun(@(A) A(1),timeIndicesPolarised(tracesWithEvents))/sr;
    end
    
    genLatOfMaxOnset = latencies(1,:);
    genLatOfMinOnset = latencies(2,:);

    % THRESHOLDED MIN -- spontaneous event analysis of baseline interval
    timeIndicesOfEvents = findThresholdCrossings(dataArray(baselineStartIndex:baselineEndIndex,:), synNegThresh, 'negative');
    tracesWithEvents = ~cellfun(@isempty,timeIndicesOfEvents);
    spontEventNum = sum(tracesWithEvents); % TODO : multiple events on the same trace only count as one, is that right?
    totalBaselineTime = size(dataArray,2) * (self.baselineEnd - self.baselineStart);
    spontEventRate = spontEventNum / totalBaselineTime;

    % TYPES OF RESPONSES according to clamp mode, response polarity
    if ~isCurrentClamp == 0 %V-clamp
        % assumes neg Vh; inward currents excitatory, outward currents inhibitory
%         excitatoryLatency = genLatOfMin;
        excitatoryLatencyOnset = genLatOfMinOnset;
        excitatoryAmplitude = genMinAmp;
%         inhibitoryLatency = genLatOfMax;
        inhibitoryLatencyOnset = getLatOfMaxOnset;
        inhibitoryAmplitude = genMaxAmp;
    else
        % assumes typical negative Vr -- positive responses excitatory, negative responses inhibitory
%         excitatoryLatency = genLatOfMax;
        excitatoryLatencyOnset = genLatOfMaxOnset;
        excitatoryAmplitude = genMaxAmp;
%         inhibitoryLatency = genLatOfMin;
        inhibitoryLatencyOnset = genLatOfMinOnset;
        inhibitoryAmplitude = genMinAmp;
    end

    % first the direct responses: suprathreshold excitatory responses starting within direct window
    edBinary = excitatoryLatencyOnset > (directWindowStart - stimOn) & excitatoryLatencyOnset <= directWindow;
    recording.DirectResponseOccurence = mapAnalysis.Map(edBinary',mapPattern);
    recording.DirectResponseAmplitude = mapAnalysis.Map((excitatoryAmplitude.*edBinary)',mapPattern);
%     edDelay = excitatoryLatency.*edBinary;
%     edDelayOnset = genLatOfMinOnset.*edBinary;

    % now the synaptic responses -- suprathreshold excitatory responses starting within synaptic window
    esBinary = genLatOfMinOnset > synapticWindowStart & genLatOfMinOnset <= synapticWindow;
    recording.ExcitatorySynapticResponseOccurence = mapAnalysis.Map(esBinary',mapPattern);
    recording.ExcitatorySynapticResponseAmplitude = mapAnalysis.Map((excitatoryAmplitude.*esBinary)',mapPattern);
%     esDelay = excitatoryLatency.*esBinary;
%     esDelayOnset = excitatoryAmplitude.*esBinary;

    isBinary = inhibitoryLatencyOnset > synapticWindowStart & inhibitoryLatencyOnset <= synapticWindow;
    recording.InhibitorySynapticResponseOccurence = mapAnalysis.Map(isBinary',mapPattern);
    recording.InhibitorySynapticResponseAmplitude = mapAnalysis.Map((inhibitoryAmplitude.*isBinary)',mapPattern);
%     isDelay = inhibitoryLatency.*isBinary;
%     isDelayOnset = inhibitoryLatencyOnset.*isBinary;

    % PLOT map stuff for this map
    histoN = self.array2Dplot(recording,mapNumber);
end