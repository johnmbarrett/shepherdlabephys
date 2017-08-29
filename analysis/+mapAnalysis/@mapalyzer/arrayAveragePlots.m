function arrayAveragePlots(self,mapStack)
    % arrayAvgPlots
    %
    %Editing:
    % gs april 2005 privatized for mapAnalysis2p0
    % -------------------------------------------------------------------
    % TODO : work out what's common between this and array2Dplot and
    % consolidate

    % set up the figure
    x = .2; y = .05; w = .7; h = .7; 
    figure('Units', 'normalized', 'Position', [x y w h], 'Name', 'arrayAvgPlots', ...
        'NumberTitle', 'off', 'Color', 'w');
    subplotRows = 4+self.fourthWindowMaps; subplotCols = 3; plotnum = 0;

    % map images - general settings
    [sizeX,sizeY] = size(self.recordingActive.Raw.Array);
    magFacX = (self.mapSpacing * (sizeX-1))/2;
    magFacY = (self.mapSpacing * (sizeY-1))/2;

    % polarity stuff -- gs 2006 12 02
    if strcmp(self.eventPolaritySyn, 'down')
        plotPolarityFactor = 1;
    elseif strcmp(self.eventPolaritySyn, 'up')
        plotPolarityFactor = -1;
    end

    % SYNAPTIC WINDOW PLOTS *****************************************
    % genMin (or genMax) map
    maps = cell(1,7+3*self.fourthWindowMaps);
    
    if strcmp(self.eventPolaritySyn, 'down')
        maps{1} = mapStack.mapAvgMin.Array;
        maps{3} = mapStack.mapAvgOnset.Array;
    else
        maps{1} = mapStack.mapAvgMax.Array;
        maps{3} = mapStack.mapAvgMaxOnset.Array;
    end
    
    maps{2} = mapStack.mapAvgMean.Array;
    maps{4} = mapStack.mapAvgMinED.Array;
    maps{5} = mapStack.mapAvgMeanED.Array;
    maps{6} = mapStack.mapAvgOnsetED.Array;
    
    if self.fourthWindowMaps
        maps{7} = mapStack.mapAvgMean4th.Array;
        maps{8} = mapStack.mapAvgMin4th.Array;
        maps{9} = mapStack.mapAvgMax4th.Array;
    end
    
    [~,~,p] = size(mapStack.mapStackHistoThresh);
    s=-sum(mapStack.mapStackHistoThresh, 3);
    s(isnan(s))=inf;
    
    maps{end} = s;
    
    % TODO : store these in the maps themselves?
    titles = repmat({'Peak' 'Mean' 'Onset'},1,2+self.fourthWindowMaps);
    cbarTexts = repmat({'pA' 'pA' 's'},1,2+self.fourthWindowMaps); % TODO : units
    titles{7+3*self.fourthWindowMaps} = 'Events per site';
    cbarTexts{7+3*self.fourthWindowMaps} = '#';
    
    hsub = gobjects(7+3*self.fourthWindowMaps,1);
    
    for ii = 1:numel(maps)
        plotnum = plotnum+1;
        hsub(plotnum) = subplot(subplotRows,subplotCols,plotnum);

        map = maps{ii};
        map(isnan(map)) = plotPolarityFactor * inf;
        
        if ii == numel(maps)
            extraArgs = {'CLim' [-p .1]};
        else
            extraArgs = {};
        end
        
        plotMap(hsub(plotnum), map, 'ColorBarText', cbarTexts{ii}, 'Title', titles{ii}, 'XData', [-magFacX magFacX], 'YData', [-magFacY magFacY], extraArgs{:});
    end

    % ONSET LATENCY HISTOGRAM

    % data for histogram -- sum of individual maps' data
    sumData = sum(mapStack.mapStackLatHistoN, 2);

    % histo params
    leftLim = 0;
    binWidth = .001;
    rightLim = self.synapticWindow;
    histoEdges = (leftLim : binWidth : rightLim);

    plotnum = plotnum+1;
    hsub(plotnum) = subplot(subplotRows,subplotCols,plotnum);
    h = bar(histoEdges, sumData, 'histc');
    set(h, 'FaceColor', 'r', 'LineStyle', 'none');
    set(gca, 'XLim', [leftLim rightLim]);
    xlabel('Onset latency (sec)');
    ylabel('Number');
    edEnd = self.directWindow;
    line([edEnd edEnd], [min(get(gca,'YLim')) max(get(gca,'YLim'))], ...
        'Color', 'b', 'LineStyle', ':');

    if strcmp(self.eventPolaritySyn, 'down')
        colormap(flipud(colormap(jet2)));
    else
        colormap(jet2);
    end

    plotnum = plotnum+1;
    hsub(plotnum) = subplot(subplotRows,subplotCols,plotnum);

    hSliceImg = imagesc(self.image.img);
    daspect([1 1 1]);

    set(hsub(plotnum), 'ButtonDownFcn', @(varargin) imagesc(hsub(plotnum),self.chooseImageFile(true))); % TODO : this doesn't change the title.  should make a utility function or something.
    title(self.image.imgName);

    % TODO : this is at least the third place this code exists
    if isempty(self.imageXrange)
        warning('ShepherdLab:mapAnalysis:mapalyzer:arrayAveragePlots:MissingXRange','Using defaults for xrange that may be invalid. Check.');
        xrange = 1900; % default param's from Ingrid's rig
    else
        xrange = self.imageXrange;
    end
    
    if isempty(self.imageYrange)
        warning('ShepherdLab:mapAnalysis:mapalyzer:arrayAveragePlots:MissingYRange','Using defaults for yrange that may be invalid. Check.');
        yrange = 1520;
    else
        yrange = self.imageYrange;
    end
    
    set(hSliceImg, 'XData', [-xrange/2 xrange/2], 'YData', [-yrange/2 yrange/2]);
    axis tight;

    if self.chkWithRsRm
        plotnum = plotnum+1;
        hsub(plotnum) = subplot(subplotRows,subplotCols,plotnum);
        self.plotCellParameters([], hsub(plotnum));
    end

    titleStr = [self.experimentName ', average maps'];

    text('String', titleStr, 'Units', 'Normalized', 'Position', [0 1.2], ...
        'FontWeight', 'Bold', 'Parent', hsub(1), 'Interpreter', 'none');

    text('String', 'Synaptic', 'Units', 'Normalized', 'Position', [-.5 0.3], ...
        'FontWeight', 'Bold', 'Parent', hsub(1), 'Rotation', 90);

    text('String', 'Direct', 'Units', 'Normalized', 'Position', [-.5 0.35], ...
        'FontWeight', 'Bold', 'Parent', hsub(4), 'Rotation', 90);

    if self.fourthWindowMaps
        text('String', '4th Window', 'Units', 'Normalized', 'Position', [-.5 0.35], ...
            'FontWeight', 'Bold', 'Parent', hsub(7), 'Rotation', 90);
    end
end