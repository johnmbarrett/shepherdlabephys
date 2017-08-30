function hs = plotSkew(self,bregmaCoordsPX)
    map = self.Map;
    
    [figs,~,warpedMaps,imrefs] = self.alignHeatmapToBrainImage(zeros(512,640)); % TODO : save warpedMaps & imrefs somewhere so we don't have to do this, also will the image size always be 640x512?
    
    close(figs);
    
    mmppxAlignment = 0.025; % TODO : push this into AlignmentInfo
    
    hs = zeros(1,size(map,2));
    
    for ii = 1:size(map,2)
        hs(ii) = figure;
        x = ((imrefs{ii}.YWorldLimits(1):(imrefs{ii}.YWorldLimits(2)-1))+0.5-bregmaCoordsPX(2))*mmppxAlignment;
        y = ((imrefs{ii}.XWorldLimits(1):(imrefs{ii}.XWorldLimits(2)-1))+0.5-bregmaCoordsPX(1))*mmppxAlignment;
        c = imrotate(warpedMaps{ii},90);
        a = c ~= 0;
        surf(x,y,zeros(size(c)),c,'AlphaData',a,'CDataMapping','scaled','EdgeColor','none','FaceAlpha','flat','FaceColor','flat');
    %     colormap(cmap);
        daspect([1 1 1]);
        set(gca,'YDir','reverse')
        view(2);
        xlabel('Lateral to Bregma (mm)');
        xlim(x([1 end]));
        ylabel('Posterior to Bregma (mm)');
        ylim(y([1 end]));

        % TODO : is the alignment image always aligned on the rostrocaudal
        % axis?  It's usually pretty close but not always perfect.
        line(x(1)+[9 7.5; 9 10.5]*diff(x([1 end]))/12,y(1)+[7.5 9; 10.5 9]*diff(y([1 end]))/12,'Color','k','LineWidth',4);
        patch(x(1)+[9 9 7.3 10.7; 8.8 8.8 8 10; 9.2 9.2 8 10]*diff(x([1 end]))/12,y(1)+[7.3 10.7 9 9; 8 10 8.8 8.8; 8 10 9.2 9.2]*diff(y([1 end]))/12,'k');

        text(x(1)+9*diff(x([1 end]))/12,y(1)+6.8*diff(y([1 end]))/12,'R','Color','k','FontSize',14,'FontWeight','bold','HorizontalAlignment','center','VerticalAlignment','middle');
        text(x(1)+9*diff(x([1 end]))/12,y(1)+11.2*diff(y([1 end]))/12,'C','Color','k','FontSize',14,'FontWeight','bold','HorizontalAlignment','center','VerticalAlignment','middle');
        text(x(1)+6.8*diff(x([1 end]))/12,y(1)+9*diff(y([1 end]))/12,'M','Color','k','FontSize',14,'FontWeight','bold','HorizontalAlignment','center','VerticalAlignment','middle');
        text(x(1)+11.2*diff(x([1 end]))/12,y(1)+9*diff(y([1 end]))/12,'L','Color','k','FontSize',14,'FontWeight','bold','HorizontalAlignment','center','VerticalAlignment','middle');
    end
end