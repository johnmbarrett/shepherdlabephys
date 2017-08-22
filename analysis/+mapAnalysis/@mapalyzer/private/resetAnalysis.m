function self = resetAnalysis(self, isLoad)
% RESETANALYSIS reset analysis results in mapalyzer
%
%   RESETANALYSIS(M) resets the calculated cell and baseline parameters for
%   the mapalyzer M.
%
%   RESETANALYSIS(M,ISLOAD) also resets the average laser intensity if
%   ISLOAD is true.

% Created by John Barrett 2017-08-17 17:38 CDT
% Last Modified by John Barrett 2017-08-17 17:39 CDT
% Based on code written by Gordon Shepherd in May 2005
% ----------------------------------------------------

    if isLoad
        % reset on loading
    %     self = [];
    %     handles.data.acq = [];
        self.avgLaserIntensity = [];
    end

    % reset cell parameters
    self.mapAvg.rseries = [];
    self.mapAvg.rmembrane = [];
    self.mapAvg.cmembrane = [];

    % reset baseline analysis results
    self.mapAvg.synThreshpAmV = [];
    self.mapAvg.baselineSD = [];
    self.mapAvg.spontEventRate = [];
end