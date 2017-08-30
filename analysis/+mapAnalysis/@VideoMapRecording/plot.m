function hs = plot(self,useRealCoords,bregmaCoordsPX) % TODO : this method is kind of unwieldly, can we split it up a bit?  Also I like the idea of plot(mmr) giving you the basic map, but what about all the other kinds of plots?  Should they be accessible through plot(mmr,...,<some options>), or just through their own dedicated methods?  Also, should we separate the view from the data?  Probably.
    % TODO : name-value pairs, validation
    if nargin < 3
        bregmaCoordsPX = [NaN NaN];
    end
    
    if nargin < 2
        useRealCoords = false;
    end

    bodyParts = self.BodyParts;
    map = self.Map;
    
    if numel(bodyParts) ~= size(map,2)
        switch size(map,2)
            case 2
                bodyParts = {'right_forepaw' 'left_forepaw'};
            case 3
                bodyParts = {'right_forepaw' 'left_forepaw' 'hindpaw'};
            otherwise
                error('MotorMapping:MotorMappingResult:InvalidBodyParts','You must set BodyParts before plotting a MotorMappingResult.');
        end
    end

    assert(isa(self.AlignmentInfo,'mm.LaserAlignment'),'MotorMapping:MotorMappingResult:MissingAlignmentInfo','You must set AlignmentInfo before plotting a MotorMappingResult.');

    layout = [self.AlignmentInfo.Rows self.AlignmentInfo.Cols];
    
    isRowsEven = mod(layout,1) == 0;
    xtick = ((1-0.5*isRowsEven):(1+(layout(1) > 9)):(layout(1)+isRowsEven))';

    isColsEven = mod(layout,2) == 0;
    ytick = ((1-0.5*isColsEven):(1+(layout(2) > 9)):(layout(2)+isColsEven))';

    assert(prod(layout) == size(map,1),'Map dimensions must match number of stimulation sites');
    
    mmppxTracking = 0.067;

    if useRealCoords
        % TODO : push this into AlignmentInfo
        mmppxAlignment = 0.025;

        beta = self.AlignmentInfo.GridParameters;

        % TODO : this makes assumptions about the order of points in the laser
        % grid that may not always hold in future.  Push this into
        % AlignmentInfo also.
        xtickMarksBottom = mmppxAlignment*([ones(size(xtick)) xtick(1)*ones(size(xtick)) flipud(xtick)]*beta(:,2)-bregmaCoordsPX(2));
        ytickMarksBottom = mmppxAlignment*([ones(size(ytick)) flipud(ytick) ytick(end)*ones(size(ytick))]*beta(:,1)-bregmaCoordsPX(1));

        xtickMarksTop = mmppxAlignment*([ones(size(xtick)) xtick(end)*ones(size(xtick)) flipud(xtick)]*beta(:,2)-bregmaCoordsPX(2));
        ytickMarksTop = mmppxAlignment*([ones(size(ytick)) ytick ytick(1)*ones(size(ytick))]*beta(:,1)-bregmaCoordsPX(1));

        xscale = median([median(abs(diff(xtickMarksBottom))) median(abs(diff(xtickMarksTop)))]);
        yscale = median([median(abs(diff(ytickMarksBottom))) median(abs(diff(ytickMarksTop)))]);

        %%

        alignmentTransform = self.AlignmentInfo.AlignmentTransform;
        [lineCenterXr,lineCenterYr] = transformPointsForward(alignmentTransform,10*layout(1)/12,2*layout(2)/12); % TODO : check indices are the right way round

        horizontalLineXr = lineCenterXr*[1 1];
        horizontalLineYr = lineCenterYr+[-1 1]*beta(2,1); % horizonal line is vertical in imaging space

        horizontalLineLength = abs(diff(horizontalLineYr));

        verticalLineXr = lineCenterXr+[-1 1]*beta(3,2)*yscale/xscale; % and vice-versa
        verticalLineYr = lineCenterYr*[1 1];

        verticalLineLength = abs(diff(verticalLineXr));

        horizontalArrowheadsXr = repmat(lineCenterXr+[0;-0.1;0.1]*horizontalLineLength/2,1,2);
        horizontalArrowheadsYr = [1.1;0.8;0.8]*(horizontalLineYr-lineCenterYr)+lineCenterYr;

        verticalArrowheadsXr = [1.1;0.8;0.8]*(verticalLineXr-lineCenterXr)+lineCenterXr;
        verticalArrowheadsYr = repmat(lineCenterYr+[0;-0.1;0.1]*verticalLineLength/2,1,2);

        rightXr = horizontalLineXr(1);
        rightYr = lineCenterYr + 0.7*verticalLineLength;

        leftXr = horizontalLineXr(1);
        leftYr = lineCenterYr - 0.7*verticalLineLength;

        caudalXr = lineCenterXr - 0.7*horizontalLineLength;
        caudalYr = verticalLineYr(1);

        rostralXr = lineCenterXr + 0.7*horizontalLineLength;
        rostralYr = verticalLineYr(1);

        [horizontalLineXm,horizontalLineYm] = transformPointsInverse(alignmentTransform,horizontalLineXr,horizontalLineYr);
        [verticalLineXm,verticalLineYm] = transformPointsInverse(alignmentTransform,verticalLineXr,verticalLineYr);
        [horizontalArrowheadsXm,horizontalArrowheadsYm] = transformPointsInverse(alignmentTransform,horizontalArrowheadsXr,horizontalArrowheadsYr);
        [verticalArrowheadsXm,verticalArrowheadsYm] = transformPointsInverse(alignmentTransform,verticalArrowheadsXr,verticalArrowheadsYr);
        [rostralXm,rostralYm] = transformPointsInverse(alignmentTransform,rostralXr,rostralYr);
        [caudalXm,caudalYm] = transformPointsInverse(alignmentTransform,caudalXr,caudalYr);
        [leftXm,leftYm] = transformPointsInverse(alignmentTransform,leftXr,leftYr);
        [rightXm,rightYm] = transformPointsInverse(alignmentTransform,rightXr,rightYr);

        if all(xtick([1 end]) <= 0)
            leftText = 'L';
            rightText = 'M';
        elseif all(xtick([1 end]) >= 0)
            leftText = 'M';
            rightText = 'L';
        else
            leftText = 'S';
            rightText = 'D';
        end
    end
    
    hs = gobjects(size(map,2),1);
    
    [~,finalFolder] = fileparts(pwd);

    for ii = 1:size(map,2)
        hs(ii) = figure;
        ax1 = axes;
        cax = [min(map(:)) max(map(:))]*mmppxTracking;

        imagesc(flipud(reshape(map(:,ii)*mmppxTracking,layout)));

        if ~useRealCoords
            % TODO : more control over saving
            saveas(gcf,[finalFolder '_' bodyParts{ii} '_motor_tracking_map'],'fig');
            continue
        end

        set(ax1,'XTick',xtick,'XTickLabel',arrayfun(@(f) sprintf('%1.2f',f),xtickMarksBottom,'UniformOutput',false));
        set(ax1,'YTick',ytick,'YTickLabel',arrayfun(@(f) sprintf('%1.2f',f),ytickMarksBottom,'UniformOutput',false));

        ax2 = axes('Color','none','XLim',get(gca,'XLim'),'YLim',get(gca,'YLim'),'XAxisLocation','top','YAxisLocation','right');

        set(ax2,'XTick',xtick,'XTickLabel',arrayfun(@(f) sprintf('%1.2f',f),xtickMarksTop,'UniformOutput',false));
        set(ax2,'YTick',ytick,'YTickLabel',arrayfun(@(f) sprintf('%1.2f',f),ytickMarksTop,'UniformOutput',false));

        caxis(ax1,cax);
        c = colorbar(ax1);
        c.Label.String = 'Total movement (mm)';

        set(ax2,'Position',get(ax1,'Position'));

        xlabel(ax1,'Lateral to Bregma (mm)');
        ylabel(ax1,'Anterior to Bregma (mm)');

        line(ax1,verticalLineXm,layout(2)-verticalLineYm,'Color','w','LineWidth',2);
        line(ax1,horizontalLineXm,layout(2)-horizontalLineYm,'Color','w','LineWidth',2);
        patch(ax1,verticalArrowheadsXm,layout(2)-verticalArrowheadsYm,'w','EdgeColor','none');
        patch(ax1,horizontalArrowheadsXm,layout(2)-horizontalArrowheadsYm,'w','EdgeColor','none');
        text(ax1,rostralXm,layout(2)-rostralYm,'R','Color','w','FontSize', 12,'FontWeight','bold','HorizontalAlignment','center','VerticalAlignment','middle');
        text(ax1,caudalXm,layout(2)-caudalYm,'C','Color','w','FontSize',12,'FontWeight','bold','HorizontalAlignment','center','VerticalAlignment','middle');
        text(ax1,leftXm,layout(2)-leftYm,leftText,'Color','w','FontSize',12,'FontWeight','bold','HorizontalAlignment','center','VerticalAlignment','middle');
        text(ax1,rightXm,layout(2)-rightYm,rightText,'Color','w','FontSize',12,'FontWeight','bold','HorizontalAlignment','center','VerticalAlignment','middle');

        daspect(ax1,[yscale xscale 1]);
        daspect(ax2,[yscale xscale 1]);

        colorbarPosition = get(c,'Position');
        axisPosition = get(ax1,'Position');
        colorbarPadding = colorbarPosition(1) - axisPosition(1) - axisPosition(3);

        if colorbarPadding < 0
            colorbarPadding = 0;
        else
            axisPosition(1) = axisPosition(1) - colorbarPadding/2;
            colorbarPadding = colorbarPadding*2;
        end

        set(c,'Position',[axisPosition(1) + axisPosition(3) + colorbarPadding colorbarPosition(2:end)]);

        set(ax1,'Position',axisPosition); % matlab why do you feel the need to make me do this
        set(ax2,'Position',axisPosition); % matlab why do you feel the need to make me do this
        
        % TODO : more control over saving
        saveas(gcf,[finalFolder '_' bodyParts{ii} '_motor_tracking_map_real_coords'],'fig');
    end
end