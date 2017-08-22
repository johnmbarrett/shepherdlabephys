function showAutoNotes(self,varargin)
% showAutoNotesForCurrentExpt

% gs march 2008
% ---------------------------------------

    if isempty(self.mapActive.uncagingPathName);
        warning('ShepherdLab:mapalyzer:showAutoNotes:NoExperimentLoaded','No experiment loaded to show auto notes for.');
        return
    end
    
    dirs = strsplit(self.mapActive.uncagingPathName, {'\' '/'});
    dirs = dirs(~cellfun(@isempty,dirs));
    
    exptName = self.experimentName;
    
    % TODO : this assumes that the autonotes are saved in a folder named
    % after the experiment and that the traces are stored in the same
    % folder (e.g. for general ephys) or one below it (e.g. for maps).
    % there are probably better ways of doing this.
    if strcmpi(dirs{end},exptName)
        exptDir = strjoin(dirs,'/');
    else
        exptDir = strjoin(dirs(1:end-1),'/'); 
    end
    
    fileExt = '.txt';
    
    filename = [exptDir '/' exptName fileExt];
    
    if ~exist(filename,'file')
        warning('ShepherdLab:mapalyzer:showAutoNotes:MissingAutoNotesFile','Unable to find autoNotes file for current experiment');
        return
    end
    
	system(['notepad ' filename ' &']);
end
