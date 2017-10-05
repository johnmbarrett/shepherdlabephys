classdef LaserAlignment
    properties
        Angle
        VScale
        XOffset
        YOffset
    end
    
    properties(GetAccess=public,SetAccess=protected)
        Rows
        Cols
        GridCoordinates % in top view imaging space
        GridParameters
        AlignmentTransform % from map co-ordinates to top view image coordinates
    end
    
    methods
        function self = LaserAlignment(rows,cols,angle,vScale,xOffset,yOffset,gridCoordinates,gridParameters,alignmentTransform)
            if nargin == 0
                return
            end
            
            % TODO : validation
            if nargin > 0
                self.Rows = rows;
            end
            
            if nargin > 1
                self.Cols = cols;
            end
            
            if nargin > 2
                self.Angle = angle;
            end
            
            if nargin > 3
                self.VScale = vScale;
            end
            
            if nargin > 4
                self.XOffset = xOffset;
            end
            
            if nargin > 5
                self.YOffset = yOffset;
            end
            
            if nargin > 6
                self.GridCoordinates = gridCoordinates;
            end
            
            if nargin > 7
                self.GridParameters = gridParameters;
            end
            
            if nargin > 8
                self.AlignmentTransform = alignmentTransform;
            end
        end
        
        function result = isnan(~)
            result = false;
        end
    end
    
    methods(Static=true)
        function la = fromLaserImages(rows,cols,imageFolder,blankImageIndex,angle,vScale,xOffset,yOffset,varargin)
            if nargin < 5 || ischar(angle)
                angle = NaN;
                vScale = NaN;
                xOffset = NaN;
                yOffset = NaN;
            end
            
            if ischar(angle)
                varargin = [{angle vScale xOffset yOffset} varargin]; % TODO : this means you either specify all the laser parameters or none, might be better to detect the first character argument and assume all the ones preceding are valid paramters
            end
            
            if nargin < 2
                error('MotorMapping:LaserAlignment:InsufficientParameters','Must provide number of rows & columns to align laser grid');
            end
            
            if nargin < 4
                blankImageIndex = NaN;
            elseif ischar(blankImageIndex)
                varargin = [{blankImageIndex angle vScale xOffset yOffset} varargin];
                blankImageIndex = NaN;
            end

            if nargin < 3 || isempty(imageFolder) || all(isnan(imageFolder(:)))
                imageFolder = uigetdir(pwd,'Choose image folder...');
            end

            cd(imageFolder);
            laserImages = loadFilesInNumericOrder('*.bmp','tt([0-9]+)');
            
            if isnan(blankImageIndex)
                I = imread(laserImages{1});
                J = imread(laserImages{2});
                % mean-subtracting controls for variations in overall brightness
                [~,blankImageIndex] = min([sum(I(:)-mean(I(:))) sum(J(:)-mean(J(:)))]);
            end

            firstImageIndex = 3-blankImageIndex;

            laserImages = laserImages(1:(2*rows*cols));
            
            blankImage = arrayfun(@(idx) imread(laserImages(idx).name),blankImageIndex:2:(2*rows*cols),'UniformOutput',false);
            blankImage = cat(3,blankImage{:});
            blankImage = median(blankImage,3);
            
            laserImages = laserImages(firstImageIndex:2:(2*rows*cols));
            
            varargin = [{'BackgroundSubtraction' true 'BackgroundImage' blankImage} varargin];

            [grid,beta,CX,CY] = fitGridToSpots(laserImages,rows,cols,varargin{:});
            
            figure; % TODO : supress figures?

            imagesc(blankImage);
            colormap(gray);

            hold on;

            scatter(cellfun(@mean,CX),cellfun(@mean,CY));
            scatter(grid(:,1),grid(:,2));

            [~,lastDir] = fileparts(pwd);

            saveFile = [lastDir '_laser_grid_new']; % TODO : more control over saving

            saveas(gcf,saveFile,'fig');

            tf = mapAnalysis.LaserAlignment.createAlignmentTransformation(rows,cols,beta);
            
            save(saveFile,'grid','beta','CX','CY','rows','cols','tf');
            
            la = mapAnalysis.LaserAlignment(rows,cols,angle,vScale,xOffset,yOffset,grid,beta,tf); % TODO : supress figures?
        end
    
        function la = fromMATFile(matFile,angle,vScale,xOffset,yOffset,varargin)
            load(matFile,'grid','beta','rows','cols','tf');
            
            assert(logical(exist('grid','var')),'MotorMapping:LaserAlignment:GridCoordsNotFound','File %s does not contain grid co-ordinates\n',matFile);
            assert(logical(exist('beta','var')),'MotorMapping:LaserAlignment:GridParamsNotFound','File %s does not contain grid parameters\n',matFile);
            assert(logical(exist('rows','var')),'MotorMapping:LaserAlignment:RowsNotFound','File %s does not contain a number of rows\n',matFile);
            assert(logical(exist('cols','var')),'MotorMapping:LaserAlignment:ColsNotFound','File %s does not contain a number of columns\n',matFile);
            
            if ~exist('tf','var')
                tf = mapAnalysis.LaserAlignment.createAlignmentTransformation(rows,cols,beta); % fuck's sake matlab lern2scope
            end
            
             % TODO : fill in NaNs if possible
            if nargin < 2
                angle = NaN;
            end
            
            if nargin < 3
                vScale = NaN;
            end
            
            if nargin < 4
                xOffset = NaN;
            end
            
            if nargin < 5
                yOffset = NaN;
            end
            
            la = mapAnalysis.LaserAlignment(rows,cols,angle,vScale,xOffset,yOffset,grid,beta,tf);
        end
        
        function la = fromNotesFile(params,setupFile,varargin)
            map = str2double(strsplit(params.Map{1},'x'));
            rows = map(1);
            cols = map(2);

            angle = params.Angle;
            vScale = params.VScale;
            xOffset = params.XOff;
            yOffset = params.YOff;
            
            [setupDir,setupFileName] = fileparts(setupFile);

            if exist(setupFile,'file')
                la = mapAnalysis.LaserAlignment.fromMATFile(setupFile,angle,vScale,xOffset,yOffset);
            else
                try
                    la = mapAnalysis.LaserAlignment.fromLaserImages(rows,cols,setupDir,NaN,angle,vScale,xOffset,yOffset,varargin{:});
                catch err
                    logMatlabError(err,sprintf('Encountered the following error trying to align laser for setup %s, using empty LaserAlignment\n',setupFileName));
                    la = LaserAlignment(rows,cols,angle,vScale,xOffset,yOffset);
                end
            end
        end
        
        function la = fromRowsAndCols(rows,cols)
            la = mapAnalysis.LaserAlignment(rows,cols,NaN,NaN,NaN,NaN,NaN,NaN,NaN);
        end
        
        function tf = createAlignmentTransformation(rows,cols,gridParams) % TODO : can a method be both static and non-static?
            movingPoints = [0.5 0.5; 0.5 rows+0.5; cols+0.5 0; cols+0.5 rows+0.5];
            fixedPoints = [ones(4,1) movingPoints]*gridParams;
            tf = fitgeotrans(movingPoints,fixedPoints,'affine');
        end
    end
end