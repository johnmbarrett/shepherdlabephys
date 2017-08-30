function h = plotMotionTube(self,locationIndex,bodyPartIndex,trialIndex)
    frameRate = 100; % TODO : specify somewhere?
    frameOffset = 11;  % TODO : specify somewhere?
    deltaT = 1/frameRate;
    
    motionTube = self.MotionTubes{locationIndex,trialIndex}{bodyPartIndex}; % TODO : reverse order of bodyPartIndex and trialIndex?
    
    tt = ((1:size(motionTube,3))-frameOffset)*deltaT;

    h = figure;
    hold on;
    
    trajectories = self.Trajectories;
    
    mmppxTracking = 0.067; % TODO : push this into AlignmentInfo

    for ii = 1:size(motionTube,3)
        x = trajectories{locationIndex,trialIndex}(ii,1,bodyPartIndex)+(1:size(motionTube,2))-size(motionTube,2)/2-trajectories{locationIndex,trialIndex}(1,1,bodyPartIndex);
        y = trajectories{locationIndex,trialIndex}(ii,2,bodyPartIndex)+(1:size(motionTube,1))-size(motionTube,1)/2-trajectories{locationIndex,trialIndex}(1,2,bodyPartIndex);
        [X,Y] = meshgrid(x,y);
        surf(                                           ...
            tt(ii)*ones(size(X)),                       ...
            X*mmppxTracking,                            ...
            Y*mmppxTracking,                            ...
            'CData', motionTube(:,:,ii),                ...
            'CDataMapping', 'scaled',                   ...
            'AlphaData', ~isnan(motionTube(:,:,ii)),    ...
            'AlphaDataMapping', 'none',                 ...
            'EdgeColor', 'none',                        ...
            'FaceColor', 'flat',                        ...
            'FaceAlpha', 'flat'                         ...
            );
    end

    colormap(gray);
    caxis([0 255]);
    view(3);
    set(gca,'YDir','reverse','ZDir','reverse');
    xlabel('Time from Stimulus Onset (s)')
    xlim(tt([1 end]));
    ylabel('Horizontal Displacement (mm)');
    ylim([-3 3]);
    zlabel('Vertical Displacement (mm)');
    zlim([-3 3]);

    % TODO : more control over saving
    saveas(h,sprintf('VT%d_trial_%d_%s_motion_tube',locationIndex-1,trialIndex,self.BodyParts{bodyPartIndex}),'fig');
end