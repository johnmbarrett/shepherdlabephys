classdef Recording < handle
    properties(Dependent=true,SetAccess=immutable)
        RecordingName
    end
    
    methods
        function name = get.RecordingName(self)
            name = self.getRecordingName();
        end
    end
    
    methods(Abstract=true)
        name = getRecordingName(self)
    end
end