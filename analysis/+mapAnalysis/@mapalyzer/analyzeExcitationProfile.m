function analyzeExcitationProfile(self,recording)
% excitationProfileAnalysis     Analyze responses in terms of distance from soma
% Syntax:
%   excitationProfileAnalysis(maps, spacingXY, somaXYZ, figFlag)
% - maps: a map stack.
% - spacingXY is a 2-element vecor
% - somaXYZ is a 3-element vectors.
% - NB -- somaXYZ(3) is the focal plane relative to the soma plane
% - set figFlag to 1 for graphical display of map and gaussian fit
%
% Directly derived from responseDistance.m, with addition
% of stuff from analyzeArray
%
% Private version for mapAnalysis3p0
%
% See also responseDistance, analyzeArray

% note -- need to figure out how to analyze correctly for Z > 0
% correct way is probably
% - do the gaussian fit without factoring in Z
% - factor the Z in for the mean-distance calculation

% more notes -- 
% - could re-write distance arrays using meshgrid
% - need to revise distance arrays to accommodate non-zero soma positions

% gs Sept 2004 -- Private version for mapAnalysis3p0
% gs may 2006 -- modified for compatibility with ephus software
% GS20060530 - fixed error involving distance calculations (relating to EP stacks for 2P LSPS)
% ********************************************************************
    maps = recording.ActionPotentialNumber.Array;
    [R,C,P] = size(maps);

    % DISTANCES ----------------------------------------------------------

    % arrays and vectors of distances
    spacingXY = [self.mapSpacing self.mapSpacing];

    [colArray,rowArray] = ndgrid(...
        -((R-1)/2)*spacingXY(1):spacingXY(1):((R-1)/2)*spacingXY(1),    ...
        -((C-1)/2)*spacingXY(2):spacingXY(2):((C-1)/2)*spacingXY(2)     ...
        );


    distArray = sqrt(rowArray.^2 + colArray.^2);
    distances = distArray(:);
    distances2 = [-distances; distances];
    
    responses1 = zeros(R*C,P);
    responses2 = zeros(2*R*C,P); % o.o
    
    meanWeightedDistance = zeros(P,1);
    stdWeightedDistance = zeros(P,1);
    semWeightedDistance = zeros(P,1);
    
    meanDistance = zeros(P,1);
    semDistance = zeros(P,1);
    stdDistance = zeros(P,1);

    % RESPONSES ----------------------------------------------------------

    for ii = 1:P
        map = maps(:,:,ii);
        responses = reshape(map, R*C, []);

        % data format for later plotting and gaussian fit
        responses1(:,ii) = responses;
        responses2(:,ii) = [responses; responses];

        % distances of responses > 0
        I = find(responses > 0);

        % mean distance weighted by response number
        resps = responses(I);
        dists = distances(I);
        
        distVec = [];
        for jj = 1:length(I)
            distVec = [distVec; repmat(dists(jj), resps(jj), 1)]; %#ok<AGROW>
        end

        meanWeightedDistance(ii) = mean(distVec);
        stdWeightedDistance(ii) = std(distVec);
        semWeightedDistance(ii) = std(distVec) / sqrt(numel(distVec));

        % unweighted version
        meanDistance(ii) = mean(distances(I));
        stdDistance(ii) = std(distances(I));
        semDistance(ii) = std(distances(I)) / sqrt(numel(I));
    end


    % response distance analysis in terms of each unique distance

    % need to re-do this -- if one map, error bars are within-map SEM; if >1 map, bars are across-cell SEM

    [Xuniq,~,I] = unique(distances);
    N = numel(Xuniq);
    Aavg = zeros(N,1);
    Asem = zeros(N,1);
    
    for n = 1:N
        A = responses1(I == n, :);
        A = A(:);
        Aavg(n) = mean(A);
        Asem(n) = std(A)/sqrt(numel(A));
    end

    % average map
    mapAvg = recording.ActionPotentialNumber.derive(@(x) nanmean(x,2));

    if size(maps, 3) == 1 % for now, only if 1 EP sent to functionrecording.ActionPotentialNumber
        totalNumberOfSites = sum(maps(:) > 0);
        totalNumberOfSpikes = sum(maps(:));
        normNumber = totalNumberOfSpikes * (spacingXY(1)/1000) * (spacingXY(2)/1000);
        spikesPerSite = totalNumberOfSpikes / totalNumberOfSites;

        recording.TotalNumberOfSites = totalNumberOfSites;
        recording.TotalNumberOfSpikes = totalNumberOfSpikes;
        recording.SpikesPerSite = spikesPerSite;
        recording.NormTotalNumberOfSpikes = normNumber;
        recording.MeanWeightedDistanceFromSoma = meanWeightedDistance(1);
    end
    
    fig = figure;
    set(fig, 'Position', [65   695   560   420], 'DoubleBuffer', 'on', 'Color', 'w');
    plotrows = 2;
    plotcols = 2;
    plotnum = 0;
    colormap jet2;

    % plot the average map
    plotnum  = plotnum + 1;
    subplot(plotrows, plotcols, plotnum);
    
    plotMap(mapAvg,  ...
        'XData',    [min(colArray(:)) max(colArray(:))],    ...
        'YData',    [min(rowArray(:)) max(rowArray(:))],    ...
        'YLabel',   'Distance (um)'                         ...
        );
    hold on;
    plot([0 0], [0 0], 'wo');

    % plot distances vs responses
    plotnum  = plotnum + 1;
    subplot(plotrows, plotcols, plotnum);
    plot(distances, responses1, 'bo');
    hold on;
    herr = errorbar(Xuniq, Aavg, Asem, 'k-');
    set(herr, 'Marker', 's', 'MarkerFaceColor', 'none', 'LineWidth', 2);
    xlabel('Distance (um)');
    ylabel('Number of spikes');
    title('Single cell resolution');

    % plot folded data, gaussian fit
    plotnum  = plotnum + 1;
    hplt = subplot(plotrows, plotcols, plotnum);

    [~,c1] = size(responses2);
    responses2 = responses2(:);
    [~,c2] = size(distances2);
    distances2 = reshape(repmat(distances2, c1/c2, 1),[],1);

    hold on;

    hdata = line(distances2,responses2,'Parent',hplt,'Color',[0.333333 0 0.666667],...
         'LineStyle','none', 'LineWidth',1,...
         'Marker','o', 'MarkerSize',6);
    xlims = [min(distances2) max(distances2)];
    
    if xlims(1) == xlims(2)
        xlims = [0 1];
    else
        xlims = xlims + [-1 1] * 0.01 * diff(xlims);
    end
    
    options = fitoptions('method','NonlinearLeastSquares','Lower',[-Inf -Inf 0 ],'StartPoint',[5 35.35533905933 35.42453587741]);

    out = fit(distances2,responses2,fittype('gauss1'),options);

    hfit = plot(out,'fit',0.95);
    set(hfit(1),'Color',[1 0 0],...
         'LineStyle','-', 'LineWidth',2,...
         'Marker','none', 'MarkerSize',6);

    legend(hplt,[hdata hfit],{'responses2 vs. distances2' 'fit 1'});
    
    xlim(xlims);

    fitVals = get(hfit, 'YData');
    fitX = get(hfit, 'XData');
    peakVal = max(fitVals);
    minVal = min(fitVals);
    halfMax = (peakVal - minVal)/2;
    I = find(fitVals>halfMax);
    fullWidth = round(fitX(I(end)) - fitX(I(1)));

    recording.FWHM = fullWidth;
end