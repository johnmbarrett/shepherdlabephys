function ax = plotParams(ax,data,varargin)
%PLOTPARAMS Plot extracted parameters
%   PLOTPARAMS(DATA) produces a scatter plot of the data contained in DATA.
%   This function is intended for plotting scalar parameters calculated by
%   analysing ephys traces, for example the series resistance or response
%   latency on each trace.
%
%   AX = PLOTPARAMS(DATA) returns a handle, AX, to the resulting plot.
%
%   PLOTPARAMS(AX,...) plots the data into the axes handle AX instead of
%   creating a new figure.
%
%   PLOTPARAMS(...,PARAM1,VAL1,PARAM2,VAL2,...)  specifies one or more of 
%   the following name/value pairs:
%
%       'Abcissa'   Plots dashed vertical lines at the specified X-axis
%                   value(s).  Default is no lines.
%       'Ordinate'  Plots dashed horizontal lines at the specified Y-axis
%                   value(s).  Default is no lines.
%       'UnityLine' Plots dashed diagonal lines with the slope(s)
%                   specified.  Default is no lines.
%       'Title'     Gives the plot the specified title.  Default is no
%                   title.
%       'XLabel'    Gives the plot the specified X-axis label.  Default is
%                   no label.
%       'YLabel'    Gives the plot the specified X-axis label.  Default is
%                   no label.
%       'XLim'      Two-element monotonically increasing vector specifying
%                   the X-axis limits.  Default is to MATLAB to determine
%                   the limits automatically.
%       'YLim'      Two-element monotonically increasing vector specifying
%                   the X-axis limits.  Default is to MATLAB to determine
%                   the limits automatically.

%   Written by John Barrett 2017-07-28 17:35 CDT
%   Last updated John Barrett 2017-08-15 18:17 CDT
    if isnumeric(ax) && ~isscalar(ax) % TODO : this isn't exactly right but close enough unless you want to plot a single datapoint without specifying a handle
        if nargin > 1
            varargin = [{data} varargin];
        end
        
        data = ax;
        
        figure;
        ax = axes;
    end

    parser = inputParser;
    isRealFiniteVector = @(x) validateattributes(x,{'numeric'},{'real' 'finite' 'vector'});
    addParameter(parser,'Abcissa',NaN,isRealFiniteVector);
    addParameter(parser,'Ordinate',NaN,isRealFiniteVector);
    addParameter(parser,'UnityLine',NaN,isRealFiniteVector);
    addParameter(parser,'Title','',@ischar);
    addParameter(parser,'XLabel','',@ischar);
    addParameter(parser,'YLabel','',@ischar);
    isLims = @(x) isnumeric(x) && isvector(x) && all(isreal(x) & isfinite(x)) && isequal(size(x),[1 2]) && x(1) < x(2);
    addParameter(parser,'XLim',NaN,isLims);
    addParameter(parser,'YLim',NaN,isLims);
    parser.parse(varargin{:});
    
    hold(ax,'on');
    
    title(parser.Results.Title,'Parent',ax);
    xlabel(ax,parser.Results.XLabel);
    ylabel(ax,parser.Results.YLabel);
	
    if ~isnan(parser.Results.XLim(1))
        xlim(ax,parser.Results.XLim);
    end
	
    if ~isnan(parser.Results.YLim(1))
        ylim(ax,parser.Results.YLim);
    end
    
    plot(1:length(data),data,'Color','r','LineStyle','-','Marker','o');
    
    xx = xlim;
    yy = ylim;
    
    plot((parser.Results.Abcissa(:)*[1 1])',repmat(yy',1,numel(parser.Results.Abcissa)),'Color','k','LineStyle','-.');
    plot(repmat(xx',1,numel(parser.Results.Ordinate)),(parser.Results.Ordinate(:)*[1 1])','Color','k','LineStyle','-.');
    
    if isnan(parser.Results.UnityLine(1))
        hold(ax,'off');
        
        return
    end
    
    for ii = 1:numel(parser.Results.UnityLine)
        slope = parser.Results.UnityLine(ii);
        
        x1 = yy(1)/slope;
        
        if x1 < xx(1)
            x1 = xx(1);
            y1 = slope*x1;
        else
            y1 = yy(1);
        end
        
        x2 = yy(2)/slope;
        
        if x2 > xx(2)
            x2 = xx(2);
            y2 = slope*x2;
        else
            y2 = yy(2);
        end
        
        plot([x1;x2],[y1;y2],'Color','k','LineStyle','-.');
    end
    
    hold(ax,'off');
end