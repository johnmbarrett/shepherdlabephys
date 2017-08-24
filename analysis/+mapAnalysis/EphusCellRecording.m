classdef EphusCellRecording < mapAnalysis.CellRecording
    properties
        AcquirerHeader
        BaseName
        TraceNumber
        Directory
        Filenames
        HeaderGUI
        ImagingSysHeader
        LaserIntensity
        PhysHeader
        ScopeHeader
        UncagingHeader
        UncagingPathName
    end
    
    methods
        function name = getRecordingName(self)
            name = sprintf('%s%04d',self.BaseName,self.TraceNumber);
        end
    end
end