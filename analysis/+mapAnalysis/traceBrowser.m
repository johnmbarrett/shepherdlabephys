classdef traceBrowser < handle
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
        Data
    end

    properties(Dependent=true)
        CurrentTrace
        Recording
    end
    
    properties(Access=protected)
        Parent
        Recording_
    end
    
    properties
        Figure
        StimHandles
        TraceAxis
        TraceEdit
        TraceHandles
        TraceSlider
    end
    
    methods(Abstract=true,Access=protected)
        createFigure(self)
    end
       
    methods(Abstract=true)
        data = getData(self);
    end

    methods
        function self = traceBrowser(recording,parent,noPlot)
            self.Recording = recording;
            
            assert(isa(parent,'mapAnalysis.mapalyzer'),'ShepherdLab:mapAnalysis:traceBrowser:InvalidParent','Trace browser parent must be a mapalyzer');
            
            self.Parent = parent;
            
            if nargin < 2 || noPlot
                return
            end
            
            self.createFigure();
        end
        
        function delete(self)
            if isa(self.Figure,'handle') && isvalid(self.Figure)
                delete(self.Figure);
            end
        end  
           
        function fig = raiseFigure(self)
            if ~isa(self.Figure,'handle') || ~isvalid(self.Figure)
                self.createFigure();
            end
            
            set(self.Figure,'Visible','on');
            
            fig = self.Figure;
        end
        
        function trace = get.CurrentTrace(self)
            trace = get(self.TraceSlider,'Value');
        end
        
        function set.CurrentTrace(self,value)
            % TODO : bounds checking, also should this update the display?
            set(self.TraceSlider,'Value',value);
        end
        
        function data = get.Data(self)
            data = self.getData();
        end
        
        function updatePlots(self)
            if ~isempty(self.Data)
                self.plotTrace();
            end
        end
        
        function recording = get.Recording(self)
            recording = self.Recording_;
        end
        
        function set.Recording(self,recording)
            assert(isa(recording,'mapAnalysis.Recording'),'Recording must be a mapAnalysis.Recording');
            
            self.Recording_ = recording;
            
            % TODO : event-driven model
            if isa(self.Figure,'handle') && isvalid(self.Figure)
                self.updatePlots();
            end
        end
        
        function changeTrace(self,controlOrValue,varargin)
            if isnumeric(controlOrValue)
                newValue = controlOrValue;
            else
                switch get(controlOrValue,'Tag')
                    case 'traceEdit'
                        oldValue = get(self.TraceSlider,'Value');
                        newValue = str2double(get(controlOrValue,'String'));
                    case 'traceSlider'
                        oldValue = str2double(get(self.TraceEdit,'String'));
                        newValue = get(controlOrValue,'Value');
                end
            end
            
            if ~isfinite(newValue) || ~isreal(newValue) || newValue < 1 || newValue > size(self.Data,2)
                warning('ShepherdLab:mapAnalysis:traceBrowser:changeTrace:InvalidTraceIndex','Invalid trace index %d: should be in the range 1-%d\n',newValue,size(self.Data,2));
                set(self.TraceEdit,'String',num2str(oldValue));
                set(self.TraceSlider,'Value',oldValue);
                return
            end
            
            set(self.TraceEdit,'String',num2str(newValue));
            set(self.TraceSlider,'Value',newValue);
            
            self.plotTrace(newValue);
        end
        
        function plotTrace(self,index)
            if nargin < 2
                index = self.CurrentTrace;
            end
            
            if index < 1 || index > size(self.Data,2)
                warning('ShepherdLab:mapAnalysis:traceBrowser:plotTrace:InvalidTraceIndex','Invalid trace index %d: should be in the range 1-%d\n',index,size(self.Data,2));
                return
            end
            
            cla(self.TraceAxis);

            % TODO : should this information be stored in the map as well?
            switch self.Parent.lstbxTraceType
                case 'general physiology traces'
                    stimOn = self.Parent.stimOnGen;
                case 'excitation profile'
                    stimOn = self.Parent.stimOnEP;
                case 'input map'
                    stimOn = self.Parent.stimOn;
                otherwise
                    stimOn = self.Parent.stimOn;
            end

            if ~isempty(self.Parent.isCurrentClamp) && self.Parent.isCurrentClamp
                recordingMode = 'IC';
            else
                recordingMode = 'VC';
            end
            
            data = self.Data;
            
            extraColons = repmat({':'},1,ndims(data)-2);
    
            [~,self.TraceHandles,~,self.StimHandles] = plotTraces(self.TraceAxis,squeeze(data(:,index,extraColons{:})),self.Parent.sampleRate,'RecordingMode',recordingMode,'StimStart',stimOn);
            % TODO : can we pass options like these through to plot traces instead?
            set(self.TraceHandles, 'Color', 'b');
            set(self.StimHandles, 'Color', 'c');
        end
    end
end