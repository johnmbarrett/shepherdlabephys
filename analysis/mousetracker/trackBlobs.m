function [X,Y] = trackBlobs(V,varargin)
    parser = inputParser;
    
    addParameter(parser,'MaxBlobs',Inf,@(x) validateattributes(x,{'numeric'},{'real' 'positive' 'scalar'}));
    addParameter(parser,'Mask',true,@(x) islogical(x) && ismatrix(x));
    addParameter(parser,'MinBlobSize',0,@(x) validateattributes(x,{'numeric'},{'finite' 'real' 'nonnegative' 'scalar'}));
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
    
    for ii = 2:nFrames
        tic;
        currentBlobs = getBlobs(threshold(V(:,:,ii)) & parser.Results.Mask,parser.Results.MaxBlobs,parser.Results.MinBlobSize);
        newBlobs = cell(size(oldBlobs));
        
        for jj = 1:numel(currentBlobs)
            blob = currentBlobs{jj};
            
            percentOverlap = 100*cellfun(@(b) numel(intersect(b,blob))/numel(union(b,blob)),oldBlobs);
            
            assert(all(isfinite(percentOverlap)),'A non-negative finite number divided by a positive finite number should always a finite number.');
            
            [biggestOverlap,biggestOverlapIndex] = max(percentOverlap);
            
            if biggestOverlap == 0 % assume completely new blob
                % TODO : can a mouse ever move > the entire length of its
                % body in a single frame?  might want to look for
                % similar-sized blobs nearby in this case before assuming a
                % completely new blob?
                X(:,end+1) = NaN; %#ok<AGROW>
                Y(:,end+1) = NaN; %#ok<AGROW>
                blobIndex = size(X,2);
            else
                blobIndex = biggestOverlapIndex;
            end
            
            newBlobs{blobIndex} = blob;
            [X(ii,blobIndex),Y(ii,blobIndex)] = getBlobCoords(blob,sizeV(1:2));
        end
        
        oldBlobs = newBlobs;
        toc;
    end
end

function [X,Y] = getBlobCoords(blobs,sizeI)
    if ~iscell(blobs)
        blobs = {blobs};
    end

    n = numel(blobs);
    X = zeros(1,n);
    Y = zeros(1,n);
    
    for ii = 1:n
        [y,x] = ind2sub(sizeI,blobs{ii});
        X(ii) = mean(x);
        Y(ii) = mean(y);
    end
end

function blobs = getBlobs(I,maxBlobs,minBlobSize)
    blobs = bwconncomp(I);

    % TODO : should really sort by size
    blobs = blobs.PixelIdxList(1:min(numel(blobs.PixelIdxList),maxBlobs));

    blobs(cellfun(@(b) numel(b) < minBlobSize,blobs)) = [];
end