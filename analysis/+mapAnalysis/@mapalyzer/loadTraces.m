function loadTraces(self, mode, traceType)
    % loadTraces -- private version for mapAnalysis2p0 gui
    %
    % MODES:
    % 0 -- subset of traces in directory selected manually
    % 1 -- all map traces in for one map automatically selected
    % 2 -- multiple maps, identified manually
    % 3 -- multiple maps, designated in M-file
    %
    % Notes:
    % - for convenience, general physiol traces are to some extent treated as a 'map'
    % 
    % See also
    %
    % Editing:
    % gs march, april 2005
    % gs march, april 2006 - modified for ephus and 'turbo' maps
    % John Barrett, 2017-08-18 - massive refactoring to try and move from a
    % GUIDE style close to true OOP, but honestly I have no idea what's
    % going on here
    % --------------------------------------------------------------------
    
    % TODO : this method is still VERY messy - should be split into
    % multiple (e.g. per load method, per file type, etc)

    % reset
    self.resetAnalysis(true);

    if exist(self.defaultDataDir,'dir')
        cd(self.defaultDataDir);
    else
        warning('ShepherdLab:mapalyzer:MissingDefaultDataDirectory','Unable to find default data directory. Modify mapalyzer.ini');
    end

    % determine how many maps to analyze
    switch mode
        case {0 1}
            numberOfMaps = 1;
        case 2
            numberOfMaps = inputdlg('How many maps to analyze? ');

            if isempty(numberOfMaps)
                return
            end
            
            numberOfMaps = str2double(numberOfMaps{1});
        case 3
            warndlg('Saving data as code is an utterly horrifying design pattern and should be avoided at all costs.  This feature may be removed in a future release of mapalyzer.  Proceed at your own risk...');
            dataMfile = inputdlg('Enter name of data M-file (e.g. g1091P1)');

            if isempty(dataMfile)
                return
            end

            try
                eval(['self.dataMfile = ' dataMfile{1} ';']);
                numberOfMaps = numel(self.dataMfile.mapNumbers);
                self.dataMfile.experiment = self.dataMfile.experiment(1:6); % ??? - jmb 2017-08-17
            catch err
                warndlg('Problem loading specified data M-file.  Don''t say I didn''t warn you...');
                logMatlabError(err,sprintf('Problem loading M-file %s:-\\n',dataMfile));
                return
            end
    end

    % ???
    % try
    %     cd(handles.data.analysis.uncagingPathName); 
    % catch
    % end
    
    switch traceType
        case 'video map'
            filterSpec = '*.mat';
            % TODO : this gets almost immediately overwritten
            self.recordingActive = mapAnalysis.VideoMapRecording();
        otherwise
            filterSpec = {
                '*.xsg', 'Ephus traces (*.xsg)';        ...
                '*.mwf', 'TidalWave traces (*.mwf)';    ... TODO : do we still need to support this?
                '*.*', 'All files (*.*)'                ...
                };
            self.recordingActive = mapAnalysis.EphusCellRecording();
    end

    self.mapNumbers = [];

    for ii = 1:numberOfMaps
        % select the traces to load - step 1
        if mode < 3
            [filename, pathname] = uigetfile(filterSpec,'Select any trace.'); % TODO : explicit trace selection instead of assuming we want all in the folder?
            
            if isnumeric(filename)
                return
            end
        elseif mode == 3
            % TODO : fix this.  or just delete it.
            mapNumID = translateMapNum(handles.data.dataMfile.mapNumbers(ii));
            filename = [handles.data.dataMfile.experiment mapNumID '0001.xsg'];
            % e.g.: gs2224MAAA0001.xsg
            mapNumStr = num2str(handles.data.dataMfile.mapNumbers(ii));
            if numel(mapNumStr) == 1
                mapNumStr = ['0' mapNumStr];
            end % TODO: this probably needs to be fixed for larger #s
            % ------- PROBLEM (START) ----------
            pathname = [handles.data.dataMfile.pathBaseName 'map' mapNumStr '\'];
            % pathBaseName stored incorrectly:
            % e.g. C:\_Cartography\matlab\dataMfiles\Gordon\gs22\traces\map01\
            % should be C:\_Data\Gordon\gs2224\map01
            % quick fix:
            localpath1 = 'C:\_Data\Gordon\'; % <<<<========= settable
            localpath2 = 'D:\DATA\CMdata\'; % <<<<========= settable
            localpath3 = 'E:\DATA\CMdata\'; % <<<<========= settable
            expStr = handles.data.dataMfile.experiment(1:6);
            pathname = [localpath1 expStr '\map' mapNumStr '\'];
            try
                cd(pathname);
            catch
                try
                    pathname = [localpath2 expStr '\map' mapNumStr '\'];
                    cd(pathname);
                catch
                    try
                        pathname = [localpath3 expStr '\map' mapNumStr '\'];
                        cd(pathname);
                    catch
                        warndlg('Unable to find usable local path. Edit loadTraces to provide path.');
                    end
                end
            end
            % ------- PROBLEM (END) ----------
        end

        fullfile = [pathname filename];
        [~,filename,ext] = fileparts(fullfile);

        traceFiles = dir([pathname '*' ext]);

        switch ext
            case '.mat'
                self.mapNumbers = 1; % TODO : not really meaningful for video maps
            case '.mwf'
                % TODO : bump mapNumbers into the Cell class.  also fix up
                % the whole data/UI interaction, maybe into something
                % MVC-ish
                self.mapNumbers = [self.mapNumbers str2double(pathname(end-1:end))];
            case '.xsg'
                dirs = strsplit(pathname,{'/' '\'});
                dirs = dirs(~cellfun(@isempty,dirs));
                mapNumber = sscanf(dirs{end},'map%f');

                if isempty(mapNumber)
                    warning('ShepherdLab:mapalyzer:loadTraces:UnknownMapNumbers', 'Problem extracting map number from directory name %s\n',pathname);
                    self.mapNumbers(end+1) = NaN;
                else
                    self.mapNumbers(end+1) = mapNumber;
                end
                
                self.recordingActive.UncagingPathName = pathname; % TODO : is this needed?

                self.recordingActive.BaseName = filename(1:end-4);
                self.recordingActive.TraceNumber = str2double(filename(end-3:end));

                self.patchChannel = 'P1'; % default

                if mode == 1 || mode == 2
                    lastFile = traceFiles(numel(traceFiles));

                    if ~isempty(strfind(lastFile.name, 'P2')) % i.e., there must be P2 traces ...
                        patchChannel = questdlg('Choose patch channel to process', ...
                            'Select patch channel', 'P1', 'P2', 'P1');

                        self.patchChannel = patchChannel;
                        p = strfind(handles.data.map.recordingActive.BaseName, 'P1');
                        self.recordingActive.BaseName(p+1) = patchChannel(2);
                    end
                end
            otherwise
                warning('ShepherdLab:mapalyzer:loadTraces:UnknownFileFormat', 'Unknown file format %s\n',ext(2:end));
                return
        end

        % step 2
        if mode == 0
            filenames = selectFilesFromList(pathname, ext);
        elseif strcmp(traceType,'video map')
            if mode ~= 1
                % TODO : disable these options in the UI
                errordlg('Currently only loading a single map is supported for video maps.')
                return
            end
            
            filenames = fullfile;
        else %if mode == 1 || mode == 2 || mode == 3
            filenames = arrayfun(@(jj) sprintf('%s%04d%s',self.recordingActive.BaseName,jj,ext),1:numel(traceFiles),'UniformOutput',false);
        end

        switch ext
            case '.mat'
                if mode == 0
                    errordlg('This isn''t implemented yet.'); % TODO : implement
                    self.recordingActive = mapAnalysis.VideoMapRecording.fromVideoFiles(self.recordingActive.Filenames);
                elseif mode == 1
                    self.recordingActive = mapAnalysis.VideoMapRecording.fromMATFile(fullfile);
                end
                
                self.sampleRate = 100; % TODO : pull out of the file?
            case '.xsg'
                self.recordingActive.Directory = pathname;
                self.recordingActive.Filenames = filenames;
                fnames = cellfun(@(fname) [self.recordingActive.UncagingPathName fname],self.recordingActive.Filenames,'UniformOutput',false);
                [data,self.sampleRate] = concatenateEphusTraces(fnames,[],self.aiTraceNum,'Program',self.aiProgram);

                for jj = 1:numel(fnames)
                    % TODO : we load every file twice.  should be able to
                    % pass the structs directly to concatenateEphusTraces
                    traceFile = load(fnames{end},'-mat'); 
                    % NB -- for turbomaps, is this the correct value for the power????? i.e., was this the correctly computed value for this trace, or the prev trace?
                    self.recordingActive.LaserIntensity(jj) = traceFile.header.mapper.mapper.specimenPlanePower;
                end

                if isfield(traceFile.header, 'headerGUI')
                    self.recordingActive.HeaderGUI = traceFile.header.headerGUI.headerGUI;
                end

                self.recordingActive.PhysHeader = traceFile.header.ephys.ephys;
                self.recordingActive.UncagingHeader = traceFile.header.mapper.mapper;
                self.recordingActive.ScopeHeader = traceFile.header.scopeGui.ephysScopeAccessory; % gs 20060625
                self.recordingActive.AcquirerHeader = traceFile.header.acquirer.acquirer; % gs 20060625
                self.recordingActive.ImagingSysHeader = traceFile.header.imagingSys.imagingSys; % gs 20080627
        
                if numel(self.recordingActive.UncagingHeader.mapPatternArray) == size(data,2)
                    pattern = self.recordingActive.UncagingHeader.mapPatternArray;
                else
                    pattern = 1:size(data,2);
                end

                self.recordingActive.Raw = mapAnalysis.Map(data',pattern);
                
                if self.recordingActive.UncagingHeader.xSpacing ~= self.recordingActive.UncagingHeader.ySpacing
                    warning('ShepherdLab:mapalyzer:loadTraces:UnequalXYSpacing','Map %d has different X and Y spacing, using X spacing by default.',ii);
                end

                if isfield(self.recordingActive.ImagingSysHeader,'xMicrons') && isfield(self.recordingActive.ImagingSysHeader,'yMicrons')
                    self.imageXrange = self.recordingActive.ImagingSysHeader.xMicrons;
                    self.imageYrange = self.recordingActive.ImagingSysHeader.yMicrons;
                else %% TODO: implement these parameters properly
                    if ~isfield(self.recordingActive.UncagingHeader,'videoHorizontalDistance')
                        self.recordingActive.UncagingHeader.videoHorizontalDistance = 2666;
                        warning('ShepherdLab:mapalyzer:loadTraces:NoHorizontalDistance','No xMicrons or videoHorizontalDistance in map %d, using default value',ii);
                    end

                    if ~isfield(self.recordingActive.UncagingHeader,'videoVerticalDistance')
                        self.recordingActive.UncagingHeader.videoVerticalDistance = 2000;
                        warning('ShepherdLab:mapalyzer:loadTraces:NoVerticalDistance','No yMicrons or videoVerticalDistance in map %d, using default value',ii);
                    end

                    self.imageXrange = self.recordingActive.UncagingHeader.videoHorizontalDistance;
                    self.imageYrange = self.recordingActive.UncagingHeader.videoVerticalDistance;
                end

                if isempty(self.recordingActive.UncagingHeader.soma1Coordinates)
                    self.somaX = '';
                    self.somaY = '';
                else
                    self.somaX = self.recordingActive.UncagingHeader.soma1Coordinates(1);
                    self.somaY = self.recordingActive.UncagingHeader.soma1Coordinates(2);
                end

                if isfield(self.recordingActive.UncagingHeader,'somaZ') && ~isempty(self.recordingActive.UncagingHeader.somaZ)
                    self.somaZ = num2str(self.recordingActive.UncagingHeader.somaZ);
                elseif ~self.retainForNextCell
                    self.somaZ = '';
                end

                % avg laser intensity
                self.avgLaserIntensity = [self.avgLaserIntensity mean(self.recordingActive.LaserIntensity)];
            otherwise
                warning('ShepherdLab:mapalyzer:loadTraces:UnknownFileFormat', 'Unknown file format %s\n',ext(2:end));
                return
        end

        if ii == 1 % have to do this because of silly Matlab and its silly structs
            self.recordings = self.recordingActive;
        else
            self.recordings(ii) = self.recordingActive;
        end
    end

    % INFO PANEL display

    if strcmp(ext, '.mwf')
        k = strfind(self.recordingActive.BaseName, 'map');
        self.experimentName = self.recordingActive.BaseName(1 : (k-1));
    elseif strcmp(ext, '.xsg')
        self.experimentName = self.recordingActive.BaseName(1 : 6);
    else
        self.experimentName = self.recordingActive.RecordingName;
    end

    if strcmp(ext, '.xsg')
        if isfield(self.recordingActive.AcquirerHeader,'triggerTime') && ~isempty(self.recordingActive.AcquirerHeader.triggerTime)
            triggerTime = self.recordingActive.AcquirerHeader.triggerTime;
            self.triggerTime = datestr(datenum(triggerTime), 16);
            self.experimentDate = [datestr(datenum(triggerTime), 'ddd') ', ' datestr(datenum(triggerTime), 1)];
        else
            self.experimentDate = 'not noted';
            self.triggerTime = 'not noted';
        end
        
        if ~isempty(self.recordingActive.ScopeHeader.breakInTime)
            self.breakInTime = datestr(datenum(self.recordingActive.ScopeHeader.breakInTime), 16);
        else
            self.breakInTime = 'not noted';
        end

        % register and display clamp mode
        if isfield(self.recordingActive.PhysHeader,'modeString')
            self.clampMode = self.recordingActive.PhysHeader.modeString;

            switch self.clampMode(1)
                case 'V'
                    self.isCurrentClamp = 0;
                case 'I'
                    self.isCurrentClamp = 1; 
                otherwise
                    warning('ShepherdLab:mapalyzer:loadTraces:UnknownRecordingMode','Unknown recording mode %s\n',self.clampMode);
            end
        else
            self.clampMode = '';
        end

        self.laserIntensity = mean(self.avgLaserIntensity);

        if self.recordingActive.UncagingHeader.xSpacing == self.recordingActive.UncagingHeader.ySpacing
            self.mapSpacing = self.recordingActive.UncagingHeader.xSpacing;
        else
            self.mapSpacing = [self.recordingActive.UncagingHeader.xSpacing self.recordingActive.UncagingHeader.ySpacing];
        end

        self.mapPatternName = self.recordingActive.UncagingHeader.mapPattern;
        self.xPatternOffset = self.recordingActive.UncagingHeader.xPatternOffset;
        self.yPatternOffset = self.recordingActive.UncagingHeader.yPatternOffset;
        self.spatialRotation = self.recordingActive.UncagingHeader.spatialRotation;

        [self.somaXnew, self.somaYnew] = self.transformSomaPosition(...
            self.somaX,self.somaY,self.spatialRotation, ...
            self.xPatternOffset,self.yPatternOffset);

        % --------- reset cell params
        self.rseriesAvg = [];
        self.rmembraneAvg = [];
        self.cmembraneAvg = [];
        self.tauAvg = [];

        if ~self.retainForNextCell
            self.cellType = 'neuron';
            self.Vrest = [];
            self.Vhold = [];
            self.animalAge = [];
            self.exptCondition = '';
            self.notes = '';

            for cc = 'ABCDEFGH'
                self.(['field' cc 'Val']) = '';
            end
        end
    end

    % transfer the first map data set back to the active map directory:
    self.recordingActive = self.recordings(1);
end