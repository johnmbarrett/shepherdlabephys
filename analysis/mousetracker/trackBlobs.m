function [X,Y,d] = trackBlobs(V,varargin)
%TRACKBLOBS Track multiple blobs in a series of images
%
%   [X,Y] = TRACKBLOBS(V) finds "blobs" (regions of connected pixels) in
%   the series of images V and tracks them, returning the X and Y
%   co-ordinates of each blob's centre of mass in each frame.  V must be an
%   NxMxP numeric or logical matrix.  If none of the thresholding options
%   are set (see below), V must be pre-binarised for TRACKBLOBS to work 
%   effectively.  The resulting matrices X and Y will have size [P Q],
%   where Q is the number of blobs detected.
%
%   Different numbers of blobs may be detected in each frame.  TRACKBLOBS
%   attempts to keep track of which blob is which by assuming that blobs
%   cannot travel a distance greater than their length in any direction in
%   one frame, hence two blobs that overlap in consecutive frames are
%   likely the same blob.  If a blob overlaps with multiple blobs in the
%   preceding frame, it is assumed to be the blob with which it shares the
%   greatest percentage overlap (100*<number of intesecting pixels>/<number
%   of conjoined pixels>).  If, after applying this heuristic, multiple
%   current blobs overlap with the same preceding blob, the blob with the
%   greatest percentage overlap is assumed to be the preceding blob and the
%   others to have split off from it.  Blobs that don't appear in a frame
%   are assigned NaN X and Y coordinates for that frame.
%
%   [X,Y,d] = TRACKBLOBS(V) additionally returns a 1xQ row vector, d,
%   giving the total distance travelled (in pixels) by each blob.
%
%   [...] = TRACKBLOBS(V,PARAM1,VALUE1,PARAM2,VALUE2,...) allows specifying
%   the following name-value pair arguments:
%
%       'Debug'                     Plots the outline of every blob in the
%                                   frame currently being analyzed and the
%                                   silhouetter of every blob in the
%                                   previous frame, in opposing colours.
%                                   Considerably slows the execution of
%                                   TRACKBLOBS.
%       'MaxBlobs'                  Maximum number of blobs to locate *in
%                                   each frame*.  As blobs may appear,
%                                   disappear, or split off from other
%                                   blobs, the total number of blobs
%                                   returned may be greater than MaxBlobs.
%                                   When excluding blobs, the smallest
%                                   blobs are thrown away first.  Setting
%                                   this option may speed up execution when
%                                   you have many small, artifactual blobs,
%                                   but risks throwing away important blobs
%                                   if you have large artifactual blobs in
%                                   some frames.
%       'Mask'                      Allows specifying the search area.
%                                   Must be an NxM logical matrix.  False
%                                   pixels in mask are not searched for
%                                   blobs.
%       'MinBlobSize'               Blobs containing fewer pixels than this
%                                   value are thrown away in each frame.
%       'MinDistanceTravelled'      Blobs whose centre of mass travels less
%                                   than this many pixels are thrown away
%                                   at the end.
%       'MinExistencePercentage'    Blobs that appear in few than this
%                                   percentage of frames are thrown away at
%                                   the end.
%       'Threshold'                 If Threshold is a scalar, V is
%                                   binarized by applying a threshold of
%                                   the specified value to each frame.  If
%                                   Threshold is a function handle, the
%                                   specified function is applied to each
%                                   frame of V.  The function should accept
%                                   an image matrix and return a binary
%                                   matrix.

%   Created by John Barrett 2017-08-31 18:58 CDT
%   Last modified by John Barrett 2017-09-01 19:23 CDT
    parser = inputParser;
    
    addParameter(parser,'Debug',false,@(x) islogical(x) && isscalar(x));
    addParameter(parser,'MaxBlobs',Inf,@(x) validateattributes(x,{'numeric'},{'real' 'positive' 'scalar'}));
    addParameter(parser,'Mask',true,@(x) islogical(x) && ismatrix(x));
    addParameter(parser,'MinBlobSize',0,@(x) validateattributes(x,{'numeric'},{'finite' 'real' 'nonnegative' 'scalar'}));
    addParameter(parser,'MinDistanceTravelled',0,@(x) validateattributes(x,{'numeric'},{'finite' 'real' 'nonnegative' 'scalar'}));
    addParameter(parser,'MinExistencePercentage',5,@(x) validateattributes(x,{'numeric'},{'finite' 'real' 'scalar' '>=' 0 '<=' 100}));
    addParameter(parser,'Threshold',NaN,@(x) isa(x,'function_handle') || validateattributes(x,{'numeric'},{'finite' 'real' 'nonnegative' 'scalar'}));
    parser.parse(varargin{:});
    
    if isa(parser.Results.Threshold,'function_handle')
        threshold = parser.Results.Threshold;
    elseif isnan(parser.Results.Threshold)
        threshold = @(I) I;
    else
        threshold = @(I) I > parser.Results.Threshold;
    end
    
    initialBlobs = getBlobs(threshold(V(:,:,1)) & parser.Results.Mask,parser.Results.MaxBlobs,parser.Results.MinBlobSize);
    sizeV = size(V);
    nFrames = sizeV(3);
    nBlobs = numel(initialBlobs);
    
    X = nan(nFrames,nBlobs);
    Y = nan(nFrames,nBlobs);
    
    [X(1,:),Y(1,:)] = getBlobCoords(initialBlobs,sizeV(1:2));
    
    if nFrames == 1
        return
    end
    
    oldBlobs = initialBlobs;
    
    if parser.Results.Debug
        figure;
        hold on;
    end
    
    for ii = 2:nFrames
        tic;
        currentBlobs = getBlobs(threshold(V(:,:,ii)) & parser.Results.Mask,parser.Results.MaxBlobs,parser.Results.MinBlobSize);
        
        if parser.Results.Debug
            cla;
            colours = distinguishable_colors(max(numel(oldBlobs),numel(currentBlobs)));
            xlim([0 sizeV(2)]);
            ylim([0 sizeV(1)]);
            
            for jj = 1:numel(oldBlobs)
                if isempty(oldBlobs{jj})
                    continue
                end
                
                [x,y] = ind2sub(sizeV(1:2),oldBlobs{jj});
                shape = alphaShape(x,y);
                plot(shape,'EdgeColor','none','FaceColor',colours(jj,:));
            end
        end 
        
        nextBlobs = cell(size(oldBlobs));
        percentOverlap = zeros(numel(currentBlobs),numel(oldBlobs));
        
        for jj = 1:numel(currentBlobs)
            blob = currentBlobs{jj};
            
            if parser.Results.Debug
                [x,y] = ind2sub(sizeV(1:2),currentBlobs{jj});
                k = boundary(x,y);
                plot(x(k),y(k),'Color',1-colours(jj,:));
                drawnow;
            end
            
            percentOverlap(jj,:) = 100*cellfun(@(b) numel(intersect(b,blob))/numel(union(b,blob)),oldBlobs);
        end
        
        completelyNewBlobs = sum(percentOverlap,2) == 0;
        nCompletelyNewBlobs = sum(completelyNewBlobs);
        
        X(:,end+(1:nCompletelyNewBlobs)) = NaN;
        Y(:,end+(1:nCompletelyNewBlobs)) = NaN;
        nextBlobs(end+(1:nCompletelyNewBlobs)) = currentBlobs(completelyNewBlobs);
        
        currentBlobs(completelyNewBlobs) = [];
        percentOverlap(completelyNewBlobs,:) = [];
        
        [~,nextBlobIndices] = max(percentOverlap,[],2);
        
        [uniqueNextBlobIndices,~,nextBlobIndexIndices] = unique(nextBlobIndices);
        
        for jj = 1:numel(uniqueNextBlobIndices)
            splitBlobIndices = find(nextBlobIndexIndices == jj);
            
            if numel(splitBlobIndices) == 1
                continue
            end
            
            [~,biggestOverlap] = max(percentOverlap(splitBlobIndices,uniqueNextBlobIndices(jj)));
            
            splitBlobIndices(biggestOverlap) = [];
            
            nSplitBlobs = numel(splitBlobIndices);
            
            X(:,end+(1:nSplitBlobs)) = NaN;
            Y(:,end+(1:nSplitBlobs)) = NaN;
            nextBlobs(end+(1:nSplitBlobs)) = currentBlobs(splitBlobIndices);
            
            currentBlobs(splitBlobIndices) = [];
            nextBlobIndices(splitBlobIndices) = [];
        end
        
        assert(isequal(uniqueNextBlobIndices,sort(nextBlobIndices)),'All new and split blobs should have been removed');
        
        nextBlobs(nextBlobIndices) = currentBlobs; % this might leave some blobs empty, but this is okay
        
        [X(ii,:),Y(ii,:)] = getBlobCoords(nextBlobs,sizeV(1:2));
        
        oldBlobs = nextBlobs;
        toc;
    end
    
    isTooTransient = 100*sum(~isnan(X))/size(X,1) < parser.Results.MinExistencePercentage;
    
    X(:,isTooTransient) = [];
    Y(:,isTooTransient) = [];
    
    d = zeros(1,size(X,2));
    
    for ii = 1:size(X,2)
        isIncluded = ~isnan(X(:,ii));
        x = X(isIncluded,ii);
        y = Y(isIncluded,ii);
        d(ii) = sum(sqrt(diff(x).^2+diff(y).^2));
    end
    
    assert(all(isfinite(d)),'If a blob exists in one dimension it must exist in the other');
    
    isTooStationary = d < parser.Results.MinDistanceTravelled;
    
    X(:,isTooStationary) = [];
    Y(:,isTooStationary) = [];
    d(:,isTooStationary) = [];
end

function [X,Y] = getBlobCoords(blobs,sizeI)
    if ~iscell(blobs)
        blobs = {blobs};
    end

    n = numel(blobs);
    X = zeros(1,n);
    Y = zeros(1,n);
    
    for ii = 1:n
        if isempty(blobs{ii})
            X(ii) = nan;
            Y(ii) = nan;
            continue
        end
        
        [y,x] = ind2sub(sizeI,blobs{ii});
        X(ii) = mean(x);
        Y(ii) = mean(y);
    end
end

function blobs = getBlobs(I,maxBlobs,minBlobSize)
    blobs = bwconncomp(I);
    blobs = blobs.PixelIdxList;

    blobSizes = cellfun(@numel,blobs);
    
    tooSmall = blobSizes < minBlobSize;
    
    blobSizes(tooSmall) = [];
    blobs(tooSmall) = [];
    
    if ~isfinite(maxBlobs)
        return
    end
    
    [~,sortIndices] = sort(blobSizes);
    
    blobs(sortIndices(1:end-maxBlobs)) = [];
end