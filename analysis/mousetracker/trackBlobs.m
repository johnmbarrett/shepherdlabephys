function [X,Y,d] = trackBlobs(V,varargin)
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