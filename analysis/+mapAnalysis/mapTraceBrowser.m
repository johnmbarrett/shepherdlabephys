classdef mapTraceBrowser < mapAnalysis.traceBrowser
% traceBrowser     Browse traces; includes pix2trace options.
%
% See also traceBrowser, traceAdvancer, analyzeArrayDual, 
%      loadDualTraces
%
% Editing:
% gs 2005 -- Adapted for traceBrowserDual
% (initially partly based on loadTracesMinStim)
% gs april 2005 -- adapted for mapAnalysis3p0 
% gs may 2006 - %GS20060524 - modified for ephus compatibility; flipud's added
% -------------------------------------------------------------
    properties(Access=protected)
        MagFactorX
        MagFactorY
    end
    
    properties
        BlankMapHandle
        MapAxis
        MapHandle
        MapHighlightHandle
        SliceAxis
        SliceHandle
        SliceHighlightHandle
    end
    
    methods(Access=protected)
        function createFigure(self)
            self.Figure = figure;

            set(gcf, 'Color', 'w', 'DoubleBuffer', 'on', 'Units', 'normalized', ...
                'Position', [0.1    0.5    0.8    0.4], 'Toolbar', 'figure');

            self.TraceAxis = axes;
            set(self.TraceAxis, 'Position', [0.05    0.15    0.4    0.75]);
            axis tight;
            set(gca, 'DataAspectRatioMode', 'auto');
            set(gca, 'PlotBoxAspectRatioMode', 'auto');
            
            uicontrol(self.Figure, 'Style', 'text', 'String', self.Map.baseName(1:(end-4)), 'FontSize', 12, ...
                'FontWeight', 'bold', 'Units', 'normalized', 'Position', [0.03   0.93    0.5    0.05], ...
                'BackgroundColor', 'w', 'HorizontalAlignment', 'left');

            colormap(gray(256));
            
            numTraces = size(self.Data,2);
            
            self.TraceSlider = uicontrol(self.Figure, 'Tag', 'traceSlider', 'Style', 'slider', ...
                'min', 1, 'max', numTraces, ...
                'SliderStep', [1/(numTraces-1) 1/(numTraces-1)], ...
                'Callback', @self.changeTrace, 'Value', 1, ...
                'Units', 'normalized', 'Position', [0.5   0.75    0.06    0.04]);

            self.TraceEdit = uicontrol(self.Figure, 'Tag', 'traceEdit', 'Style', 'edit', ...
                'min', 1, 'max', 1, 'BackgroundColor', 'w', 'FontSize', 12, ...
                'Callback', @self.changeTrace, 'String', 1, ...
                'Units', 'normalized', 'Position', [0.5   0.79    0.06    0.04]);
    
            uicontrol(gcf, 'Style', 'text', 'String', 'current trace', 'FontSize', 10, ...
                'Units', 'normalized', 'Position', [0.5   0.83    0.06    0.04]);
            
            self.MapAxis = axes;
            set(self.MapAxis, 'Position', [0.5    0.15    0.1    0.35], 'box', 'on');
            
            self.SliceAxis = axes;
            set(self.SliceAxis, 'Position', [0.65    0.15    0.3    0.75]);
            title('Click on axes to upload an image');
            
            self.updatePlots();
        end
    end

    methods
        function self = mapTraceBrowser(varargin) % matlab this shouldn't be necessary :|
            self@mapAnalysis.traceBrowser(varargin{:});
        end
        
        function updatePlots(self)
            self.updatePlots@mapAnalysis.traceBrowser();
            
            if ~isempty(self.Data)
                self.plotMap();
                self.plotSlice();
            end
        end
        
        function changeTrace(self,controlOrValue,varargin)
            self.changeTrace@mapAnalysis.traceBrowser(controlOrValue,varargin{:});
            self.highlightTrace(self.MapAxis);
            self.highlightTrace(self.SliceAxis);
        end
        
        function data = getMapData(self)
            data = self.Map.bsArray;
        end
        
        function highlightTrace(self,ax)
            hold(ax,'on');
            [row,col] = find(flipud(self.Map.uncagingHeader.mapPatternArray) == self.CurrentTrace);%GS20060524
            y = (row - 1) * self.Map.uncagingHeader.xSpacing - self.MagFactorY;
            x = (col - 1) * self.Map.uncagingHeader.ySpacing - self.MagFactorX;
            
            % TODO : this feels dirty somehow?
            if ax == self.MapAxis
                color = 'c';
                highlightHandle = 'MapHighlightHandle';
            elseif ax == self.SliceAxis
                color = 'w';
                highlightHandle = 'SliceHighlightHandle';
            else
                % TODO : warning?
                return
            end
            
            if isa(self.(highlightHandle),'handle')
                delete(self.(highlightHandle));
            end
            
            self.(highlightHandle) = plot(ax,x,y,'Color',color,'LineWidth',1,'Marker','*','MarkerSize', 12);
        end
        
        function plotMap(self)
            [sizeY,sizeX] = size(self.Map.uncagingHeader.mapPatternArray); % LTP corrected 
            self.MagFactorX = (self.Map.uncagingHeader.xSpacing*(sizeX-1))/2;
            self.MagFactorY = (self.Map.uncagingHeader.ySpacing*(sizeY-1))/2;

            self.MapHandle = imagesc(self.MapAxis,flipud(self.Map.uncagingHeader.mapPatternArray)); %GS20060524
            set(self.MapHandle,'XData',[-self.MagFactorX self.MagFactorX],'YData',[-self.MagFactorY self.MagFactorY]);
            set(self.MapAxis, 'PlotBoxAspectRatio', [1 1 1], 'YDir', 'normal');%GS20060524
            axis(self.MapAxis,'tight');

            self.highlightTrace(self.MapAxis);

            set(self.MapHandle,'ButtonDownFcn',@self.pickTrace);
        end
        
        function pickTrace(self,source,eventData)
            M = flipud(self.Map.uncagingHeader.mapPatternArray);  % GS200605024

            x = eventData.IntersectionPoint(1);
            y = eventData.IntersectionPoint(2);

            xdata = get(source, 'XData'); % TODO : src, surely???
            numCols = size(M,2);
            pixelSideX = (xdata(2) - xdata(1))/(numCols - 1);
            fullSideX = [xdata(1)-pixelSideX/2 xdata(2)+pixelSideX/2];
            Xfraction = (x - fullSideX(1)) / (fullSideX(2) - fullSideX(1));
            colInd = ceil(Xfraction * numCols);
            
            ydata = get(source, 'YData');
            numRows = size(M,1);
            pixelSideY = (ydata(2) - ydata(1))/(numRows - 1);
            fullSideY = [ydata(1)-pixelSideY/2 ydata(2)+pixelSideY/2];
            Yfraction = (y - fullSideY(1)) / (fullSideY(2) - fullSideY(1));
            rowInd = ceil(Yfraction * numRows);

            traceNumber = M(rowInd, colInd);

            % TODO : switch to event-driven model
            self.changeTrace(traceNumber);
        end
        
        function changeSliceImage(self,varargin)
            % TODO : this breaks encapsulation - would be better to make
            % chooseImageFile a function that is called by both mapalyzer
            % and traceBrowser
            self.Parent.chooseImageFile(true);
            
            self.plotSlice();
        end
        
        function plotSlice(self)
            if isempty(self.Parent.image.img)
                R = magic(4);
                warning('ShepherdLab:mapAnalysis:traceBrowser:plotSlice:NoSliceImage','No slice image has been selected')
            else
                R = self.Parent.image.img;

                R = self.transformImagePosition(R, self.Parent.spatialRotation, ...
                    self.Parent.xPatternOffset, self.Parent.yPatternOffset, ...
                    self.Parent.imageXrange, self.Parent.imageYrange);    

                R = flipud(R);
            end

            self.SliceHandle = imagesc(self.SliceAxis,R);
            set(self.SliceAxis,'YDir', 'normal');

            % TODO : isn't this done somewhere else?
            if isempty(self.Parent.imageXrange)
                xrange = 1900;
                disp('ShepherdLab:mapAnalysis:traceBrowser:NoXRange','Missing image X range, using default');
            else
                xrange = self.Parent.imageXrange;
            end

            if isempty(self.Parent.imageYrange)
                yrange = 1520;
                disp('ShepherdLab:mapAnalysis:traceBrowser:NoYRange','Missing image Y range, using default');
            else
                yrange = self.Parent.imageYrange;
            end

            set(self.SliceHandle, 'XData', [-xrange/2 xrange/2], 'YData', [-yrange/2 yrange/2], ...
                'ButtonDownFcn', @self.changeSliceImage);
            
            hold(self.SliceAxis,'on');

            self.BlankMapHandle = imagesc(self.SliceAxis,zeros(16,16));
            set(self.BlankMapHandle, 'AlphaData', .15, 'XData', [-self.MagFactorX self.MagFactorX], 'YData', [-self.MagFactorY self.MagFactorY]);
            set(self.BlankMapHandle,'ButtonDownFcn',@self.pickTrace);

            self.highlightTrace(self.SliceAxis);

            xdata = get(self.MapHandle, 'XData');
            ydata = get(self.MapHandle, 'YData');
            rectangle(self.SliceAxis,'Position', ...
                [xdata(1) ydata(1) xdata(2)-xdata(1) ydata(2)-ydata(1)], ...
                'EdgeColor', 'y', 'LineStyle', ':');

            plot(self.SliceAxis,self.Parent.somaXnew,self.Parent.somaYnew,'co');
            
            daspect(self.SliceAxis,[1 1 1]);
            axis(self.SliceAxis,'tight');
        end
    end
end