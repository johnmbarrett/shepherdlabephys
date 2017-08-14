function ax = plotTraces(ax,data,sampleRate,varargin)
    if ~ishandle(ax);
        if nargin > 2
            varargin = [{sampleRate} varargin];
        end
        
        sampleRate = data;
        data = ax;
        
        figure;
        ax = axes;
    end
    
    parser = inputParser;
    % TODO : Peaks and PeakIndices could really be any points of interest,
    % and maybe StimStart can just be abcissa?  can we factor out common
    % code between this and plotParams
    addParameter(parser,'Peaks',NaN,@(x) validateattributes(x,{'numeric'},{'real finite vector'}));
    addParameter(parser,'PeakIndices',NaN,@(x) validateattributes(x,{'numeric'},{'real finite positive integer vector'}));
    addParameter(parser,'StimStart',NaN,@(x) validateattributes(x,{'numeric'},{'real finite scalar'}));
    addParameter(parser,'RecordingMode','VC',@(x) ismember(x,{'VC' 'IC'}));
    addParameter(parser,'Title','',@ischar);
    parser.parse(varargin{:});
    
    hold(ax,'on');
    
    title(parser.Results.Title,'Parent',ax);
    
    xlabel(ax,'time (s)');
    
    switch parser.Results.RecordingMode
        case 'VC'
            ylabel('pA');
        case 'IC'
            ylabel('mV');
        otherwise
            disp('Check the recordMode field');
    end
    
    time = (1:size(data,1))/sampleRate;
    
    plot(ax,time,data);
    
    plot(ax,(parser.Results.StimStart(:)*[1 1])',repmat(ylim',1,numel(parser.Results.StimStart)),'Color','k','LineStyle','-.'); % TODO : override these plot options?
    
    if all(isnan(parser.Results.Peaks(:)))
        hold(ax,'off');
        return
    end
    
    if all(isnan(parser.Results.PeakIndices(:)))
        error('ShepherdLab:plotTraces:MissingPeakIndices','You must provide PeakIndices when passing Peaks to plotTraces.');
    end
    
    peaks = parser.Results.Peaks;
    peakIndices = parser.Results.PeakIndices;
    
    assert(numel(peaks) == numel(peakIndices),'ShepherdLab:plotTraces:PeaksPeakIndicesMismatch','The must be one PeakIndex for every peak');
    
    plot(peakIndices(:)/sampleRate,peaks(:),'Color','k','LineStyle','none','Marker','o','MarkerSize',10);
    
    hold(ax,'off');
end