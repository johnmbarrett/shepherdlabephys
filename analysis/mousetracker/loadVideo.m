function V = loadVideo(videoFile,varargin)
    parser = inputParser;
    
    isImageOrScalar = @(x) isnumeric(x) && (isscalar(x) || (ismember(ndims(x),[2 3]) && ismember(size(x,3),[1 3]) && all(isfinite(x(:)) & isreal(x(:)) & x(:) > 0)));
    addParameter(parser,'BackgroundImage',[],isImageOrScalar);
    addParameter(parser,'Binning',NaN,@(x) isnumeric(x) && ismember(numel(x),[1 2]) && all(isfinite(x) & isreal(x) & round(x) == x));
    addParameter(parser,'ConvertToGrayscale',false,@(x) islogical(x) && isscalar(x));
    addParameter(parser,'MaxFrames',Inf,@(x) isnumeric(x) && isscalar(x) && ~isnan(x) && isreal(x) && x > 0);
    addParameter(parser,'Scaling',[],isImageOrScalar);
    parser.parse(varargin{:});
    
    r = VideoReader(videoFile);
    
    I = readFrame(r);
    sizeI = size(I);
    sizeV = sizeI;
    
    N = ceil(r.Duration*r.FrameRate); % TODO : does this always work?
    N = min(N,parser.Results.MaxFrames);
    sizeV(end+1) = N;
    
    if ndims(I) == 3 && parser.Results.ConvertToGrayscale
        sizeV(3) = [];
    end
    
    binning = parser.Results.Binning;
    isToBeBinned = ~any(isnan(binning));
    
    if isToBeBinned
        if isscalar(binning)
            sizeV(1:2) = ceil(sizeI(1:2)/binning);
        else
            sizeV(1:2) = binning;
            binning = ceil(sizeI(1:2)./sizeV(1:2));
        end
    end
    
    V = zeros(sizeV);
    colons = repmat({':'},1,ndims(V)-1);
    
    r = VideoReader(videoFile);
    
    ii = 0;
    while hasFrame(r) && ii < N
        tic;
        ii = ii + 1;
        
        I = double(readFrame(r));
        
        if parser.Results.ConvertToGrayscale
            I = mean(I,3);
        end
        
        if isToBeBinned
            I = bin(I,binning);
        end
        
        if ~isempty(parser.Results.BackgroundImage)
            I = I-parser.Results.BackgroundImage; % TODO : arg checking
        end
        
        if ~isempty(parser.Results.Scaling)
            I = I./parser.Results.Scaling; % TODO : arg checking
        end
        
        V(colons{:},ii) = I; % TODO : indexing if sizeV(1:2)./sizeI(1:2) is non-integer
        
        toc;
    end
    
    if ii < N
        V(colons{:},(ii+1):N) = [];
    end
end