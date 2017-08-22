function displayVideoImages(self,varargin)
% displayVideoImages
%
% Displays an array of video images in a figure
%
% Editing:
% gs june 2005
% gs may 2006 - modified for ephus etc
% ------------------------------------------------------

    if isempty(self.image.imgDir)
        imgDir = pwd;
    else
        imgDir = self.image.imgDir;
    end

    files = dir([imgDir '/*.tif']);

    if isempty(files)
        return
    end

    figure('Color', 'w', 'DoubleBuffer', 'on', 'Units', 'normalized', ...
        'Position', [.2 .1 .42 .84]);

    numFiles = numel(files);

    [subRows,subCols] = subplots(numFiles);
    
    hsub = zeros(numFiles,1);

    for ii = 1:numFiles
        hsub(ii) = subplot(subRows, subCols, ii);

        fullname = [self.image.imgDir '\' files(ii).name];
        I = imread(fullname);

        imagesc(flipud(I));
        set(gca, 'XTickLabel', [], 'YTickLabel', [], 'YDir', 'normal');
        daspect([1 1 1]);
        title(files(ii).name,'Interpreter','none');
    end

    if isempty(self.experimentName)
        titleStr = 'images';
    else
        titleStr = [self.experimentName ', images'];
    end
    
    text('String', titleStr, 'Units', 'Normalized', 'Position', [0 1.2420], ...
        'FontSize', 12, 'FontWeight', 'Bold', 'Parent', hsub(1), ...
        'Interpreter', 'none');

    colormap(gray(256));
end