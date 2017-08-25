function mapStackHistoThresh = amplitudeHistogramAnalysis(self,recordings,mapStack)
    % ampHistoAnalysis
    %
    % Editing:
    % gs april 2005 -- private version for mapAnalysis2p0
    % -----------------------------------------------------------------

    % some initialization stuff
    synapticData = [recordings.AmplitudeHistogramSynapticData];
    mapStackHistoThresh = cat(3,synapticData.Array);
    
    baselineData = [recordings.AmplitudeHistogramBaselineData];
    mapStackHistoBase = cat(3,baselineData.Array);
    [r,c,p] = size(mapStackHistoBase);

    % INDIVIDUAL MAPS ***********************************************

    % obtain map of direct responses to exclude them from the histograms
    directMap = mapStack.mapAvgMeanED.Array;
    directMap(~isnan(directMap)) = 0; 
    directMap(isnan(directMap)) =  1;
    directMap(directMap==0) = NaN;

    % TODO : a lot of this feels common with array2Dplot - consolidate
    % histo params
    leftLim = -9;
    binWidth = .5;
    rightLim = 74;
    ampHistoEdges = [-inf  (leftLim:binWidth:rightLim)  inf];
    ampHistoEdges2 = ( leftLim-1 * binWidth : binWidth : rightLim + 1 * binWidth);

    indirectResponses = ~isnan(directMap);
    m = sum(indirectResponses(:));
    baselineData = zeros(p,m);
    baselineN = zeros(p,numel(ampHistoEdges));
    baselineSD = zeros(1,m);
    synapticData = zeros(p,m);
    synapticN = zeros(p,numel(ampHistoEdges));

    % for each baseline and synaptic map, obtain the histograms of the data
    for n = 1 : p

        % histo of the baseline window data
        b = mapStackHistoBase(:,:,n);
        baselineData(n, :) = b(indirectResponses); % exclude NaNs
        baselineN(n, :) = histc(baselineData(n, :), ampHistoEdges);

        % use the baseline noise level to generate a thresholded binary map of responses
        baselineSD(n) = std(baselineData(n, :));
        d = mapStackHistoThresh(:,:,n) > 2*baselineSD(n); % 0 = null, 1 = synaptic response
        mapStackHistoThresh(:,:,n) = d.*directMap;        % NaN = direct response

        % histo of the synaptic window data 
        s = mapStackHistoThresh(:,:,n);
        synapticData(n, :) = s(indirectResponses);
        synapticN(n, :) = histc(synapticData(n, :), ampHistoEdges);
    end

    % averaged individual histograms
    baselineNIndMean = mean(baselineN);
    synapticNIndMean = mean(synapticN);

    % AVERAGED MAPS ***********************************************
    % (already direct-corrected)
    baselineDataMean = mapStack.mapAvgHistoBase.Data';
    baselineNMean = histc(baselineDataMean, ampHistoEdges);

    synapticDataMean = mapStack.mapAvgHistoSyn.Data';
    synapticNMean = histc(synapticDataMean, ampHistoEdges);

    % summed map across individual binarized/thresholded maps of responses
    flagX = 0; % TODO : ????????
    if flagX
        s=sum(mapStackHistoThresh, 3);
        s(isnan(s))=-inf;
        figure;
        set(gcf, 'Color', 'w');
        colormap(jet2);
        imagesc(s);
        set(gca, 'CLim', [-.1 p]);
        colorbar;
        set(gca, 'PlotBoxAspectRatio', [1 1 1]);
        set(gca, 'Visible', 'off');
    end
    % PLOTTING ***********************************************
    % set up the figure
    x = 100; y = 30; w = 1500; h = 1000;
    hFigHist = figure('Position', [x y w h], 'Name', 'array2Dplot', ...
        'NumberTitle', 'off', 'Color', 'w', 'DoubleBuffer', 'on');
    subplotRows = p+2; subplotCols = 1;

    hsub = zeros(p+2,1);
    for n = 1:p
        % amplitude histograms, individual maps
        hsub(n) = subplot(subplotRows,subplotCols,n);
        h = bar(ampHistoEdges2, baselineN(n, :), 'histc');
        set(h, 'FaceColor', 'none', 'EdgeColor', 'k', 'LineWidth', 1);
        hold on;
        h = bar(ampHistoEdges2, synapticN(n, :), 'histc');
        set(h, 'FaceColor', 'none', 'EdgeColor', 'r', 'LineWidth', 1);
        ylabel('Observations');
        legend('Baseline window', 'Synaptic window');
        legend boxoff;
        title(['map ' num2str(n)]);
    end

    % amplitude histograms, mean histo of all individual histos
    n = n+1;
    hsub(n) = subplot(subplotRows,subplotCols,n);
    h = bar(ampHistoEdges2, baselineNIndMean, 'histc');
    % h = errorbar(ampHistoEdges2, baselineNIndMean, baselineNIndSEM);
    set(h, 'FaceColor', 'none', 'EdgeColor', 'k', 'LineWidth', 1);
    hold on;
    h = bar(ampHistoEdges2, synapticNIndMean, 'histc');
    % h = errorbar(ampHistoEdges2, synapticNIndMean, synapticNIndSEM);
    set(h, 'FaceColor', 'none', 'EdgeColor', 'r', 'LineWidth', 1);
    ylabel('Observations');
    legend('Baseline window', 'Synaptic window');
    legend boxoff;
    title('mean histo based on all individual histo data');

    % amplitude histograms, histo of mean map
    n = n+1;
    hsub(n) = subplot(subplotRows,subplotCols,n); %#ok<NASGU>
    h = bar(ampHistoEdges2, baselineNMean, 'histc');
    set(h, 'FaceColor', 'none', 'EdgeColor', 'k', 'LineWidth', 1);
    hold on;
    h = bar(ampHistoEdges2, synapticNMean, 'histc');
    set(h, 'FaceColor', 'none', 'EdgeColor', 'r', 'LineWidth', 1);
    xlabel('Amplitude (pA)');
    ylabel('Observations');
    legend('Baseline window', 'Synaptic window');
    legend boxoff;
    title('histo of mean data');

    if ~self.chkShowHistoAnalysis
        delete(hFigHist);
    else
    %     set(hFigHist, 'Visible', 'on');
    end
end