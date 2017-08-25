classdef CellRecording < mapAnalysis.Recording
    properties
        CMembrane
        RMembrane
        RSeries
        Tau
        Test mapAnalysis.Map;
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
        ActionPotentialOccurrence mapAnalysis.Map
        AmplitudeHistogramBaselineData mapAnalysis.Map% TODO : better names for these two as I have no idea what they're supposed to be
        AmplitudeHistogramSynapticData mapAnalysis.Map
        FourthWindowMinimumResponseAmplitude mapAnalysis.Map
        FourthWindowMaximumResponseAmplitude mapAnalysis.Map
        FourthWindowMeanResponseAmplitude mapAnalysis.Map
    end
end
    
