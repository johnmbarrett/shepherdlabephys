classdef VideoMapRecording < mapAnalysis.Recording
    properties(Access=public)
        AlignmentInfo
        ROIs
    end
    
    properties(Access=public,Dependent=true)
        BodyParts
    end
    
    properties(GetAccess=public,SetAccess=protected,Dependent=true)
        Files
    end
    
    properties
        TotalMovement mapAnalysis.Map
        MotionTubes mapAnalysis.Map
        PathLengths mapAnalysis.Map
        Trajectories mapAnalysis.Map
    end
    
    properties(Access=protected)
        BodyParts_
        Files_
    end
    
    methods
        function la = get.AlignmentInfo(self)
            la = self.AlignmentInfo;
        end
        
        function set.AlignmentInfo(self,la)
            % TODO : pull in LaserAlignment?
            assert(isa(la,'mm.LaserAlignment') || (isnumeric(la) && isscalar(la) && isnan(la)),'ShepherdLab:mapAnalysis:VideoMapRecording:IllegalLaserAlignment','Alignment info must be of class mm.LaserAlignment or a scalar NaN');
            self.AlignmentInfo = la;
        end
        
        function bodyParts = get.BodyParts(self)
            bodyParts = self.BodyParts_;
        end
        
        function set.BodyParts(self,bodyParts)
            assert(iscellstr(bodyParts),'ShepherdLab:mapAnalysis:VideoMapRecording:InvalidBodyParts','BodyParts must be a cell array of strings of length equal to the number of columns in Map');
            
            self.BodyParts_ = bodyParts;
        end
        
        function files = get.Files(self)
            files = self.Files_;
        end
        
        [figs,tf,warpedMaps,refs] = alignHeatmapToBrainImage(self,brainImage)
        
        makeTrialVideo(self,locationIndex,bodyPartIndex,trialIndex,varargin)
        
        hs = plot(self,useRealCoords,bregmaCoordsPX)
        
        h = plotMotionTube(self,locationIndex,bodyPartIndex,trialIndex)
        
        hs = plotSkew(self,bregmaCoordsPx); % TODO : better name
        
        hs = plotTrajectories(self,l,varargin)
    end
    
    methods(Static=true)
        % TODO : pull implementation from motor mapping package
        function mmr = fromMATFile(matFile) % TODO : a superclass that knows about its subclasses?  is that allowed?  maybe a factory class would be better
            mmr = mm.MATFileMotorMappingResult(matFile);
        end
        
        function mmr = fromVideoFiles(videoFiles,varargin) % TODO : other parameters
            bmm = mm.BasicMotorMapper;
            
            [~,~,~,~,~,saveFile] = bmm.mapMotion(videoFiles,varargin{:});
            
            mmr = mm.MATFileMotorMappingResult(saveFile);
        end
    end
end
