classdef Recording < handle
    properties(Dependent=true,SetAccess=immutable)
        RecordingName
    end
    
    properties(Dependent=true)
        Directory
    end
    
    methods
        function name = get.RecordingName(self)
            name = self.getRecordingName();
        end
        
        function directory = get.Directory(self)
            directory = self.getDirectory();
        end
        
        function set.Directory(self,directory)
            self.setDirectory(directory);
        end
    end
    
    methods(Abstract=true)
        name = getRecordingName(self)
        directory = getDirectory(self)
        setDirectory(self,directory)
        highlightMapPixel(self,ax,highlight,color);
        plotMapPattern(self,ax,highlight)
        plotMapAreaOnVideoImage(self,ax,highlight)
    end
    
    methods(Static=true)
        function recording = average(recordings)
            assert(all(isa(recordings,'mapAnalysis.Recording')));
            
            mc = metaclass(recordings(1));
            
            assert(all(arrayfun(@(r) mc == metaclass(r),recordings(2:end))),'All recordings to be averaged must be of the same subclass');
            
            constructor = str2func(mc.Name);
            
            recording = constructor();
            
            for ii = 1:numel(mc.PropertyList)
                property = mc.PropertyList(ii);
                
                if ~strcmp(property.GetAccess,'public') || property.Dependent || property.Constant
                    continue
                end
                
                values = {recordings.(property.Name)};
                
                if all(cellfun(@(A) isa(A,'mapAnalysis.Map'),values))
                    recording.(property.Name) = mapAnalysis.Map.reduce(@(x) mean(x,ndims(x)),values{:});
                    continue
                end
                
                if all(cellfun(@isnumeric,values))
                    if all(cellfun(@isscalar,values))
                        recording.(property.Name) = mean([values{:}]);
                        continue
                    end
                    
                    if all(cellfun(@isvector,values))
                        values = cellfun(@(v) v(:),'UniformOutput',false);
                        recording.(property.Name) = mean([values{:}]);
                    end
                    
                    maxDim = max(cellfun(@ndims,values));
                    
                    try
                        value = cat(maxDim,values{:});
                    catch err
                        if ~strcmp(err.identifier,'MATLAB:catenate:dimensionMismatch')
                            throw(err);
                        end
                        
                        warning('ShepherdLab:mapAnalysis:Recording:average:DimensionMismatch','Can not concatenate values of property %s into a hyper-rectangle, %s will have its default value in the average Recording.\n',property.Name,property.Name);
                        continue
                    end
                    
                    recording.(property.Name) = mean(value,maxDim);
                    continue
                end
                
                warning('ShepherdLab:mapAnalysis:Recording:average:UnknownType','Don''t know how to concatenate values of property %s with type %s, so taking the value from the first Recording.\n',property.Name,class(values{1}));
                
                recording.(property.Name) = values{1};
            end
        end
    end
end