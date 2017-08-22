function distanceData = measureDistances(varargin)
% MEASUREDISTANCES  Measures distances between mouse-selected points.
% 
% x and y are vectors of points as obtained using getpts
%
% Data saved to the WS as structure variable 'distanceData'

% gs 2004; 
% modified for use with mapAnalysis, 2008 03 08
% ---------------------------------------------------------

    [x,y] = getpts;
    distanceData = struct('x',{x},'y',{y},'d',[],'yL2',[],'ysoma',[],'yWM',[],'yfrac',[]);

    if numel(x)<2
        warning('ShepherdLab:mapalyzer:measureDistances:InsufficientData','You need to select at least 2 points to measure a distance.');
        return
    end
    
    dx = diff(x);
    dy = diff(y);
    d = [0; sqrt(dx.^2 + dy.^2)];
    distanceData.d = d;

    % yfrac calculation
    if numel(d) == 4 && max(abs(d)) > 1
        D = cumsum(d);

        ysoma = D(end-1);
        yWM = D(end);
        yfrac = round(1000*(ysoma/yWM))/1000;

        distanceData.yL2 = D(end-2);
        distanceData.ysoma = ysoma;
        distanceData.yWM = yWM;
        distanceData.yfrac = yfrac;
    end

    % TODO : no
    assignin('base', 'distanceData', distanceData);
end