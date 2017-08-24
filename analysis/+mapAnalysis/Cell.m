classdef Cell < handle
    properties
        CMembrane
        RMembrane
        RSeries
        Tau
    end
    
    properties(Dependent=true)
        Maps
    end
    
    properties(Access=protected)
        Maps_ = struct([]);
    end
    
    methods
        function maps = get.Maps(self)
            maps = self.Maps_;
        end
        
        function set.Maps(self,maps)
            assert(isstruct(maps) && all(structfun(@(s) isa(s,'mapAnalysis.Map')),'ShepherdLab:mapAnalysis:Cell:InvalidMaps','Maps must be a struct where every member is a mapAnalysis.Map');
            
            self.Maps_ = maps;
        end
    end
end
    