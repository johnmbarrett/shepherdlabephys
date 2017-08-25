function plotCellParameters(self,recording,ax)
% plotCellParameters
%
% Editing:
% gs april 2005
% -------------------------------------------------------
    
    if isempty(self.mapAvg.rseries)
        return
    end
    
    % TODO : this function is a bit of a mess
    if nargin < 2 || isempty(recording)
        rseries = self.mapAvg.rseries;
        rmembrane = self.mapAvg.rmembrane;
    else
        rseries = recording.RSeries;
        rmembrane = recording.RMembrane;
    end

    if nargin < 3
        hfig = figure;
        set(hfig, 'Color', 'w', 'Position', [126   816   342   283]);
        ax = axes;
    end

    RCaxis = 1:length(rseries);
    RCaxis = (RCaxis-1)*self.RsSkipVal+1;
    
    hold on;
    
    rsh = plot(ax,RCaxis,rseries,'Color','b','LineStyle','-','Marker','o');
    rmh = plot(ax,RCaxis,rmembrane,'Color','g','LineStyle','-','Marker','o');
    
    set(ax, 'XLim', [0 max(RCaxis)+1], 'YLim', [0 max(ylim)]);
    xlabel(ax,'Trace');
    ylabel(ax,'Resistance (M{\Omega})');
    legend(ax,[rsh rmh],{'Rs' 'Rm'});

    if nargin > 1 || isempty(self.recordings)
        return
    end
    
    for ii = 1:numel(self.recordings)
        line(ax,[ii ii]*size(self.recordings(ii).Raw.Data,1),ylim,'Color','k');
    end
end