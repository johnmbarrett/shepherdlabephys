function histoN = array2Dplot(self,recording,mapNumber) % TODO : get rid of map number
    % array2Dplot
    %
    % private version for mapAnalysis2p0
    %
    % Editing:
    % gs april 2005
    % ------------------------------------------------------

    % TODO: fix text display of map name

    % initialize some variables
    data = recording.BaselineSubtracted.Data';
    [rows,cols] = size(data);
    totalTime = (rows-1)/self.sampleRate;
    xTimeAxis = linspace(0, totalTime, rows)'; 

    % set up the figure
    x = .17; y = .08; w = .7; h = .7; 
    figure('Units', 'normalized', 'Position', [x y w h], 'Name', 'array2Dplot', ...
        'NumberTitle', 'off', 'Color', 'w', 'DoubleBuffer', 'on');
    subplotRows = 5; subplotCols = 4; plotnum = 0;

    % polarity stuff -- gs 2006 12 02
    if strcmp(self.eventPolaritySyn, 'down')
        plotPolarityFactor = 1;
    elseif strcmp(self.eventPolaritySyn, 'up')
        plotPolarityFactor = -1;
    end

    % Laser intensity
    plotnum = plotnum+1;
    
    hsub(plotnum) = subplot(subplotRows,subplotCols,plotnum);
    plot(recording.LaserIntensity, 'c-');
    set(gca, 'YLim', [0 max(get(gca, 'YLim'))], 'XLim', [0 numel(recording.LaserIntensity)+1]);
    xlabel('Trace');
    ylabel('mW');
    legend('laser');

    % Rs, Rm
    plotnum = plotnum+1;
    hsub(plotnum) = subplot(subplotRows,subplotCols,plotnum);

    if self.chkWithRsRm
        self.plotCellParameters(recording,hsub(plotnum));
    else
        set(hsub(plotnum), 'Visible', 'off');
    end

    plotnum = plotnum+1;

    % image of slice (in mapping position)
    plotnum = plotnum+1;
    hsub(plotnum) = subplot(subplotRows,subplotCols,plotnum);
    sliceImage = imagesc(self.image.img);
    daspect([1 1 1]);
    title(self.image.imgName,'Interpreter','none');
    xrange = self.imageXrange;
    yrange = self.imageYrange;
    set(sliceImage, ...
        'XData', [-xrange/2 xrange/2], 'YData', [-yrange/2 yrange/2]);
    axis tight;

    plotnum = plotnum+1;

    % AMPLITUDE histogram *****************************

    % obtain map of direct responses to exclude them from the histograms
    directMap = recording.DirectResponseAmplitude.Array;
    directMap(directMap~=0) = NaN;
    directMap(directMap==0) = 1; % ends up with NaNs at direct sites, 1's everywhere else

    % histo params
    leftLim = -9;
    binWidth = .5;
    rightLim = 74;
    histoEdges = [-inf  (leftLim:binWidth:rightLim)  inf];
    histoEdges2 = leftLim-1*binWidth:binWidth:rightLim+1*binWidth;

    % for each baseline and synaptic map, obtain the histograms of the data
    % histo of the baseline window data
    b = recording.AmplitudeHistogramBaselineData.Array;
    b = b.*directMap; % convert directs to NaNs
    
    baselineData = b(~isnan(b)); % exclude NaNs
    baselineN = histc(baselineData(:), histoEdges);
    %
    % use the baseline noise level to generate a thresholded binary map of responses
    baselineSD = std(baselineData(:));
    d = recording.AmplitudeHistogramSynapticData.Array > 2 * baselineSD; % 0 = null, 1 = synaptic response
    d = d.*directMap;           % NaN = direct response
    d(isnan(d))=-inf;           % NaN => inf for plotting
    d = -d;

    % histo of the synaptic window data 
    s = recording.AmplitudeHistogramSynapticData.Array;
    s = s.*directMap;
    
    synapticData = s(~isnan(s));
    synapticN = histc(synapticData(:), histoEdges);

    plotnum = plotnum+1;
    hsub(plotnum) = subplot(subplotRows,subplotCols,plotnum);
    h = bar(histoEdges2, baselineN, 'histc');
    set(h, 'FaceColor', 'k', 'LineStyle', 'none');
    hold on;
    h = bar(histoEdges2, synapticN, 'histc');
    set(h, 'FaceColor', 'none', 'EdgeColor', 'r', 'LineWidth', 1);
    set(gca, 'XLim', [-15 80]);
    xlabel('Amplitude (pA)');
    ylabel('N');
    legend('baseline', 'synaptic');

    % binarized/thresholded map (from amplitude histogram, 2SDs)
    plotnum = plotnum+1;
    hsub(plotnum) = subplot(subplotRows,subplotCols,plotnum);
    imagesc(d);
    set(gca, 'CLim', [-1 0.03], 'PlotBoxAspectRatio', [1 1 1], 'Visible', 'off');

    plotnum = plotnum+1;
    hsub(plotnum) = subplot(subplotRows,subplotCols,plotnum);

    % data for histogram -- from "All, Onset" array -- i.e., from genOnset map below
    if strcmp(self.eventPolaritySyn, 'down')
        %     if ~handles.data.analysis.responsesInvertedFlag
        genMap = recording.MinimumResponseLatency.Data';
    else
        genMap = recording.MaximumResponseLatency.Data';
    end
    genMap(genMap==0) = inf;
    result = genMap;
    result(result==0) = inf;

    leftLim = 0;
    binWidth = .001;
    rightLim = self.synapticWindow;
    histoEdges = leftLim : binWidth : rightLim;

    b = result;
    b(b == inf) = NaN;
    histoData = b(~isnan(b));
    histoN = histc(histoData, histoEdges);

    h = bar(histoEdges, histoN, 'histc');
    set(h, 'FaceColor', 'r', 'LineStyle', 'none');
    set(gca, 'XLim', [leftLim rightLim]);
    xlabel('Onset latency (sec)');
    ylabel('Number');
    edEnd = self.directWindow;
    line([edEnd edEnd], [min(get(gca,'YLim')) max(get(gca,'YLim'))], ...
        'Color', 'b', 'LineStyle', ':'); 

    [sizeX,sizeY] = size(recording.Raw.Pattern);
    magFacX = (self.mapSpacing * (sizeX-1))/2;
    magFacY = (self.mapSpacing * (sizeY-1))/2;
    
    indices = {1:length(xTimeAxis) 900:2100 900:2100};
    masks = {true(1,cols) ~recording.DirectResponseOccurence.Data recording.DirectResponseOccurence.Data};
    fields = cell(1,3);
    
    if strcmp(self.eventPolaritySyn, 'down')
        fields{1} = 'MinimumResponseAmplitude';
        fields{3} = 'MinimumResponseLatency';
    else
        fields{1} = 'MaximumResponseAmplitude';
        fields{3} = 'MaximumResponseLatency';
    end
    
    fields{2} = 'MeanResponseAmplitude';
    
    titles = {'Peak' 'Mean' 'Onset'};
    cbarTexts = {'pA' 'pA' 's'};
    
    for jj = 1:3
        plotnum = plotnum+1;
        hsub(plotnum) = subplot(subplotRows,subplotCols,plotnum);
        plotTraces(hsub(plotnum),xTimeAxis(indices{jj}),data(indices{jj},masks{jj}),self.sampleRate,'StimStart',[self.stimOn self.directWindow self.synapticWindow]);
        set(gca, 'XLim', [0 max(xTimeAxis)]);
        xlabel('Seconds');
        ylabel('Amplitude');
        
        for ii = 1:numel(fields)
            plotnum = plotnum+1;
            hsub(plotnum) = subplot(subplotRows,subplotCols,plotnum);

            result = recording.(fields{ii}).Array;
            
            mask = recording.DirectResponseAmplitude.Array;

            switch jj
                case 1 % do nothing
                case 2
                    result = result.*(mask == 0);
                case 3
                    result = result.*(mask ~= 0);
            end

            result(result==0) = plotPolarityFactor * inf;

            plotMap(hsub(plotnum), result,              ...
                'ColorBarText', cbarTexts{ii},          ...
                'Title',        titles{ii},             ...
                'XData',        [-magFacX magFacX],     ...
                'YData',        [-magFacY magFacY],     ...
                'XYLabel',      'micrometers'           ...
                );
        end
    end
    
    if strcmp(self.eventPolaritySyn, 'down')
        colormap(flipud(colormap(jet2)));
    else
        colormap(jet2);
    end

    titleStr = sprintf('%s, map%02d',self.experimentName,mapNumber);

    text('String', titleStr, 'Units', 'Normalized', 'Position', [0 1.2], ...
        'FontWeight', 'Bold', 'Parent', hsub(1), 'Interpreter', 'none');

    text('String', 'All', 'Units', 'Normalized', 'Position', [-.5 0.3], ...
        'FontWeight', 'Bold', 'Parent', hsub(9), 'Rotation', 90);

    text('String', 'Non-Direct', 'Units', 'Normalized', 'Position', [-.5 0.35], ...
        'FontWeight', 'Bold', 'Parent', hsub(13), 'Rotation', 90);

    if length(hsub) > 16
        text('String', 'Direct', 'Units', 'Normalized', 'Position', [-.5 0.4], ...
            'FontWeight', 'Bold', 'Parent', hsub(17), 'Rotation', 90);
    end
end