function I = transformImagePosition(I, spatialRotation, xPatternOffset, yPatternOffset, imageXrange, imageYrange)
    % imagePositionTransformer
    %
    % de-offsets and de-rotates and image
    %
    % Editing:
    % gs may 2006
    % -----------------------------------------------------------

    if isempty(spatialRotation) || isempty(xPatternOffset) || isempty(yPatternOffset) || isempty(imageXrange) || isempty(imageYrange)
        return
    end

    Hlims = [-imageXrange/2 imageXrange/2];
    Vlims = [-imageYrange/2 imageYrange/2];
    [Vsize, Hsize] = size(I);

    HmicronsPerPixel = (max(Hlims) - min(Hlims)) / Hsize;
    HoffsetInPixels = abs(round(xPatternOffset / HmicronsPerPixel));
    HblankPart = zeros(Vsize, HoffsetInPixels);

    if sign(xPatternOffset) == 1
        Itrimmed = I(:, HoffsetInPixels+1:end);
        I = [Itrimmed, HblankPart];
    elseif sign(xPatternOffset) == -1
        Itrimmed = I(:, 1:end-HoffsetInPixels);
        I = [HblankPart, Itrimmed];
    end

    VmicronsPerPixel = (max(Vlims) - min(Vlims)) / Vsize;
    VoffsetInPixels = abs(round(yPatternOffset / VmicronsPerPixel));
    VblankPart = zeros(VoffsetInPixels, Hsize);

    if sign(yPatternOffset) == -1
        Itrimmed = I(VoffsetInPixels+1:end, :);
        I = [Itrimmed; VblankPart];
    elseif sign(yPatternOffset) == 1
       Itrimmed = I(1:end-VoffsetInPixels, :);
        I = [VblankPart; Itrimmed];
    end

    I = imrotate(I, -spatialRotation, 'crop');
end