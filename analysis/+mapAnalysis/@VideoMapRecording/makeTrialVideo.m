function makeTrialVideo(self,locationIndex,bodyPartIndex,trialIndex,varargin) % TODO : make it so that you can exclude bodyPartIndex if it's unnecessary
    if nargin < 4 || ischar(trialIndex)
        if nargin >= 4
            varargin = [{trialIndex} varargin];
        end
        
        trialIndex = bodyPartIndex;
        bodyPartIndex = 1:size(self.Map,2);
        isROICutoutOrMotionTube = false;
    else
        isROICutoutOrMotionTube = true;
    end

    parser = inputParser;
    
    % TODO : relax scalar requirement?
    % TODO : introduce lambda lambda for validation because the only thing
    % that's changing between these 3 is the max value
    parser.addRequired('locationIndex',@(x) isscalar(x) && isnumeric(x) && isreal(x) && isfinite(x) && x > 0 && x <= size(self.Map,1) && round(x) == x);
    parser.addRequired('bodyPartIndex',@(x) ~isROICutoutOrMotionTube || (isscalar(x) && isnumeric(x) && isreal(x) && isfinite(x) && x > 0 && x <= size(self.Map,2) && round(x) == x));
    parser.addRequired('trialIndex',@(x) isscalar(x) && isnumeric(x) && isreal(x) && isfinite(x) && x > 0 && x <= size(self.PathLengths,2) && round(x) == x);
    
    isScalarLogical = @(x) isscalar(x) && islogical(x);
    
    parser.addParameter('HighlightROIs',false,isScalarLogical);
    parser.addParameter('TraceTrajectory',false,isScalarLogical);
    parser.addParameter('ROICutoutOnly',false,isScalarLogical);
    parser.addParameter('MotionTubeOnly',false,isScalarLogical);
    
    parser.addParameter('Padding',25,@(x) isscalar(x) && isnumeric(x) && isreal(x) && isfinite(x) && x >= 0 && round(x) == x);
    
    parser.parse(locationIndex,bodyPartIndex,trialIndex,varargin{:});
    
    % TODO : assume one or the other if bodyPartIndex is specified?  or
    % allow bodyPartIndex for TraceTrajectory/HighlightROIs when making the
    % whole body video?
    assert(isROICutoutOrMotionTube == (parser.Results.ROICutoutOnly || parser.Results.MotionTubeOnly),'mm:MotorMapping:MotorMappingResult:makeTrialVideo:InvalidArgument','A bodyPartIndex  must be specified if and only if exactly one of ROICutoutOnly and MotionTubeOnly is also specifed');
    
    assert(~(parser.Results.ROICutoutOnly && parser.Results.MotionTubeOnly),'mm:MotorMapping:MotorMappingResult:makeTrialVideo:InvalidArgument','You may only specify one of ROICutoutOnly and MotionTubeOnly');
    
    isPlainVideo = ~(parser.Results.HighlightROIs || parser.Results.TraceTrajectory || parser.Results.MotionTubeOnly);
    
    videoFile = self.Files{locationIndex}; %sprintf('VT%d',locationIndex-1); % TODO : store this information when generating the motor mapping result
    
    if ~strcmp(videoFile(end-3:end),'.mat')
        videoFile = [videoFile '.mat'];
    end
    
    load(videoFile,'VT'); % TODO : push file/video handling into its own dedicated wrapper class with support for multiple file formats
    
    roiPositions = self.ROIs;
    
    if isROICutoutOrMotionTube
        roiPosition = round(roiPositions(bodyPartIndex,:))+[-1 -1 2 2]*parser.Results.Padding;
        yidx = unique(max(1,min(size(VT{trialIndex},1),roiPosition(1)+(0:roiPosition(3))))); %#ok<USENS>
        xidx = unique(max(1,min(size(VT{trialIndex},1),roiPosition(1)+(0:roiPosition(3)))));
    else
        yidx = 1:size(VT{trialIndex},1);
        xidx = 1:size(VT{trialIndex},2);
    end
    
    yoffset = yidx(1)-1;
    xoffset = xidx(1)-1;
    
    trajectories = self.Trajectories;
    
    if parser.Results.MotionTubeOnly
        V = nan(size(VT{trialIndex}));
        motionTube = self.MotionTubes{locationIndex,trialIndex}{bodyPartIndex};

        for ii = 1:size(V,3)
            V( ...
                round(trajectories{locationIndex,trialIndex}(ii,2,bodyPartIndex))+(1:size(motionTube,1))-ceil(size(motionTube,1)/2), ...
                round(trajectories{locationIndex,trialIndex}(ii,1,bodyPartIndex))+(1:size(motionTube,2))-ceil(size(motionTube,2)/2), ...
                ii) = motionTube(:,:,ii);
        end

        V = V(yidx,xidx,:);
        V(isnan(V)) = 255;
        
        % TODO : mmm spaghetti
        yidx = 1:size(V,1);
        xidx = 1:size(V,2);
    else
        V = VT{trialIndex};
    end
    
    if parser.Results.TraceTrajectory
        colours = jet(size(V,3)); % TODO : control colours
        imageFun = @(I) (128+double(I)/2)/255; % TODO : specify transparency?
        cax = [0 1];
    elseif ~isPlainVideo
        imageFun = @(I) double(I)/255;
        cax = [0 1];
    end
    
    if ~isPlainVideo
        fig = figure;
        set(fig,'Position',[100 100 size(V,2) size(V,1)]);
        ax = subplot('Position',[0 0 1 1]);
    end
    
    w = VideoWriter(sprintf('%s_trial_%d_test.avi',videoFile,trialIndex)); % TODO : more control over file naming
    open(w);
    
    phs = gobjects(1,numel(bodyPartIndex));
    lhs = gobjects(4,numel(bodyPartIndex));

    for ii = 1:size(V,3)
        tic; % TODO : logging
        if isPlainVideo
            writeVideo(w,V(yidx,xidx,ii)); % TODO : see above RE video/file handling, also do we *really* need imageFun here?
            toc;
            continue
        end
        
        if ii == 1
            img = image(ax,imageFun(V(yidx,xidx,ii)),'CDataMapping','scaled');
            colormap(ax,gray(255));
            caxis(ax,cax);
            box(ax,'off');
            set(ax,'XTick',[],'YTick',[]);
            hold(ax,'on');
        else
            set(img,'CData',imageFun(V(yidx,xidx,ii)));
        end
        
        if parser.Results.HighlightROIs
            if ii > 1
                delete(phs);
                delete(lhs);
            end
            
            for jj = bodyPartIndex
                phs(jj) = plot(ax,trajectories{locationIndex,trialIndex}(ii,1,jj)-yoffset,trajectories{locationIndex,trialIndex}(ii,2,jj)-xoffset,'LineStyle','none','Marker','o','MarkerEdgeColor','r');
                lhs(:,jj) = line(ax,   ...
                    roiPositions(jj,1)+[0 1 1 0; 1 1 0 0]*roiPositions(jj,3)+trajectories{locationIndex,trialIndex}(ii,1,jj)-trajectories{locationIndex,trialIndex}(1,1,jj)-yoffset,   ...
                    roiPositions(jj,2)+[0 0 1 1; 0 1 1 0]*roiPositions(jj,4)+trajectories{locationIndex,trialIndex}(ii,2,jj)-trajectories{locationIndex,trialIndex}(1,2,jj)-xoffset,   ...
                'Color','g');
            end
        end
        
        if parser.Results.TraceTrajectory
            for jj = bodyPartIndex
                plot(trajectories{locationIndex,trialIndex}(unique(max(1,ii-[1;0])),1,jj)-yoffset,trajectories{locationIndex,trialIndex}(unique(max(1,ii-[1;0])),2,jj)-xoffset,'Color',colours(ii,:));
            end
        end
        
        writeVideo(w,getframe(ax));

        toc;
    end

    close(w);
    
    if ~isPlainVideo
        close(fig);
    end
end