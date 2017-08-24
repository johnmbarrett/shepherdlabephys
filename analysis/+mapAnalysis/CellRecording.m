classdef CellRecording < mapAnalysis.Recording
    properties
        CMembrane
        RMembrane
        RSeries
        Tau
    end
    
    methods
        function self = CellRecording()
            self@mapAnalysis.Recording({'Raw' 'BaselineSubtracted' 'Filtered'});
        end
    end
end
    