classdef MotorMapper
    methods(Abstract=true)
        [trajectory,motionTube] = trackMotion(self,I,varargin);
    end
    
    methods
        function [map,trajectories,pathLengths,motionTubes,roiPositions,saveFile] = mapMotion(self,files,varargin)
            parser = inputParser;
            parser.KeepUnmatched = true;
            parser.addParameter('ROIs',NaN,@(x) isa(x,'imroi') || (iscell(x) && all(cellfun(@(A) isequal(size(A),[1 4]),x))) || (isnumeric(x) && ismatrix(x) && size(x,2) == 4)); % TODO : duplicated code
            parser.addParameter('SaveFilePrefix',NaN,@(x) ischar(x)); % TODO : control full filename?
            parser.parse(varargin{:});

            rois = parser.Results.ROIs;

            % TODO : duplicated code
            I = loadLXJOrMATFile(files{1}); % TODO : extract handling of different file formats into its own class

            nTrials = numel(I); % TODO : really not this
            nFiles = numel(files);

            trajectories = cell(nFiles,nTrials);
            motionTubes = cell(nFiles,nTrials);

            for ii = 1:nFiles
                I = loadLXJOrMATFile(files{ii});

                for jj = 1:nTrials
                    tic; % TODO : logging?
                    % TODO : how many of the arguments passed in here are
                    % specific to BasicMotorMapper?
                    [trajectories{ii,jj},motionTubes{ii,jj}] = self.trackMotion(I{jj},varargin{:}); %sprintf('%d_trial_%d_motion_tracking',files{ii},jj));
                    toc;
                end
            end

            pathLengths = cell2mat(cellfun(@(t) sum(sqrt(sum(diff(t(~any(any(isnan(t),2),3),:,:),[],1).^2,2)),1),trajectories,'UniformOutput',false));

            map = squeeze(median(pathLengths,2));

            % TODO : does this function even need to return roiPositions???
            if isa(rois,'imroi')
                roiPositions = arrayfun(@(r) r.getPosition,rois,'UniformOutput',false);
                roiPositions = vertcat(roiPositions{:});
            elseif iscell(rois)
                roiPositions = vertcat(rois{:});
            else
                roiPositions = rois;
            end

            if ischar(parser.Results.SaveFilePrefix)
                saveFilePrefix = parser.Results.SaveFilePrefix;
            else
                dirs = strsplit(pwd,{'\' '/'});
                saveFilePrefix = dirs{end};
            end
            
            saveFile = [saveFilePrefix '_motion_tracking.mat'];
            
            save(saveFile,'-v7.3','map','trajectories','motionTubes','roiPositions','pathLengths','files'); % TODO : more control over file handling
        end
    end
end
    