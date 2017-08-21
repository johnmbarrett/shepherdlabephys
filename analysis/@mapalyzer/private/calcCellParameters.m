function calcCellParameters(self)
% calcCellParameters
%
% Editing:
% gs april 2005
% ----------------------------------------------------------------


    if ~isempty(self.isCurrentClamp) && self.isCurrentClamp
        warning('ShepherdLab:mapalyzer:calculateCellParameters:CurrentClampCellParametersNotImplemented','Cell parameter calculations not yet implemented for current clamp.');
        return
    end

    for ii = 1:self.numberOfMaps
        map = self.maps(ii);
        
        [map.rseries, map.rmembrane, map.tau, map.cmembrane] = calculateCellParameters(map.bsArray(:,1:self.RsSkipVal:end), self.rstepAmp/1000, self.sampleRate, ...
            'ResponseStart',        self.rstepOn,                   ...
            'ResponseLength',       self.rstepDur,                  ...
            'SteadyStateStart',     self.rstepOn+2*self.rstepDur/3, ... TODO : expose? the old mapAnalysis forced you to use the last third of the data
            'SteadyStateLength',    self.rstepDur/3,                ...
            'TauMethod',            'fit'                           ...
            );

        self.maps(ii) = map; % TODO : handle classes
        
        if strcmp(map.filenames,self.mapActive.filenames)
            self.mapActive = map;
        end
    end
    
    % TODO : is the mapAvg struct even necessary?
    self.mapAvg.rseries = nanmean([self.maps.rseries]);
    self.mapAvg.rmembrane = nanmean([self.maps.rmembrane]);
    self.mapAvg.tau = nanmean([self.maps.tau]);
    self.mapAvg.cmembrane = nanmean([self.maps.cmembrane]);
    
    % TODO : the code to keep the UI in sync with the data is all over the
    % place.  an event-driven model would solve this.
    self.rseriesAvg = self.mapAvg.rseries;
    self.rmembraneAvg = self.mapAvg.rmembrane;
    self.tauAvg = self.mapAvg.tau;
    self.cmembraneAvg = self.mapAvg.cmembrane;
end