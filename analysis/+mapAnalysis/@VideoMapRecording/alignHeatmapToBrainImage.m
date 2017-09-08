function [figs,tf,warpedMaps,refs] = alignHeatmapToBrainImage(self,brainImage)
    if isnan(self.AlignmentInfo)
        error('MotorMapping:MotorMappingResult:NoAlignmentInformation','No alignment information provided.');
    end
        
    tf = self.AlignmentInfo.AlignmentTransform;
    grid = self.AlignmentInfo.GridCoordinates;
    rows = self.AlignmentInfo.Rows;
    cols = self.AlignmentInfo.Cols;
    
    map = self.TotalMovement.Array;
    
    pathname = self.Directory;
    [~,filename] = fileparts(pathname);
    save(sprintf('%s\\%s_heatmap_alignment_transform.mat',pathname,filename),'tf');
    
    if ischar(brainImage)
        brainImage = imread(brainImage);
    end
    
    brainImage = double(brainImage)/255;
    
    if size(brainImage,3) == 1
        brainImage = repmat(brainImage,1,1,3);
    end
    
    cmap = jet(256); % TODO : jet3
    cmap(1,:) = 0;
    
    figs = gobjects(size(map,3),1);
    
    warpedMaps = cell(size(map,3),1);
    refs = cell(size(map,3),1);

    for ii = 1:size(map,3)
        paddedMap = [zeros(1,cols+2); zeros(rows,1) map(:,:,ii) zeros(rows,1); zeros(1,cols+2)];
        [warpedMap,ref] = imwarp(paddedMap,imref2d(size(paddedMap),[-0.5 size(paddedMap,2)-0.5],[-0.5 size(paddedMap,1)-0.5]),tf,'nearest');
        warpedMaps{ii} = warpedMap;
        refs{ii} = ref;
        
        registeredMap = zeros(size(brainImage));
        registeredMap( ...
            round(ref.YWorldLimits(1)+1:ref.YWorldLimits(2)),   ...
            round(ref.XWorldLimits(1)+1:ref.XWorldLimits(2)),:) ...
            = interp1(0:255,cmap,min(255*warpedMap/max(warpedMap(:)),255));
        
        figs(ii) = figure;
        
        imagesc(brainImage+registeredMap/5); % TODO : transparency
        
        hold on;
        
        plot(grid(:,1),grid(:,2),'LineStyle','none','Marker','.','Color','m'); % TODO : control marker
    end
end