classdef VideoMapRecording < mapAnalysis.Recording
    properties(Access=public)
        AlignmentInfo
        ROIs
    end
    
    properties(Access=public,Dependent=true)
        BodyParts
    end
    
    properties(GetAccess=public,SetAccess=protected,Dependent=true)
        Filenames
        Distance
        AverageDistance
    end
    
    properties
        % TODO : TotalMovement and PathLengths can be derived from
        % trajectories, so maybe they should be moved to lazy-loaded
        % Dependent properties in the style of Displacement
        TotalMovement mapAnalysis.Map
        MotionTubes mapAnalysis.Map
        PathLengths mapAnalysis.Map
        Trajectories mapAnalysis.Map
    end
    
    properties(Access=protected)
        BodyParts_
        Filenames_
        Distance_
        AverageDistance_
    end
    
    methods
        function la = get.AlignmentInfo(self)
            la = self.AlignmentInfo;
        end
        
        function set.AlignmentInfo(self,la)
            assert(isa(la,'mapAnalysis.LaserAlignment') || (isnumeric(la) && isscalar(la) && isnan(la)),'ShepherdLab:mapAnalysis:VideoMapRecording:IllegalLaserAlignment','Alignment info must be of class mapAnalysis.LaserAlignment or a scalar NaN');
            self.AlignmentInfo = la;
        end
        
        function bodyParts = get.BodyParts(self)
            bodyParts = self.BodyParts_;
        end
        
        function set.BodyParts(self,bodyParts)
            assert(iscellstr(bodyParts),'ShepherdLab:mapAnalysis:VideoMapRecording:InvalidBodyParts','BodyParts must be a cell array of strings of length equal to the number of columns in Map');
            
            self.BodyParts_ = bodyParts;
        end
        
        function distance = get.Distance(self)
            if isempty(self.Trajectories)
                distance = [];
                return
            end
            
            % TODO: what if trajectories is dirty? we need to make that
            % dependent and have it clear the properties that depend on it
            if isa(self.Distance_,'mapAnalysis.Map')
                distance = self.Distance_;
                return
            end
            
            distance = self.Trajectories.derive(@(x) cellfun(@(y) [0 0; squeeze(sqrt(sum(diff(y,[],1).^2,2)))],x,'UniformOutput',false));
        end
        
        function averageDistance = get.AverageDistance(self)
            if isempty(self.Trajectories)
                averageDistance = [];
                return
            end
            
            % TODO: what if trajectories is dirty? we need to make that
            % dependent and have it clear the properties that depend on it
            if isa(self.AverageDistance_,'mapAnalysis.Map')
                averageDistance = self.AverageDistance_;
                return
            end
            
            function y = safeMean(x)
                maxLength = max(cellfun(@(x) size(x,1),x));
                
                for ii = 1:numel(x)
                    x{ii}(end+(1:max(0,maxLength-size(x,1))),:) = NaN;
                end
                
                y = permute(mean(reshape(cat(3,x{:}),[size(x{1}) size(x)]),4),[3 1 2]);
            end
            
            averageDistance = self.Distance.derive(@safeMean);
        end
        
        function files = get.Filenames(self)
            files = self.Filenames_;
        end
        
        [figs,tf,warpedMaps,refs] = alignHeatmapToBrainImage(self,brainImage)
        
        makeTrialVideo(self,locationIndex,bodyPartIndex,trialIndex,varargin)
        
        hs = plot(self,useRealCoords,bregmaCoordsPX)
        
        h = plotMotionTube(self,locationIndex,bodyPartIndex,trialIndex)
        
        hs = plotSkew(self,bregmaCoordsPx); % TODO : better name
        
        hs = plotTrajectories(self,l,varargin)
        
        function name = getRecordingName(self)
            if isempty(self.Filenames)
                name = 'Unknown experiment';
                return
            end
            
            % TODO : does matlab seriously not have a builtin for this?  if
            % so I should use it, if not I should make a util
            dirs = strsplit(fileparts(self.Filenames{1}),{'\' '/'});
            dirs = dirs(~cellfun(@isempty,dirs));
            name = strjoin(dirs(end-2:end),'/');
        end
        
        function directory = getDirectory(self)
            if isempty(self.Filenames)
                directory = '';
            else
                directory = fileparts(self.Filenames{1});
            end
        end
        
        function setDirectory(~,~)
            error('ShepherdLab:mapAnalysis:VideoMapRecording:setDirectory:CannotSetDirectory','You can not set the directory of a VideoMapRecording');
        end
        
        function [r,c] = convertImageCoordinatesToMapCoordinates(self,x,y,~,maxRows,maxCols)
            [r,c] = self.AlignmentInfo.AlignmentTransform.transformPointsInverse(x,y);
            r = max(0,min(maxRows,round(r)));
            c = max(0,min(maxCols,round(c)));
        end
        
        function highlightMapPixel(self,ax,highlight,color)
            [y,x] = ind2sub(size(self.TotalMovement.Pattern),highlight);
            
            if strcmp(get(ax,'Tag'),'sliceaxis')
                [x,y] = self.AlignmentInfo.AlignmentTransform.transformPointsForward(y,x);
            end
            
            delete(findobj(ax,'Marker','*'));
            
            plot(ax,x,y,'Color',color,'Marker','*');
        end
        
        function handle = plotMapPattern(self,ax,highlight)
            cla(ax);
            
            handle = imagesc(ax,flipud(self.TotalMovement.Pattern));
            
            hold(ax,'on');
            
            set(ax,'Tag','mapaxis','YDir','normal');
            xlabel(ax,'<- left | right ->');
            ylabel(ax,'<- caudal | rostral ->');
            
            self.highlightMapPixel(ax,highlight,'c');
        end
        
        function [sliceHandle,blankMapHandle] = plotMapAreaOnVideoImage(self,ax,img,highlight,varargin)
            cla(ax);
            
            sliceHandle = imagesc(ax,img);
            daspect(ax,[1 1 1]);
            
            hold(ax,'on');
            
            [X,Y] = meshgrid(1:self.AlignmentInfo.Rows,1:self.AlignmentInfo.Cols);
            
            [U,V] = self.AlignmentInfo.AlignmentTransform.transformPointsForward(X,Y);
            
            blankMapHandle = plot(ax,U,V,'Color','m','LineStyle','none','Marker','o');
            
            set(ax,'Tag','sliceaxis');
            
            self.highlightMapPixel(ax,highlight,'w');
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
                    factors = [1; unique(cumprod(perms(factor(n)),2))];
                    
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
            recording.ROIs = roiPositions;
            
            if exist('files','var')
                recording.Filenames_ = files;
            else
                warning('ShepherdLab:mapAnalysis:VideoMapRecording:fromMATFile:FilesNotFound','Full paths were not saved in motor mapping result file %s, assuming files have standard naming and are located in the same folder as the result file.\n',matFile);
                
                [~,attributes] = fileattrib(matFile);
            
                path = fileparts(attributes.Name);
                
                load(matFile,'map');
                
                recording.Filenames_ = arrayfun(@(ii) sprintf('%s\\VT%d.mat',path,ii-1),1:size(map,1),'UniformOutput',false);
            end
        end
        
        function mmr = fromVideoFiles(videoFiles,varargin) % TODO : other parameters
            bmm = mm.BasicMotorMapper;
            
            [~,~,~,~,~,saveFile] = bmm.mapMotion(videoFiles,varargin{:});
            
            mmr = mm.MATFileMotorMappingResult(saveFile);
        end
    end
end
