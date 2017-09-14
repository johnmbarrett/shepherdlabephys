classdef EphusCellRecording < mapAnalysis.CellRecording
    properties
        AcquirerHeader
        BaseName
        TraceNumber
        Filenames
        HeaderGUI
        ImagingSysHeader
        LaserIntensity
        PhysHeader
        ScopeHeader
        UncagingHeader
        UncagingPathName
    end
    
    methods
        function name = getRecordingName(self)
            name = sprintf('%s%04d',self.BaseName,self.TraceNumber);
        end
        
        function [rowInd,colInd] = convertImageCoordinatesToMapCoordinates(~,x,y,source,numRows,numCols)
            xdata = get(source, 'XData'); % TODO : src, surely???
            pixelSideX = (xdata(2) - xdata(1))/(numCols - 1);
            fullSideX = [xdata(1)-pixelSideX/2 xdata(2)+pixelSideX/2];
            Xfraction = (x - fullSideX(1)) / (fullSideX(2) - fullSideX(1));
            colInd = ceil(Xfraction * numCols);
            
            ydata = get(source, 'YData');
            pixelSideY = (ydata(2) - ydata(1))/(numRows - 1);
            fullSideY = [ydata(1)-pixelSideY/2 ydata(2)+pixelSideY/2];
            Yfraction = (y - fullSideY(1)) / (fullSideY(2) - fullSideY(1));
            rowInd = ceil(Yfraction * numRows);
        end
        
        function highlightMapPixel(self,ax,highlight,color)
            hold(ax,'on');
            [row,col] = find(flipud(self.Raw.Pattern) == highlight);%GS20060524
            [sizeY,sizeX] = size(self.Raw.Pattern);
            y = (row-1-(sizeY-1)/2)*self.UncagingHeader.ySpacing;
            x = (col-1-(sizeX-1)/2)*self.UncagingHeader.xSpacing;
            
            delete(findobj(ax,'Marker','*'));
            
            plot(ax,x,y,'Color',color,'LineWidth',1,'Marker','*','MarkerSize', 12);
        end
        
        function [magFactorX,magFactorY] = getMagFactor(self)
            [sizeY,sizeX] = size(self.Raw.Pattern); % LTP corrected 
            
            magFactorX = (self.UncagingHeader.xSpacing*(sizeX-1))/2;
            magFactorY = (self.UncagingHeader.ySpacing*(sizeY-1))/2;
        end
        
        function handle = plotMapPattern(self,ax,highlight)
            [magFactorX,magFactorY] = self.getMagFactor();

            handle = imagesc(ax,flipud(self.Raw.Pattern)); %GS20060524
            set(handle,'XData',[-magFactorX magFactorX],'YData',[-magFactorY magFactorY]);
            set(ax, 'PlotBoxAspectRatio', [1 1 1], 'YDir', 'normal');%GS20060524
            axis(ax,'tight');

            self.highlightMapPixel(ax,highlight,'c');
        end
        
        function [sliceHandle,blankMapHandle] = plotMapAreaOnVideoImage(self,ax,img,highlight,mapHandle)
            img = transformImagePosition(img, self.UncagingHeader.spatialRotation, ...
                self.UncagingHeader.xPatternOffset, self.UncagingHeader.yPatternOffset, ...
                self.ImagingSysHeader.xMicrons, self.ImagingSysHeader.yMicrons);    

            img = flipud(img);

            sliceHandle = imagesc(ax,img);
            set(ax,'YDir', 'normal');
            
            % TODO : isn't this done somewhere else?
            if isempty(self.ImagingSysHeader.xMicrons)
                xrange = 1900;
                warning('ShepherdLab:mapAnalysis:EphusCellRecording:plotMapAreaOnVideoImage:NoXRange','Missing image X range, using default');
            else
                xrange = self.ImagingSysHeader.xMicrons;
            end

            if isempty(self.ImagingSysHeader.yMicrons)
                yrange = 1520;
                warning('ShepherdLab:mapAnalysis:EphusCellRecording:plotMapAreaOnVideoImage:NoYRange','Missing image Y range, using default');
            else
                yrange = self.ImagingSysHeader.yMicrons;
            end

            set(sliceHandle, 'XData', [-xrange/2 xrange/2], 'YData', [-yrange/2 yrange/2]);
            
            hold(ax,'on');
            
            [magFactorX,magFactorY] = self.getMagFactor();

            blankMapHandle = imagesc(ax,zeros(16,16));
            set(blankMapHandle, 'AlphaData', .15, 'XData', [-magFactorX magFactorX], 'YData', [-magFactorY magFactorY]);

            self.highlightMapPixel(ax,highlight,'w');

            xdata = get(mapHandle, 'XData');
            ydata = get(mapHandle, 'YData');
            rectangle(ax,'Position', ...
                [xdata(1) ydata(1) xdata(2)-xdata(1) ydata(2)-ydata(1)], ...
                'EdgeColor', 'y', 'LineStyle', ':');
            
            [somaXnew,somaYnew] = transformPosition( ...
                self.UncagingHeader.soma1Coordinates(1),    ...
                self.UncagingHeader.soma1Coordinates(2),    ...
                self.UncagingHeader.spatialRotation,        ...
                self.UncagingHeader.xPatternOffset,         ...
                self.UncagingHeader.yPatternOffset);

            plot(ax,somaXnew,somaYnew,'co');
            
            daspect(ax,[1 1 1]);
            axis(ax,'tight');
        end
    end
end