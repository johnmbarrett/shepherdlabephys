classdef Recording < dynamicprops
    properties(Dependent=true)
        Maps
    end
    
    properties(Dependent=true,SetAccess=immutable)
        RecordingName
    end
    
    properties(Access=protected)
        Maps_ = struct([]);
    end
    
    methods(Abstract=true)
        name = getRecordingName(self)
    end
    
    methods(Access=protected)
        function self = Recording(dynamicProps)
            assert(iscellstr(dynamicProps),'ShepherdLab:mapAnalysis:Recording','dynamicprops argument to mapAnalysis.Recording constructor must be a cell array of strings');
            
            for ii = 1:numel(dynamicProps)
                name = dynamicProps{ii};
                prop = addprop(self,name);
                
                prop.Dependent = true;
                prop.GetAccess = 'public';
                prop.SetAccess = 'public';
                
                prop.GetMethod = @(s) self.getField(name);
                prop.SetMethod = @(s,v) self.setField(name,v);
            end
        end
        
        function value = getField(self,name)
            value = self.Maps(1).(name);
        end
        
        function setField(self,name,value)
            self.Maps(1).(name) = value;
        end
    end
    
    methods
        function maps = get.Maps(self)
            maps = self.Maps_;
        end
        
        function set.Maps(self,maps)
            assert(isstruct(maps) && all(structfun(@(s) isa(s,'mapAnalysis.Map'),maps)),'ShepherdLab:mapAnalysis:Cell:InvalidMaps','Maps must be a struct where every member is a mapAnalysis.Map');
            
            self.Maps_ = maps;
        end
        
        function name = get.RecordingName(self)
            name = self.getRecordingName();
        end
    end
end
    