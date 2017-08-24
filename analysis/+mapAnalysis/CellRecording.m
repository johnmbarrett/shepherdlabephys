classdef CellRecording < mapAnalysis.Recording
    properties
        CMembrane
        RMembrane
        RSeries
        Tau
    end
    
    methods
        function self = CellRecording()
            self@mapAnalysis.Recording({'RawData' 'BaselineSubtractedData' 'FilteredData'});
        end
    end
end
    