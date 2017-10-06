classdef genericTraceBrowser < mapAnalysis.traceBrowser
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
        AverageTracesButton
        IsBaselineSubtracted_
    end
    
    properties(Dependent=true)
        IsBaselineSubtracted
    end
    
    methods(Access=protected)
        function createFigure(self)
            % TODO : most of this is very similar between mapTraceBrowser
            % and genericTraceBrowser.  maybe pull some of it up into the
            % superclass?
            self.Figure = figure;

            set(self.Figure, 'Color', 'w', 'DoubleBuffer', 'on', 'Units', 'normalized', ...
            'Position', [0.1    0.5    0.4    0.4], 'Toolbar', 'figure');

            self.TraceAxis = axes;
            set(self.TraceAxis, 'Position', [0.07    0.1    0.88    0.84]);
            axis tight;
            set(gca, 'DataAspectRatioMode', 'auto');
            set(gca, 'PlotBoxAspectRatioMode', 'auto');
            
            uicontrol(self.Figure, 'Style', 'text', 'String', self.Recording.RecordingName, 'FontSize', 12, ...
                'FontWeight', 'bold', 'Units', 'normalized', 'Position', [0.03   0.93    0.5    0.05], ...
                'BackgroundColor', 'w', 'HorizontalAlignment', 'left');

            colormap(gray(256));
            
            numTraces = size(self.Data,2);
            
            xLoc = 0.07;
            yLoc = 0.95;
            hgt = 0.04;
            self.TraceSlider = uicontrol(self.Figure, 'Tag', 'traceSlider', 'Style', 'slider', ...
                'min', 1, 'max', numTraces, ...
                'SliderStep', [1/(numTraces-1) 1/(numTraces-1)], ...
                'Callback', @self.changeTrace, 'Value', 1, ...
                'Units', 'normalized', 'Position', [xLoc+.25   yLoc    0.1    hgt]);

            self.TraceEdit = uicontrol(self.Figure, 'Tag', 'traceEdit', 'Style', 'edit', ...
                'min', 1, 'max', 1, 'BackgroundColor', 'w', 'FontSize', 12, ...
                'Callback', @self.changeTrace, 'String', 1, ...
                'Units', 'normalized', 'Position', [xLoc+.15   yLoc    0.1    hgt]);
    
            uicontrol(gcf, 'Style', 'text', 'String', 'Current trace:', 'FontSize', 10, ...
                'Units', 'normalized', 'Position', [xLoc   yLoc    0.15    hgt]);
            
            self.AverageTracesButton = uicontrol(gcf, 'Tag', 'AvgTracesGen', 'Style', 'pushbutton', ...
                'FontSize', 12, 'Callback', @self.averageTraces, 'String', 'Avg selected traces', ...
                'Units', 'normalized', 'Position', [xLoc+.6   yLoc    0.2    hgt]);
            
            self.updatePlots();
        end
    end

    methods
        function self = genericTraceBrowser(recording,parent,browseType)
            self@mapAnalysis.traceBrowser(recording,parent,true);
            
            if nargin < 2
                self.IsBaselineSubtracted = true;
            else
                self.IsBaselineSubtracted = browseType;
            end
            
            self.createFigure();
        end
        
        function b = get.IsBaselineSubtracted(self)
            b = self.IsBaselineSubtracted_;
        end
        
        function set.IsBaselineSubtracted(self,value)
            if islogical(value)
                self.IsBaselineSubtracted = all(value);
            elseif ischar(value)
                assert(ismember(value,{'baseline subtracted' 'not baseline subtracted'}),'ShepherdLab:mapAnalysis:genericTraceBrowser:InvalidBrowseType','Browse type must be one of ''baseline subtracted'' or ''not baseline subtracted''.');

                self.IsBaselineSubtracted_ = strcmp(value,'baseline subtracted');
            else
                error('ShepherdLab:mapAnalysis:genericTraceBrowser:InvalidBrowseType','Browse type must be one of ''baseline subtracted'' or ''not baseline subtracted''.');
            end
        end
        
        function data = getData(self)
            if isa(self.Recording,'mapAnalysis.VideoMapRecording')
                data = self.Recording.AverageDistance.Data;
            elseif self.IsBaselineSubtracted
                data = self.Recording.BaselineSubtracted.Data;
            else
                data = self.Recording.Raw.Data;
            end
            
            data = permute(data,[2 1 3:ndims(data)]);
        end
        
        function data = getDataToPlot(self)
            % TODO : move the map location (condition?)/trial/channel logic
            % up into traceBrowser and get rid of this horrible kludge
            data = self.Data;
            
            extraColons = repmat({':'},1,ndims(data)-2);
    
            data = squeeze(data(:,index,extraColons{:}));
        end
        
        function averageTraces(self,varargin)
            tracesToAverage = inputdlg('Enter Matlab-format vector of traces to average (e.g. [1:3 5])');
            tracesToAverage{1} = str2num(tracesToAverage{1}); %#ok<ST2NM>
            
            if isempty(tracesToAverage{1})
                tracesToAverage{1} = ':';
            end

            averageTrace = mean(self.Data(:,tracesToAverage{1}), 2);

            figure;

            plot(averageTrace);
        end
    end
end