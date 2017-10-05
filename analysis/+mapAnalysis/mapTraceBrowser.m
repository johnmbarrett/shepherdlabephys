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
    properties(Dependent=true,SetAccess=immutable)
        Map
    end
    
    properties(Access=protected)
        MagFactorX
        MagFactorY
    end
    
    properties
        BlankMapHandle
        MapAxis
        MapChoicePopupMenu
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
            
            uicontrol(self.Figure, 'Style', 'text', 'String', self.Recording.RecordingName, 'FontSize', 12, ... % TODO : non-Ephus compatibility
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
            
            self.MapChoicePopupMenu = uicontrol(self.Figure, 'Tag', 'mapChoicePopupMenu', ...
                'Style', 'popupmenu', 'BackgroundColor', 'w', 'FontSize', 12, ...
                'Value', 1, 'String', self.getMapChoices(), 'Callback', @self.changeMap, ...
                'Units', 'normalized', 'Position', [0.5   0.55    0.1   0.04], 'Enable', 'off');
    
            uicontrol(gcf, 'Style', 'text', 'String', 'current trace', 'FontSize', 10, ...
                'Units', 'normalized', 'Position', [0.5   0.83    0.06    0.04]);
            
            self.MapAxis = axes;
            set(self.MapAxis, 'Tag', 'mapaxis', 'Position', [0.5    0.15    0.1    0.35], 'box', 'on');
            
            self.SliceAxis = axes;
            set(self.SliceAxis, 'Tag', 'sliceaxis', 'Position', [0.65    0.15    0.3    0.75]);
            title('Click on axes to upload an image');
            
            self.updatePlots();
        end
    end

    methods
        function self = mapTraceBrowser(recording,parent)
            self@mapAnalysis.traceBrowser(recording,parent,false);
        end
        
        function data = getData(self)
            if isempty(self.Map)
                data = [];
                return
            end
            
            data = self.Map.Data;
            data = permute(data,[2 1 3:ndims(data)]);
        end
        
        function map = get.Map(self)
            if isempty(self.Recording_)
                map = [];
                return
            end
            
            if isa(self.Recording,'mapAnalysis.CellRecording')
                map = self.Recording.BaselineSubtracted;
            elseif isa(self.Recording,'mapAnalysis.VideoMapRecording')
                map = self.Recording.AverageDistance;
            end
        end
        
        function updatePlots(self)
            self.updatePlots@mapAnalysis.traceBrowser();
            
            if ~isempty(self.Data)
                self.plotMap();
                self.plotSlice();
            end
        end
        
        function choices = getMapChoices(self,varargin)
            fields = fieldnames(self.Recording);
            fields = fields(cellfun(@(f) isa(self.Recording.(f),'mapAnalysis.Map') && isnumeric(self.Recording.(f).Data),fields));
            
            choices = [{'Pattern'};fields];
        end
        
        function changeMap(self,menu,varargin)
            choice = menu.Value;
            
            if choice == 1
                map = self.Map.Pattern;
            else
                map = self.Recording.(menu.String{choice}).Array;
            end
            
            if size(map,3) > 1
                map = nanmean(map,3);
            end
            
            set(self.MapHandle,'CData',flipud(map));
        end
        
        function changeTrace(self,controlOrValue,varargin)
            self.changeTrace@mapAnalysis.traceBrowser(controlOrValue,varargin{:});
            self.Recording.highlightMapPixel(self.MapAxis,self.CurrentTrace,'c');
            self.Recording.highlightMapPixel(self.SliceAxis,self.CurrentTrace,'w');
        end
        
        function highlightTrace(self,ax)
            hold(ax,'on');
            [row,col] = find(flipud(self.Map.Pattern) == self.CurrentTrace);%GS20060524
            y = (row - 1);
            x = (col - 1);
            
            if isa(self.Recording,'mapAnalysis.EphusCellRecording') % TODO : do this properly for other kinds of maps
                xSpacing = self.Recording.UncagingHeader.xSpacing;
                ySpacing = self.Recording.UncagingHeader.ySpacing;
            else
                xSpacing = self.Parent.mapSpacing;
                ySpacing = self.Parent.mapSpacingY;
            end
            
            y = y * ySpacing - self.MagFactorY;
            x = x * xSpacing - self.MagFactorX;
            
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
            self.MapHandle = self.Recording.plotMapPattern(self.MapAxis,self.CurrentTrace);

            set(self.MapHandle,'ButtonDownFcn',@self.pickTrace);
        end
        
        function pickTrace(self,source,eventData)
            M = flipud(self.Map.Pattern);  % GS200605024

            x = eventData.IntersectionPoint(1);
            y = eventData.IntersectionPoint(2);

            [rowInd,colInd] = self.Recording.convertImageCoordinatesToMapCoordinates(x,y,source,size(M,1),size(M,2));

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
            end

            [self.SliceHandle,self.BlankMapHandle] = self.Recording.plotMapAreaOnVideoImage(self.SliceAxis,R,self.CurrentTrace,self.MapHandle);
            set(self.SliceHandle, 'ButtonDownFcn', @self.changeSliceImage);
            set(self.BlankMapHandle,'ButtonDownFcn',@self.pickTrace);
        end
    end
end