classdef CellRecording < mapAnalysis.Recording
    properties(Access=protected)
        Directory_
    end
    
    properties
        CMembrane
        RMembrane
        RSeries
        Tau
        
        TotalNumberOfSites
        TotalNumberOfSpikes
        SpikesPerSite
        NormTotalNumberOfSpikes
        MeanWeightedDistanceFromSoma
        FWHM
    end
    
    % maps
    properties
        Raw mapAnalysis.Map
        BaselineSubtracted mapAnalysis.Map
        Filtered mapAnalysis.Map
        MinimumResponseAmplitude mapAnalysis.Map
        MaximumResponseAmplitude mapAnalysis.Map
        MeanResponseAmplitude mapAnalysis.Map
        MinimumResponseLatency mapAnalysis.Map
        MaximumResponseLatency mapAnalysis.Map
        DirectResponseAmplitude mapAnalysis.Map
        DirectResponseOccurence mapAnalysis.Map
        ExcitatorySynapticResponseAmplitude mapAnalysis.Map
        ExcitatorySynapticResponseOccurence mapAnalysis.Map
        InhibitorySynapticResponseAmplitude mapAnalysis.Map
        InhibitorySynapticResponseOccurence mapAnalysis.Map
        ActionPotentialNumber mapAnalysis.Map
        ActionPotentialLatency mapAnalysis.Map
        ActionPotentialDelayArray mapAnalysis.Map % TODO : better name
        ActionPotentialOccurrence mapAnalysis.Map
        AmplitudeHistogramBaselineData mapAnalysis.Map% TODO : better names for these two as I have no idea what they're supposed to be
        AmplitudeHistogramSynapticData mapAnalysis.Map
        FourthWindowMinimumResponseAmplitude mapAnalysis.Map
        FourthWindowMaximumResponseAmplitude mapAnalysis.Map
        FourthWindowMeanResponseAmplitude mapAnalysis.Map
    end
    
    methods
        function n = getNMapLocations(self)
            n = numel(self.Raw.Pattern);
        end
        
        % TODO : does this actually work????
        function n = getNTrials(self)
            n = size(self.Raw.Data,2);
        end
        
        function n = getNChannels(self)
            n = size(self.Raw.Data{1},3);
        end
        
        function directory = getDirectory(self)
            directory = self.Directory_;
        end
        
        function setDirectory(self,directory)
            self.Directory_ = directory;
        end
    end
end
    
