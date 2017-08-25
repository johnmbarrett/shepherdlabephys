function analyzeInputMaps(self,varargin)
% analysisHandler
%
% Manages analysis of variable numbers of maps
%
% Editing:
% gs april 2005
% % ----------------------------------------------------
    set(self.Figure,'Pointer','Watch');

    self.resetAnalysis(false);
    
    mapStack = struct('mapStackLatHistoN',[]);

    % loop through the individual map trials
    for ii = 1:numel(self.recordings);
        [synThreshpAmV,baselineSD,spontEventRate,histoN] = self.analyzeInputMap(self.recordings(ii),ii);
        
        if isempty(mapStack(1).mapStackLatHistoN)
            mapStack(1).mapStackLatHistoN = histoN';
        else
            mapStack(1).mapStackLatHistoN(:,end+1) = histoN';
        end

        self.mapAvg.synThreshpAmV = [self.mapAvg.synThreshpAmV  synThreshpAmV];
        self.mapAvg.baselineSD = [self.mapAvg.baselineSD baselineSD];
        self.mapAvg.spontEventRate = [self.mapAvg.spontEventRate spontEventRate];
    end

    % avg and update certain analysis results in the gui
    self.mapAvg.synThreshpAmV = mean(self.mapAvg.synThreshpAmV);
    self.mapAvg.baselineSD = mean(self.mapAvg.baselineSD);
    self.mapAvg.spontEventRate = mean(self.mapAvg.spontEventRate);

    self.synThreshpAmV = self.mapAvg.synThreshpAmV;
    self.baselineSD = self.mapAvg.baselineSD;
    self.spontEventRate = self.mapAvg.spontEventRate;
    
    edStack = [self.recordings.DirectResponseAmplitude];
    edStack = [edStack.Data];
    
    function map = meanWithoutAnyDirectResponses(maps,mask)
        maps(mask ~= 0) = NaN;
        map = nanmean(maps,2);
    end

    function map = meanWithoutTrueDirectResponses(maps,mask)
        map = nanmean(maps,2);
        map = map.*isnan(mask);
        map(map == 0) = NaN;
    end
    
    % TODO : this whole map mapStack business is a lazy, messy workaround 
    % to get this stuff working and delete as much code as possible with 
    % minimal effort.  at some point it really needs to be tidied up
    mapStack(1).mapAvgMin = mapAnalysis.Map.reduce(@(m) meanWithoutAnyDirectResponses(m,edStack),self.recordings.MinimumResponseAmplitude);
    mapStack(1).mapAvgMax = mapAnalysis.Map.reduce(@(m) meanWithoutAnyDirectResponses(m,edStack),self.recordings.MaximumResponseAmplitude);
    mapStack(1).mapAvgMean = mapAnalysis.Map.reduce(@(m) meanWithoutAnyDirectResponses(m,edStack),self.recordings.MeanResponseAmplitude);
    mapStack(1).mapAvgOnset = mapAnalysis.Map.reduce(@(m) meanWithoutAnyDirectResponses(m,edStack),self.recordings.MinimumResponseLatency);
    mapStack(1).mapAvgMaxOnset = mapAnalysis.Map.reduce(@(m) meanWithoutAnyDirectResponses(m,edStack),self.recordings.MaximumResponseLatency);
    
    genOnset = mapStack(1).mapAvgOnset.Data;
    
    mapStack(1).mapAvgMinED = mapAnalysis.Map.reduce(@(m) meanWithoutTrueDirectResponses(m,genOnset),self.recordings.MinimumResponseAmplitude);
    mapStack(1).mapAvgMeanED = mapAnalysis.Map.reduce(@(m) meanWithoutTrueDirectResponses(m,genOnset),self.recordings.MeanResponseAmplitude);
    mapStack(1).mapAvgOnsetED = mapAnalysis.Map.reduce(@(m) meanWithoutTrueDirectResponses(m,genOnset),self.recordings.MinimumResponseLatency);
    
    mapStack(1).mapAvgHistoBase = mapAnalysis.Map.reduce(@(m) meanWithoutAnyDirectResponses(m,edStack),self.recordings.AmplitudeHistogramBaselineData);
    mapStack(1).mapAvgHistoSyn = mapAnalysis.Map.reduce(@(m) meanWithoutAnyDirectResponses(m,edStack),self.recordings.AmplitudeHistogramSynapticData);
    
    mapStack(1).mapAvgMean4th = mapAnalysis.Map.reduce(@(m) mean(m,2),self.recordings.FourthWindowMeanResponseAmplitude);
    mapStack(1).mapAvgMin4th = mapAnalysis.Map.reduce(@(m) mean(m,2),self.recordings.FourthWindowMinimumResponseAmplitude);
    mapStack(1).mapAvgMax4th = mapAnalysis.Map.reduce(@(m) mean(m,2),self.recordings.FourthWindowMaximumResponseAmplitude);

    
    %     if get(handles.chkShowHistoAnalysis, 'Value');
    mapStack(1).mapStackHistoThresh = self.amplitudeHistogramAnalysis(self.recordings,mapStack);
    %     end
    arrayAveragePlots(self,mapStack);

%     s = -sum(mapStackHistoThresh, 3);
%     s(isnan(s))=inf;
%     mapStack(1).mapAvgEventNumSum = abs(s);

    set(self.Figure,'Pointer','Arrow');
end