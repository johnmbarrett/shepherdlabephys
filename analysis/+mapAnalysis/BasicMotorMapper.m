classdef BasicMotorMapper < mapAnalysis.MotorMapper
    methods
        function [trajectory,motionTube] = trackMotion(self,I,varargin) % TODO : this is an absolute behemoth of a method.  Can I break it down somehow?
            parser = inputParser; % TODO : properties?
            parser.KeepUnmatched = true;
            parser.addParameter('GaussianBlurSigma',NaN,@(x) isnumeric(x) && isscalar(x) && isreal(x) && isfinite(x) && x > 0);
            parser.addParameter('MotionTubeMasks',NaN,@(x) iscell(x) && all(cellfun(@(y) isnumeric(y) & isvector(y),x)));
            parser.addParameter('ROIs',NaN,@(x) isa(x,'imroi') || (iscell(x) && all(cellfun(@(A) isequal(size(A),[1 4]),x))) || (isnumeric(x) && ismatrix(x) && size(x,2) == 4));
            parser.addParameter('Templates',NaN,@(x) iscell(x) && all(cellfun(@ismatrix,x)));
            parser.addParameter('UpdateTemplate',false,@(x) isscalar(x) && islogical(x));
            parser.addParameter('VideoOutputFile','trajectory',@(x) (isscalar(x) && isnan(x)) || ischar(x));
            parser.parse(varargin{:});

            updateTemplate = parser.Results.UpdateTemplate;
            
            isImageList = iscellstr(I);

            extraDims = ndims(I)-2*(~isImageList);

            firstFrame = 0;
            ii = 0;
            
            isToBeFiltered = ~isnan(parser.Results.GaussianBlurSigma);

            while std(double(firstFrame(:))) == 0
                ii = ii + 1;
                
                if isImageList
                    firstFrame = imread(I{ii});
                    firstFrameIndex = {[] [] ii}; % TODO : historical reasons
                else
                    firstFrameIndex = [{':' ':' ii} num2cell(ones(1,extraDims-1))];
                    firstFrame = I(firstFrameIndex{:});
                    
                    if isToBeFiltered
                        firstFrame = imgaussfilt(firstFrame,parser.Results.GaussianBlurSigma);
                    end
                end
            end

            if isImageList
                sizeI = size(firstFrame);
            else
                sizeI = size(I);
            end

            if iscell(parser.Results.Templates)
                templates = parser.Results.Templates;

                templatePos = zeros(numel(templates),4);

                for ii = 1:numel(templates)
                    if isToBeFiltered
                        templates{ii} = imgaussfilt(templates{ii},parser.Results.GaussianBlurSigma);
                    end
                    
                    C = normxcorr2(templates{ii},firstFrame);

                    [ymax,xmax] = find(C == max(C(:)));

                    templatePos(ii,1) = xmax(1)-size(templates{ii},2);
                    templatePos(ii,2) = ymax(1)-size(templates{ii},1);
                    templatePos(ii,3) = size(templates{ii},2);
                    templatePos(ii,4) = size(templates{ii},1);
                end
            else
                templateROIs = parser.Results.ROIs;

                if iscell(templateROIs) && all(cellfun(@(A) isequal(size(A),[1 4]),templateROIs))
                    templatePos = vertcat(templateROIs{:});
                elseif isnumeric(templateROIs) && ismatrix(templateROIs) && size(templateROIs,2) == 4
                    templatePos = templateROIs;
                else
                    if ~isa(templateROIs,'imroi')
                        imshow(firstFrame);
                        caxis([0 255]);

                        templateROIs = chooseMultipleROIs;
                    end

                    templatePos = arrayfun(@(roi) roi.getPosition,templateROIs,'UniformOutput',false);
                    templatePos = vertcat(templatePos{:});
                end
            end

            nROIs = size(templatePos,1);

            templateX = cell(nROIs,1);
            templateY = cell(nROIs,1);
            motionTubeMasks = parser.Results.MotionTubeMasks;
            computeMotionTube = iscell(parser.Results.MotionTubeMasks);

            for ii = 1:nROIs
                templateX{ii} = round(templatePos(ii,1)+(1:templatePos(ii,3))-1);

                trimLeft = templateX{ii} < 1;
                trimRight = templateX{ii} > sizeI(2);

                if computeMotionTube
                    [maskY,maskX] = ind2sub(size(templates{ii}),motionTubeMasks{ii});
                else
                    maskX = NaN;
                    maskY = NaN;
                end

                if any(trimLeft)
                    templateX{ii}(trimLeft) = [];
                    trimX = sum(trimLeft);
                    templates{ii}(:,1:trimX) = [];
                    maskX = maskX-trimX;
                    maskY(maskX < 1) = [];
                    maskX(maskX < 1) = [];
                elseif any(trimRight)
                    templateX{ii}(trimRight) = [];
                    templates{ii}(:,(end-sum(trimRight)+1):end) = [];
                    maskY(maskX > size(templates{ii},2)) = [];
                    maskX(maskX > size(templates{ii},2)) = [];
                end

                templateY{ii} = round(templatePos(ii,2)+(1:templatePos(ii,4))-1);

                trimTop = templateY{ii} < 1;
                trimBottom = templateY{ii} > sizeI(1);

                if any(trimTop)
                    templateY{ii}(trimTop) = [];
                    trimY = sum(trimTop);
                    templates{ii}(1:trimY,:) = [];
                    maskY = maskY-trimY;
                    maskX(maskY < 1) = [];
                    maskY(maskY < 1) = [];
                elseif any(trimBottom)
                    templateY{ii}(trimBottom) = [];
                    templates{ii}((end-sum(trimBottom)+1):end,:) = [];
                    maskX(maskY > size(templates{ii},1)) = [];
                    maskY(maskY > size(templates{ii},1)) = [];
                end

                if computeMotionTube && (any(trimTop | trimBottom) || any(trimLeft | trimRight))
                    motionTubeMasks{ii} = sub2ind(size(templates{ii}),maskY,maskX);
                end
            end

            if ~exist('templates','var')
                templates = cellfun(@(x,y) firstFrame(x,y),templateY,templateX,'UniformOutput',false);
            end

            if isImageList
                nFrames = numel(I);
            else
                nFrames = prod(sizeI(3:end));
            end

            xcenter = round(cellfun(@mean,templateX));
            ycenter = round(cellfun(@mean,templateY));

            searchX = arrayfun(@(x) unique(min(sizeI(2),max(1,x+(-100:100)))),xcenter,'UniformOutput',false);
            searchY = arrayfun(@(y) unique(min(sizeI(1),max(1,y+(-100:100)))),ycenter,'UniformOutput',false);

            trajectory = zeros(nFrames,2,nROIs);
            trajectory(1:(firstFrameIndex{3}-1),:,:) = NaN;
            trajectory(firstFrameIndex{3},1,:) = templatePos(:,1)+templatePos(:,3)/2;
            trajectory(firstFrameIndex{3},2,:) = templatePos(:,2)+templatePos(:,4)/2;

            if computeMotionTube
                motionTube = cellfun(@(Y,X) nan(numel(Y),numel(X),nFrames),templateY,templateX,'UniformOutput',false);

                for ii = 1:nROIs
                    motionTube{ii}(firstFrameIndex{:}) = firstFrame(templateY{ii},templateX{ii});
                    motionTube{ii}(motionTubeMasks{ii}) = nan;
                end
            else
                motionTube = nan;
            end

            outputVideo = ischar(parser.Results.VideoOutputFile);

            if outputVideo
                fig = figure;
                set(fig,'Position',[100 100 sizeI(2) sizeI(1)]);
                ax = gca;
                set(ax,'Position',[0 0 1 1]);
                self.plotFrameWithTemplateMarker(ax,firstFrame,trajectory(firstFrameIndex{3},1,:),trajectory(firstFrameIndex{3},2,:),templateX,templateY);

                trajectoryVideo = VideoWriter(parser.Results.VideoOutputFile);
                trajectoryVideo.FrameRate = 30; % TODO : pass in frame rate
                open(trajectoryVideo);
                writeVideo(trajectoryVideo,getframe(fig));
            end

            for jj = (firstFrameIndex{3}+1):nFrames
        %         tic;

                if isImageList
                    nextFrame = imread(I{jj});
                    nextFrameIndex = {[] [] jj}; % TODO : historical reasons
                else
                    nextFrameIndex = cell(1,extraDims);
                    [nextFrameIndex{:}] = ind2sub(sizeI(3:end),jj);
                    nextFrameIndex = [{':' ':'} nextFrameIndex]; %#ok<AGROW>
                    nextFrame = I(nextFrameIndex{:});
                end
                    
                if isToBeFiltered
                    nextFrame = imgaussfilt(nextFrame,parser.Results.GaussianBlurSigma);
                end

                s = std(double(nextFrame(:)));
                if s == 0 || isnan(s)
                    trajectory(jj,:,:) = NaN;

                    if outputVideo
                        writeVideo(trajectoryVideo,zeros(size(nextFrame)));
                    end

                    continue
                end

                if outputVideo || computeMotionTube
                    matchX = cell(size(templateX));
                    matchY = cell(size(templateY));
                end

                for kk = 1:nROIs
                    template = templates{kk};

                    C = normxcorr2(template,nextFrame(searchY{kk},searchX{kk}));

                    [ymax,xmax] = find(C == max(C(:)));

                    trajectory(jj,:,kk) = [xmax(1)-size(template,2)/2+searchX{kk}(1)-1 ymax(1)-size(template,1)/2+searchY{kk}(1)-1];

                    if ~outputVideo && ~updateTemplate && ~computeMotionTube
                        continue
                    end

                    originalMatchX = xmax(1)-size(template,2)+(1:size(template,2))+searchX{kk}(1)-1; % TODO : is the first one always the best?

                    trimLeft = originalMatchX < 1;
                    trimRight = originalMatchX >= sizeI(2);

                    assert(~(any(trimLeft) && any(trimRight)));

                    matchX{kk} = originalMatchX(~trimLeft & ~trimRight);

                    originalMatchY = ymax(1)-size(template,1)+(1:size(template,1))+searchY{kk}(1)-1;

                    trimTop = originalMatchY < 1;
                    trimBottom = originalMatchY >= sizeI(1);

                    assert(~(any(trimTop) && any(trimBottom)));

                    matchY{kk} = originalMatchY(~trimTop & ~trimBottom);

                    if ~computeMotionTube
                        continue
                    end

                    motionTubeFrame = nextFrame(matchY{kk},matchX{kk});

                    maskIndices = motionTubeMasks{kk};

                    xStart = 1;
                    yStart = 1;
                    xEnd = numel(matchX{kk});
                    yEnd = numel(matchY{kk});

                    [maskY,maskX] = ind2sub([yEnd xEnd],maskIndices);

                    if any(trimLeft)
                        trimX = sum(trimLeft);
                        maskX = maskX - trimX;
                        toTrim = maskX > 0;
                        maskX = maskX(toTrim);
                        maskY = maskY(toTrim);
                        xEnd = xEnd-trimX;
                    elseif any(trimRight)
                        trimX = sum(trimRight);
                        toTrim = maskX > xEnd-trimX;
                        maskX(toTrim) = [];
                        maskY(toTrim) = [];
                        xStart = xStart + trimX;
                    end

                    if any(trimTop)
                        trimY = sum(trimTop);
                        maskY = maskY - trimY;
                        toTrim = maskY > 0;
                        maskY = maskY(toTrim);
                        maskX = maskX(toTrim);
                        yEnd = yEnd-trimY;
                    elseif any(trimBottom)
                        trimY = sum(trimBottom);
                        toTrim = maskY > yEnd-trimY;
                        maskY(toTrim) = [];
                        maskX(toTrim) = [];
                        yStart = yStart + trimY;
                    end

                    if any(trimLeft) || any(trimRight) || any(trimTop) || any(trimBottom)
                        maskIndices = sub2ind([numel(yStart:yEnd) numel(xStart:xEnd)],maskY,maskX);
                    end

                    motionTubeFrame(maskIndices) = nan;

                    motionTubeFrameIndex = [{yStart:yEnd} {xStart:xEnd} nextFrameIndex(3:end)];

                    motionTube{kk}(motionTubeFrameIndex{:}) = motionTubeFrame;
                end

                if outputVideo
                    self.plotFrameWithTemplateMarker(ax,nextFrame,trajectory(jj,1,:),trajectory(jj,2,:),matchX,matchY);

                    writeVideo(trajectoryVideo,getframe(fig));
                end

                if updateTemplate
                    templates = cellfun(@(x,y) nextFrame(x,y),matchY,matchX,'UniformOutput',false);
                    xcenter = round(cellfun(@mean,matchX));
                    ycenter = round(cellfun(@mean,matchY));
                    searchX = arrayfun(@(x) unique(min(sizeI(2),max(1,x+(-100:100)))),xcenter,'UniformOutput',false);
                    searchY = arrayfun(@(y) unique(min(sizeI(1),max(1,y+(-100:100)))),ycenter,'UniformOutput',false);
                end

        %         toc;
            end

            if outputVideo
                close(trajectoryVideo); % TODO : oncleanup
                close(fig);
            end
        end
        
        function [map,trajectories,pathLengths,motionTubes,roiPositions,saveFile] = mapMotion(self,files,varargin)
            [roiPositions,templates,masks] = mapAnalysis.BasicMotorMapper.getROIs(files,varargin{:});
            
            roisIndex = find(strcmpi('ROIs',varargin));
            
            if ~isempty(roisIndex)
                varargin(roisIndex+[0 1]) = [];
            end
            
            varargin = [{'ROIs' roiPositions 'Templates' templates 'VideoOutputFile' NaN 'MotionTubeMasks' masks} varargin];
            
            [map,trajectories,pathLengths,motionTubes,roiPositions,saveFile] = mapMotion@mapAnalysis.MotorMapper(self,files,varargin{:});
        end
    end
    
    methods(Static=true)
        function [roiPositions,templates,masks] = getROIs(files,varargin)
            parser = inputParser; % TODO : can these parameters be promoted to properties?
            parser.KeepUnmatched = true;
            parser.addParameter('ROIs',NaN,@(x) isa(x,'imroi') || (iscell(x) && all(cellfun(@(A) isequal(size(A),[1 4]),x))) || (isnumeric(x) && ismatrix(x) && size(x,2) == 4));
            parser.addParameter('MotionTubeMasks',NaN,@(x) iscell(x) && all(cellfun(@(y) isnumeric(y) && isvector(y) && all(isreal(y) & isfinite(y) & y > 0),x)));
            parser.addParameter('UseMeanFirstImage',false,@(x) isscalar(x) && islogical(x));
            parser.parse(varargin{:});

            roiPositions = parser.Results.ROIs;

            I = loadLXJOrMATFile(files{1}); % TODO : extract handling of different file formats into its own class

            nTrials = numel(I); % TODO : really not this
            nFiles = numel(files);
            
            if parser.Results.UseMeanFirstImage
                meanFirstImage = zeros(imageSize); % do this for speed in case we need it because it doesn't slow us down much if we do

                for ii = 1:numel(files)
                    tic;
                    if ii > 1
                        I = loadLXJOrMATFile(files{ii});
                    end

                    for jj = 1:numel(I)
                        meanFirstImage = meanFirstImage + double(I{jj}(:,:,1))/(nTrials*nFiles);
                    end
                    toc;
                end
            else
                meanFirstImage = I{1}(:,:,1);
            end

            if isscalar(roiPositions) && isnan(roiPositions)
                figure;
                set(gcf,'Position',[100 100 800 600]);

                imagesc(meanFirstImage);
                colormap(gray);
                daspect([1 1 1]);
                title('Choose ROIs for Motor Mapping');

                rois = chooseMultipleROIs(@imfreehand); % TODO : choose ROI function
                roiPositions = zeros(numel(rois),4);
                masks = cell(size(rois));

                for ii = 1:numel(rois)
                    mask = createMask(rois(ii));
                    pos = regionprops(mask,'BoundingBox');
                    pos = pos.BoundingBox;

                    roiPositions(ii,:) = pos;

                    masks{ii} = find(~mask( ...
                        max(1,round(pos(2))):min(size(meanFirstImage,1),round(pos(2)+pos(4))),  ...
                        max(1,round(pos(1))):min(size(meanFirstImage,2),round(pos(1)+pos(3)))   ...
                        ));
                end

                close(gcf);
            else
                masks = parser.Results.MotionTubeMasks;
            end
            
            if iscell(roiPositions)
                roiPositions = vertcat(roiPositions{:}); % TODO : untested
            end
                
            templates = cell(size(roiPositions,1),1);
            
            for ii = 1:size(roiPositions,1)
                pos = roiPositions(ii,:);
                
                templates{ii} = meanFirstImage( ...
                    max(1,round(pos(2))):min(size(meanFirstImage,1),round(pos(2)+pos(4))),  ...
                    max(1,round(pos(1))):min(size(meanFirstImage,2),round(pos(1)+pos(3)))   ...
                    );
            end
        end
    end

    methods(Access=protected)
        function plotFrameWithTemplateMarker(~,ax,frame,x,y,templateX,templateY)
            cla;
            surf(flipud(frame));
            shading interp;
            colormap(gray);
            view(2);
            hold on;

            for ii = 1:numel(x)
                plot3(ax,x(ii),size(frame,1)-y(ii)+1,1e3,'Color','none','Marker','o','MarkerEdgeColor','r');
                line(ax,templateX{ii}([1 end; end end; end 1; 1 1]),size(frame,1)-templateY{ii}([1 1; 1 end; end end; end 1])+1,1000*ones(4,2),'Color','g');
            end

            xlim([0 size(frame,2)]);
            ylim([0 size(frame,1)]);
            set(ax,'XTick',[],'YTick',[]);
            
            drawnow;
        end
    end
end