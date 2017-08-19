function addMenu4DistanceMeasure(self,imgFigHandle)
% HELP on measuring distances on images
% 
% Select 'Measure' to activate.
%
% Left-click to select points repeatedly, then
% right-click on the final point to exit. 
%
% Distance data are displayed in the Command Window.
%
% Tip: maximize the figure window to select points more precisely.
%
% Special case for "yfrac" measurement: if you click on 4 points total --
% e.g., #1 on the pia, #2 on the L1/2 border, #3 on the soma, and #4 on 
% the L6/WM border -- then the fractional distance of the 3rd point 
% (relative to the 1st and 4th points) will also be calculated. 
%

    % addMenu4DistanceMeasure

    % gs 2008 03 08
    % ------------------------------------

    if nargin < 2
        imgFigHandle = gcf;
    end

    hmenu = uimenu(imgFigHandle, 'Label', 'MEASUREMENT');
    uimenu(hmenu, 'Label', 'Help', 'Callback', @(varargin) help('mapalyzer.addMenu4DistanceMeasure'));
    uimenu(hmenu, 'Label', 'Measure', 'Callback', @self.measureDistances);
end

    