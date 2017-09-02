function V = loadVideo(videoFile,varargin)
%LOADVIDEO  Convenience function for loading videos into memory
%
%   V = LOADVIDEO(VIDEOFILE) loads the entirety of the video specified by
%   the path VIDEOFILE into memory and returns the result as a matrix V.
%   Any video format supported by VideoReader can be loaded.
%
%   V = LOADVIDEO(VIDEOFILE,PARAM1,VALUE1,PARAM2,VALUE2,...) allows
%   specifying any of the following name-value pairs:
%
%   'BackgroundImage'       An image of the same size as each frame of V or
%                           a scalar value.  In either case, it is 
%                           subtracted from each frame of V before 
%                           returning.
%   'Binning'               A scalar or a two-element vector.  If set to a
%                           scalar, B, then each BxB region of V is binned 
%                           into a single pixel before returning.  If set 
%                           to a two-element vector, each frame of V is 
%                           shrunk to the specified size by binning.  The 
%                           aspect ratio must be maintained and the value 
%                           of Binning must be equal to the frame size of V
%                           divided by an integer value.
%   'ConvertToGrayscale'    If true, converts V to grayscale by averaging
%                           along the third dimension (which is assumed to
%                           be colour).
%   'MaxFrames'             Maximum number of frames to return.  By
%                           default, all frames in the video are returned.
%   'Scaling'               May be a scalar, in which case V is divided by
%                           the specified value before return, or an image
%                           of the same size as in each frame of V.  In the
%                           latter case, each frame of V is divided 
%                           element-wise by the image provided.  Combining
%                           the BackgroundImage and Scaling options allows
%                           images to be Z-scored by passing in a mean and
%                           a standard deviation image, respectively.

%   Created by John Barrett 2017-08-31 18:12 CDT
%   Last modified by John Barrett 2017-09-01 19:39 CDT

    parser = inputParser;
    
    isImageOrScalar = @(x) isnumeric(x) && (isscalar(x) || (ismember(ndims(x),[2 3]) && ismember(size(x,3),[1 3]) && all(isfinite(x(:)) & isreal(x(:)) & x(:) > 0)));
    addParameter(parser,'BackgroundImage',[],isImageOrScalar);
    % TODO : what about uneven binning?  if we add this at a later date,
    % the two-element form becomes ambiguous, so we should add a new
    % parameter called TargetSize or something
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
            binning = ceil(sizeI(1)./sizeV(1));
            assert(binning == ceil(sizeI(2)./sizeV(2)),'When specifying size to bin to, aspect ratio must be the same as the original video');
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