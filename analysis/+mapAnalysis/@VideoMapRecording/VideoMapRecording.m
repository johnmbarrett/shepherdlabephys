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
        
        function name = getRecordingName(~)
            name = 'FUCK YOU';
        end
    end
    
    methods(Static=true)
        function pattern = standardPattern(rows,cols)
            n = rows*cols;
            
            pattern = flipud(reshape(1:n,rows,cols));
        end
        
        function recording = fromMATFile(matFile,rows,cols) % TODO : a superclass that knows about its subclasses?  is that allowed?  maybe a factory class would be better
            recording = mapAnalysis.VideoMapRecording;
            
            load(matFile);
            
            assert(logical(exist('map','var')),'ShepherdLab:mapAnalysis:VideoMapRecording:fromMATFile:TotalMovementNotFound','File %s does not contain a motor map\n',matFile); % TODO : generate if missing
            assert(logical(exist('motionTubes','var')),'ShepherdLab:mapAnalysis:VideoMapRecording:fromMATFile:MotionTubesNotFound','File %s does not contain any motion tubes\n',matFile);
            assert(logical(exist('pathLengths','var')),'ShepherdLab:mapAnalysis:VideoMapRecording:fromMATFile:PathLengthsNotFound','File %s does not contain any path lengths\n',matFile);
            assert(logical(exist('roiPositions','var')),'ShepherdLab:mapAnalysis:VideoMapRecording:fromMATFile:ROIsNotFound','File %s does not contain any ROI coordinates\n',matFile);
            assert(logical(exist('trajectories','var')),'ShepherdLab:mapAnalysis:VideoMapRecording:fromMATFile:TrajectoriesNotFound','File %s does not contain any trajectories\n',matFile);
            
            if nargin < 2
                n = size(map,1);
                m = sqrt(n);
                
                if round(m) == m
                    rows = m;
                    cols = m;
                elseif isprime(n)
                    rows = n;
                    cols = 1;
                else
                    % assume the squarest map we can, with more rows than
                    % columns, because the mouse brain is long
                    factors = [1; unique(cumprod(perms(factor(12)),2))];
                    
                    k = numel(factors);
                    assert(mod(k,2) == 0); % it's not square, so it should have an even number of factors
                    
                    rows = factors(k/2+1);
                    cols = factors(k/2);
                end
            elseif nargin < 3
                cols = rows;
            end
            
            pattern = mapAnalysis.VideoMapRecording.standardPattern(rows,cols);
            
            recording.TotalMovement = mapAnalysis.Map(map,pattern);
            recording.MotionTubes = mapAnalysis.Map(motionTubes,pattern); % TODO : make the cell maps arrays?
            recording.PathLengths = mapAnalysis.Map(pathLengths,pattern);
            recording.Trajectories = mapAnalysis.Map(trajectories,pattern);
            
            if exist('files','var')
                recording.Files_ = files;
            else
                warning('ShepherdLab:mapAnalysis:VideoMapRecording:fromMATFile:FilesNotFound','Full paths were not saved in motor mapping result file %s, assuming files have standard naming and are located in the same folder as the result file.\n',matFile);
                
                [~,attributes] = fileattrib(matFile);
            
                path = fileparts(attributes.Name);
                
                load(matFile,'map');
                
                recording.Files_ = arrayfun(@(ii) sprintf('%s\\VT%d.mat',path,ii-1),1:size(map,1),'UniformOutput',false);
            end
        end
        
        function mmr = fromVideoFiles(videoFiles,varargin) % TODO : other parameters
            bmm = mm.BasicMotorMapper;
            
            [~,~,~,~,~,saveFile] = bmm.mapMotion(videoFiles,varargin{:});
            
            mmr = mm.MATFileMotorMappingResult(saveFile);
        end
    end
end
