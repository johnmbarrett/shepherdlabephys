function plotTracesAsInputMap(self,recordings,mapNumber,isFlipped) % TODO : get rid of map number param
% arrayTracesAsInputMap
%
% Plots the set of map traces as a map.
%
% originally arrayTracesAsMap
%
% Editing:
% gs april 2005 -- privatize version for new analysis software 
% -----------------------------------------------------------------
    nMaps = numel(recordings);
    
    if nMaps < 1
        return
    end

    if nargin < 4
        isFlipped = false;
    end

    % TODO : this method can probably be done much more neatly using
    % Map.Array and Map.Pattern
    data = arrayfun(@(r) r.BaselineSubtracted.Data',recordings,'UniformOutput',false);
    data = cat(3,data{:});
    
    for ii = 1:nMaps
        mapPattern = recordings(ii).BaselineSubtracted.Pattern;
        data(:,:,ii) = data(:,mapPattern,ii);
    end

    showStart = round(self.traceMapShowStart*self.sampleRate);
    showStop = round(self.traceMapShowStop*self.sampleRate);

    [rows,cols] = size(data(:,:,1));
    totalTime = (rows-1)/self.sampleRate; 
    xTimeAxis = linspace(0, totalTime, rows)';

    [sizeX, sizeY] = size(mapPattern);

    yFactor = self.traceMapYFactor;
    
    if ~isempty(self.isCurrentClamp) && self.isCurrentClamp
        scaleBarText = 'mV';
    else
        scaleBarText = 'pA';
    end
    
    % TODO : the default seems to be upside down w.r.t traceBrowser.  must
    % investigate
    if isFlipped
        yFactor = -yFactor;
    end
    
    offsetVector = yFactor * ( 0 : cols-1 );
    offsetArray = repmat(offsetVector, rows, 1, nMaps);
    data = data-offsetArray;

    x = .14; 
    y = .11; 
    w = .5; 
    h = .8; 
    figure('Units', 'normalized', ...
        'Position', [x y w h], 'Name', 'arrayTracesAsMap', ...
        'NumberTitle', 'off', 'Color', 'w');
    
    titleStr = self.experimentName;
    
    if nargin >= 3
        titleStr = sprintf('%s, map%02d',titleStr,mapNumber);
    elseif nMaps > 1
        titleStr = [titleStr ', traces from all analyzed maps'];
    end
    
    axs = zeros(sizeY,1);
    colorOrder = ['k'; 'b'; 'g'; 'r'; 'c'; 'm'; 'y']; % TODO : I don't know why this isn't being read out of the .ini file properly

    for ii = 1:sizeY
        startInd = (ii-1)*sizeX + 1;
        endInd = ii*sizeX;

        pos1 = 0.025 + (ii - 1)*(0.96/sizeY);
        pos2 = 0.02;
        pos3 = 0.05;
        pos4 = 0.96;
        axs(ii) = axes('Position', [pos1 pos2 pos3 pos4]);

        hold on;
        
        for jj = 1:nMaps
            plot(xTimeAxis(showStart:showStop), data(showStart:showStop,startInd:endInd,jj),'Color',colorOrder(mod(jj-1,numel(colorOrder))+1));
        end

        minval = min(mean(data(1:100,startInd:endInd)));
        maxval = max(mean(data(1:100,startInd:endInd)));
        tweakFactor = abs(maxval - minval)*0.05;
        yrange = [minval-tweakFactor maxval+tweakFactor];
        set(gca, 'YLim', yrange);
        set(gca, 'XLim', [(showStart-200)/self.sampleRate (showStop+200)/self.sampleRate]);
        xlabel('Seconds');
    end
    
    set(axs, 'Visible', 'off');
    
    text('String', titleStr, 'Units', 'Normalized', 'Position', [0 1.005], ...
        'FontSize', 12, 'FontWeight', 'Bold', 'Parent', axs(1), ...
        'Tag', 'singleTraceMap', 'Interpreter', 'none');

    Y = mean(data(:,end))+yFactor/4;
    
    hscalebar = line([.1 .2], [Y Y]);
    set(hscalebar, 'Color', 'k', 'Tag', 'scaleBarLines');
    hscalebar = line([.1 .1], [Y Y+yFactor/2]);
    set(hscalebar, 'Color', 'k', 'Tag', 'scaleBarLines');

    % scalebar text
    ht(1) = text(.12, Y+yFactor/6, '100 ms'); 
    ht(2) = text(.12, Y+yFactor/3, [num2str(yFactor/2) ' ' scaleBarText]); 
    set(ht, 'Color', 'k', 'FontSize', 8, 'Tag', 'scaleBarText');
end