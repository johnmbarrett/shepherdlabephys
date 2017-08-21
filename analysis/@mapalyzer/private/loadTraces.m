function loadTraces(self, mode)
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
            self.numberOfMaps = 1;
        case 2
            numberOfMaps = inputdlg('How many maps to analyze? ');

            if isempty(numberOfMaps)
                self.numberOfMaps = 0;
                return
            end

            self.numberOfMaps = str2double(numberOfMaps{1});
        case 3
            warndlg('Saving data as code is an utterly horrifying design pattern and should be avoided at all costs.  This feature may be removed in a future release of mapalyzer.  Proceed at your own risk...');
            dataMfile = inputdlg('Enter name of data M-file (e.g. g1091P1)');

            if isempty(dataMfile)
                return
            end

            try
                eval(['self.dataMfile = ' dataMfile{1} ';']);
                self.numberOfMaps = numel(self.dataMfile.mapNumbers);
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

    self.mapNumbers = [];

    for ii = 1:self.numberOfMaps
        % select the traces to load - step 1
        if mode < 3
            [filename, pathname] = uigetfile(...
                {   '*.xsg', 'Ephus traces (*.xsg)'; ...
                    '*.mwf', 'TidalWave traces (*.mwf)'; ...
                    '*.*', 'All files (*.*)'}, ...
                'Select any trace.'); % TODO : explicit trace selection instead of assuming we want all in the folder?
            
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
        self.mapActive.numTraces = numel(traceFiles);
        self.mapActive.directory = pathname;

        switch ext
            case '.mwf'
                self.mapNumbers = [self.mapNumbers str2double(self.mapActive.directory(end-1:end))];
            case '.xsg'
                dirs = strsplit(self.mapActive.directory,{'/' '\'});
                dirs = dirs(~cellfun(@isempty,dirs));
                mapNumber = sscanf(dirs{end},'map%f');

                if isempty(mapNumber)
                    warning('ShepherdLab:mapalyzer:loadTraces:UnknownMapNumbers', 'Problem extracting map number from directory name %s\n',self.mapActive.directory);
                else
                    self.mapNumbers(end+1) = mapNumber;
                end
            otherwise
                warning('ShepherdLab:mapalyzer:loadTraces:UnknownFileFormat', 'Unknown file format %s\n',ext(2:end));
                return
        end

        self.mapActive.uncagingPathName = pathname; % TODO : is this needed?

        self.mapActive.baseName = filename(1:end-4);
        self.mapActive.traceNumber = str2double(filename(end-3:end));

        self.patchChannel = 'P1'; % default

        if mode == 1 || mode == 2
            lastFile = traceFiles(numel(traceFiles));

            if ~isempty(strfind(lastFile.name, 'P2')) % i.e., there must be P2 traces ...
                patchChannel = questdlg('Choose patch channel to process', ...
                    'Select patch channel', 'P1', 'P2', 'P1');

                self.patchChannel = patchChannel;
                self.mapActive.numTraces = self.mapActive.numTraces/2;
                p = strfind(handles.data.map.mapActive.baseName, 'P1');
                self.mapActive.baseName(p+1) = patchChannel(2);
            end
        end

        % step 2
        if mode == 0
            self.mapActive.filenames = selectFilesFromList(pathname, ext);
            self.mapActive.numTraces = numel(self.mapActive.filenames);
        else %if mode == 1 || mode == 2 || mode == 3
            self.mapActive.filenames = arrayfun(@(jj) sprintf('%s%04d%s',self.mapActive.baseName,jj,ext),1:self.mapActive.numTraces,'UniformOutput',false);
        end

        for jj = 1:self.mapActive.numTraces
            fname = [self.mapActive.uncagingPathName self.mapActive.filenames{jj}];

            switch ext
                case '.xsg'
                    [data,self.sampleRate] = concatenateEphusTraces(fname,[],self.aiTraceNum,'Program',self.aiProgram);

                    % TODO : can probably do better than this?
                    if isempty(self.mapActive.dataArray)
                        self.mapActive.dataArray = data;
                    else
                        self.mapActive.dataArray(:,(end+1):(end+size(data,2))) = data;
                    end

                    % TODO : we load it here and in concatenateEphusTraces.
                    % Should be an option to pass the struct directly to
                    % concatenateEphusTraces
                    traceFile = load(fname,'-mat'); 

                    if isfield(traceFile.header, 'headerGUI')
                        self.mapActive.headerGUI = traceFile.header.headerGUI.headerGUI;
                    end

                    self.mapActive.physHeader = traceFile.header.ephys.ephys;
                    self.mapActive.uncagingHeader = traceFile.header.mapper.mapper;
                    self.mapActive.scopeHeader = traceFile.header.scopeGui.ephysScopeAccessory; % gs 20060625
                    self.mapActive.acquirerHeader = traceFile.header.acquirer.acquirer; % gs 20060625
                    self.mapActive.imagingSysHeader = traceFile.header.imagingSys.imagingSys; % gs 20080627
                    % NB -- for turbomaps, is this the correct value for the power????? i.e., was this the correctly computed value for this trace, or the prev trace?
                    self.mapActive.laserIntensity(jj) = self.mapActive.uncagingHeader.specimenPlanePower;
                otherwise
                    warning('ShepherdLab:mapalyzer:loadTraces:UnknownFileFormat', 'Unknown file format %s\n',ext(2:end));
                    return
            end
        end

        switch ext
            case '.xsg'
                if self.mapActive.uncagingHeader.xSpacing ~= self.mapActive.uncagingHeader.ySpacing
                    warning('ShepherdLab:mapalyzer:loadTraces:UnequalXYSpacing','Map %d has different X and Y spacing, using X spacing by default.',ii);
                end

                if isfield(self.mapActive.imagingSysHeader,'xMicrons') && isfield(self.mapActive.imagingSysHeader,'yMicrons')
                    self.imageXrange = self.mapActive.imagingSysHeader.xMicrons;
                    self.imageYrange = self.mapActive.imagingSysHeader.yMicrons;
                else %% TODO: implement these parameters properly
                    if ~isfield(self.mapActive.uncagingHeader,'videoHorizontalDistance')
                        self.mapActive.uncagingHeader.videoHorizontalDistance = 2666;
                        warning('ShepherdLab:mapalyzer:loadTraces:NoHorizontalDistance','No xMicrons or videoHorizontalDistance in map %d, using default value',ii);
                    end

                    if ~isfield(self.mapActive.uncagingHeader,'videoVerticalDistance')
                        self.mapActive.uncagingHeader.videoVerticalDistance = 2000;
                        warning('ShepherdLab:mapalyzer:loadTraces:NoVerticalDistance','No yMicrons or videoVerticalDistance in map %d, using default value',ii);
                    end

                    self.imageXrange = self.mapActive.uncagingHeader.videoHorizontalDistance;
                    self.imageYrange = self.mapActive.uncagingHeader.videoVerticalDistance;
                end

                if isempty(self.mapActive.uncagingHeader.soma1Coordinates)
                    self.somaX = '';
                    self.somaY = '';
                else
                    self.somaX = self.mapActive.uncagingHeader.soma1Coordinates(1);
                    self.somaY = self.mapActive.uncagingHeader.soma1Coordinates(2);
                end

                if isfield(self.mapActive.uncagingHeader,'somaZ') && ~isempty(self.mapActive.uncagingHeader.somaZ)
                    self.somaZ = num2str(self.mapActive.uncagingHeader.somaZ);
                elseif ~self.retainForNextCell
                    self.somaZ = '';
                end

                % avg laser intensity
                self.avgLaserIntensity = [self.avgLaserIntensity mean(self.mapActive.laserIntensity)];
            otherwise
                warning('ShepherdLab:mapalyzer:loadTraces:UnknownFileFormat', 'Unknown file format %s\n',ext(2:end));
                return
        end

        if ii == 1 % have to do this because of silly Matlab and its silly structs
            self.maps = self.mapActive;
        else
            self.maps(ii) = self.mapActive;
        end
    end

    % INFO PANEL display

    if strcmp(ext, '.mwf')
        k = strfind(self.mapActive.baseName, 'map');
        self.experimentName = self.mapActive.baseName(1 : (k-1));
    elseif strcmp(ext, '.xsg')
        self.experimentName = self.mapActive.baseName(1 : 6);
    end

    if isfield(self.mapActive.acquirerHeader,'triggerTime') && ~isempty(self.mapActive.acquirerHeader.triggerTime)
        triggerTime = self.mapActive.acquirerHeader.triggerTime;
        self.triggerTime = datestr(datenum(triggerTime), 16);
        self.experimentDate = [datestr(datenum(triggerTime), 'ddd') ', ' datestr(datenum(triggerTime), 1)];
    else
        self.experimentDate = 'not noted';
        self.triggerTime = 'not noted';
    end

    if ~isempty(self.mapActive.scopeHeader.breakInTime)
        self.breakInTime = datestr(datenum(self.mapActive.scopeHeader.breakInTime), 16);
    else
        self.breakInTime = 'not noted';
    end

    % register and display clamp mode
    if isfield(self.mapActive.physHeader,'modeString')
        self.clampMode = self.mapActive.physHeader.modeString;
        
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

    if self.mapActive.uncagingHeader.xSpacing == self.mapActive.uncagingHeader.ySpacing
        self.mapSpacing = self.mapActive.uncagingHeader.xSpacing;
    else
        self.mapSpacing = [self.mapActive.uncagingHeader.xSpacing self.mapActive.uncagingHeader.ySpacing];
    end

    self.mapPatternName = self.mapActive.uncagingHeader.mapPattern;
    self.xPatternOffset = self.mapActive.uncagingHeader.xPatternOffset;
    self.yPatternOffset = self.mapActive.uncagingHeader.yPatternOffset;
    self.spatialRotation = self.mapActive.uncagingHeader.spatialRotation;

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

    % transfer the first map data set back to the active map directory:
    self.mapActive = self.maps(1);
end