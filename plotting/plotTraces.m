function [ax,traceHandles,peakHandles,stimHandles] = plotTraces(ax,data,sampleRate,varargin)
%PLOTTRACES Plot electrophysiology traces
%   PLOTPARAMS(DATA,SAMPLERATE) plots the electrophysiology traces in the
%   matrix DATA (one per column, sampled at SAMPLERATE).
%
%   PLOTPARAMS(TIME,DATA,SAMPLERATE) plots the data using TIME as the
%   X-axis values.  TIME must have the same size as DATA or be a vector
%   with length(TIME) == size(DATA,1).
%
%   AX = PLOTPARAMS(...) returns a handle, AX, to the resulting plot.
%
%   [AX,TH,PH,SH] = PLOTPARAMS(...) additionally returns handles to the
%   plotted traces (TH), the specified peak values (PH), and the stim times
%   (SH).
%
%   PLOTPARAMS(AX,...) plots the data into the axes handle AX instead of
%   creating a new figure.
%
%   PLOTPARAMS(...,PARAM1,VAL1,PARAM2,VAL2,...)  specifies one or more of 
%   the following name/value pairs:
%
%       'Peaks'         Vector specifying Y-axis values of points of 
%                       interest (e.g. peak response) to be highlighted on 
%                       the plot with circles.  Default is no points.
%       'PeakIndices'   Vector specifying Y-axis values of points of 
%                       interest (e.g. peak response) to be highlighted on 
%                       the plot with circles.  Default is no points.
%       'StimStart'     Draws a dashed vertical line at the time(s)
%                       specified.  Default is no line.
%       'RecordingMode' Specifies the Y-axis label.  Options are 'IC' for
%                       current-clamp mode, i.e. Y-axis label is mV, or
%                       'VC' for voltage-clamp mode, i.e. Y-axis label is
%                       pA.
%       'Title'         Gives the plot the specified title.  Default is no
%                       title.

%   Written by John Barrett 2017-08-14 11:42 CDT
%   Last updated John Barrett 2017-08-25 11:13 CDT
    if ~all(ishandle(ax));
        if nargin > 2
            varargin = [{sampleRate} varargin];
        end
        
        sampleRate = data;
        data = ax;
        
        figure;
        ax = axes;
    end
    
    if ~isscalar(sampleRate)
        if ((isequal(size(data),size(sampleRate))) || (isvector(data) && length(data) == size(sampleRate,1))) && isscalar(varargin{1})
            % user must have passed in time data as well
            time = data;
            data = sampleRate;
            sampleRate = varargin{1};
            varargin = varargin(2:end);
        else
            error('ShepherdLab:plotTraces:InvalidSampleRate','Sample rate must be a scalar');
        end
    else
        time = (1:size(data,1))/sampleRate;
    end
    
    parser = inputParser;
    % TODO : Peaks and PeakIndices could really be any points of interest,
    % and maybe StimStart can just be abcissa?  can we factor out common
    % code between this and plotParams
    addParameter(parser,'Peaks',NaN,@(x) validateattributes(x,{'numeric'},{'real' 'finite' 'vector'}));
    addParameter(parser,'PeakIndices',NaN,@(x) validateattributes(x,{'numeric'},{'real' 'finite' 'positive' 'integer' 'vector'}));
    addParameter(parser,'StimStart',NaN,@(x) validateattributes(x,{'numeric'},{'real' 'finite' 'vector'}));
    addParameter(parser,'RecordingMode','VC',@(x) ismember(x,{'VC' 'IC'}));
    addParameter(parser,'Title','',@ischar);
    parser.parse(varargin{:});
    
    hold(ax,'on');
    
    title(parser.Results.Title,'Parent',ax);
    
    xlabel(ax,'Time (s)');
    
    switch parser.Results.RecordingMode
        case 'VC'
            ylabel('Current (pA)');
        case 'IC'
            ylabel('Voltage (mV)');
        otherwise
            % TODO : this should throw an error, or at least a warning
            disp('Check the recordMode field');
    end
    
    if isempty(data) % matlab is dumb and will error if this happens
        data = nan(size(time)); 
    end
    
    traceHandles = plot(ax,time,data);
    
    stimHandles = plot(ax,(parser.Results.StimStart(:)*[1 1])',repmat(ylim(ax)',1,numel(parser.Results.StimStart)),'Color','k','LineStyle','-.'); % TODO : override these plot options?
    
    if all(isnan(parser.Results.Peaks(:)))
        hold(ax,'off');
        peakHandles = [];
        return
    end
    
    if all(isnan(parser.Results.PeakIndices(:)))
        error('ShepherdLab:plotTraces:MissingPeakIndices','You must provide PeakIndices when passing Peaks to plotTraces.');
    end
    
    peaks = parser.Results.Peaks;
    peakIndices = parser.Results.PeakIndices;
    
    assert(numel(peaks) == numel(peakIndices),'ShepherdLab:plotTraces:PeaksPeakIndicesMismatch','The must be one PeakIndex for every peak');
    
    peakHandles = plot(peakIndices(:)/sampleRate,peaks(:),'Color','k','LineStyle','none','Marker','o','MarkerSize',10);
    
    hold(ax,'off');
end