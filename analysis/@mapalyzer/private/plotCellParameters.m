function plotCellParameters(self)
% plotCellParameters
%
% Editing:
% gs april 2005
% -------------------------------------------------------
    
    if isempty(self.mapAvg.rseries)
        return
    end

    hfig = figure;
    set(hfig, 'Color', 'w', 'Position', [126   816   342   283]);

    RCaxis = 1:length(self.mapAvg.rseries);
    RCaxis = (RCaxis-1)*self.RsSkipVal+1;
    
    hold on;
    
    rsh = plot(RCaxis,self.mapAvg.rseries,'Color','b','LineStyle','-','Marker','o');
    rmh = plot(RCaxis,self.mapAvg.rmembrane,'Color','g','LineStyle','-','Marker','o');
    
    set(gca, 'XLim', [0 max(RCaxis)+1], 'YLim', [0 max(ylim)]);
    xlabel('Trace');
    ylabel('Resistance (M{\Omega})');
    legend([rsh rmh],{'Rs' 'Rm'});

    if self.numberOfMaps <= 1
        return
    end
    
    for ii = 1:self.numberOfMaps - 1
        line([ii*self.numTraces ii*self.numTraces],ylim,'Color','k');
    end
end