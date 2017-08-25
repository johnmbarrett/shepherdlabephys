function [ax,mapHandle] = plotMap(ax,map,varargin)
    if ~ishandle(ax)
        if nargin > 1
            varargin = [{map} varargin];
        end
        
        map = ax;
        
        ax = gca;
    end
    
    if isnumeric(map)
        data = map;
    elseif isa(map,'mapAnalysis.Map')
        data = map.Array;
    else
        error('ShepherdLab:plotMap:InvalidData','Map must be a numeric matrix or a mapAnalysis.Map');
    end
    
    assert(isnumeric(data) && ismatrix(data),'Map must be a numeric matrix or a mapAnalysis.Map');
    
    parser = inputParser;
    isValidXYData = @(x) isnumeric(x) && ismember(numel(x),[1 2]);
    addParameter(parser,'CLim',NaN,@(x) isnumeric(x) && numel(x) == 2 && x(1) < x(2));
    addParameter(parser,'ColorBarTextPosition',[1.13 -0.08],@(x) isnumeric(x) && numel(x) == 2);
    addParameter(parser,'TitlePosition',[0 1.05],@(x) isnumeric(x) && numel(x) == 2);
    addParameter(parser,'XData',[1 size(data,2)],isValidXYData);
    addParameter(parser,'YData',[1 size(data,2)],isValidXYData);
    addParameter(parser,'XLabel','',@ischar)
    addParameter(parser,'YLabel','',@ischar)
    addParameter(parser,'XYLabel',NaN,@ischar);
    parser.parse(varargin{:});
    
    mapHandle = imagesc(ax, data);
    set(mapHandle, 'XData', parser.Results.XData, 'YData', parser.Results.YData);
    axis(ax,'tight');
    
    if any(isnan(parser.Results.CLim))
        lowerLim = min(min(data(data>-inf)));
        upperLim = max(max(data(data<inf)));
        upperLimTweaked = upperLim + 0.02*(abs(upperLim-lowerLim));
        clim = [lowerLim upperLimTweaked];
    else
        clim = parser.Results.CLim;
    end
    
    set(ax, 'CLim', clim, 'PlotBoxAspectRatio', [1 1 1]);
    
    if ischar(parser.Results.XYLabel)
        xlabel(parser.Results.XYLabel);
        ylabel(parser.Results.XYLabel);
    else
        xlabel(parser.Results.XLabel);
        ylabel(parser.Results.YLabel);
    end
    
    text(parser.Results.TitlePosition(1), parser.Results.TitlePosition(2),'Peak', ...
        'Units', 'Normalized', 'FontWeight', 'Bold', 'Parent', ax);
    
    colorbar('vert');
    text(parser.Results.ColorBarTextPosition(1), parser.Results.ColorBarTextPosition(2),'pA', 'Units', 'Normalized', 'Parent', ax);
end