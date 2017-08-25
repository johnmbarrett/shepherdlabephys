function R = chooseImageFile(self,noPlot,varargin)
% chooseImageFile
%
% See also addSliceImage
%
% Editing:
% gs april 2005
% ---------------------------------------------------

% TODO: need to delete the previous images and markers (if any),
% rather than add them to the axes
% ---------------------------------------------------------------

    dir = self.recordingActive.UncagingPathName;
    
    if isempty(dir)
        dir = pwd;
    end
    
    dirs = strsplit(dir, {'\' '/'});
    dirs = dirs(~cellfun(@isempty,dirs));
    
    defaultDirs = {[strjoin(dirs(1:end-1),'/') '/images'] [strjoin(dirs,'/') '/images'] pwd};
    defaultDir = defaultDirs{find(cellfun(@(d) exist(d,'dir'),defaultDirs),1)};
    
    [name, path] = uigetfile([defaultDir '/*.*'], 'Select an image file.');
    
    if isnumeric(name)
        return
    end
    
    fullname = [path name];

    R = imread(fullname);

    self.image.imgDir = path;
    self.image.imgName = name;
    self.image.img = R;
    self.image.info = imfinfo(fullname);
    
    if nargin > 1 && islogical(noPlot) && all(noPlot(:))
        return
    end

    fig = figure('Color', 'w');
    colormap(gray(256));

    % flip vertically, for display, so positive is up
    R = flipud(R);
    
    hSliceImg = imagesc(R);

    set(gca, 'YDir', 'normal');
    daspect([1 1 1]);

    set(hSliceImg, 'XData', [-self.imageXrange/2 self.imageXrange/2], 'YData', [-self.imageYrange/2 self.imageYrange/2]);
    axis tight;

    self.addMenu4DistanceMeasure(fig);
end