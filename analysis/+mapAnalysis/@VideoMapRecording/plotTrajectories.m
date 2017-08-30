function hs = plotTrajectories(self,l,varargin)
    parser = inputParser;
    
    parser.addRequired('locationIndex',@(x) isscalar(x) && isnumeric(x) && isreal(x) && isfinite(x) && round(x) == x && x > 0 && x <= size(self.Map,1));
    
    parser.addParameter('PlotComponentsSeparately',false,@(x) isscalar(x) && islogical(x));
    parser.addParameter('TrialIndex',NaN,@(x) isscalar(x) && isnumeric(x) && isreal(x) && isfinite(x) && round(x) == x && x > 0 && x <= size(self.PathLengths,2));
    
    parser.parse(l,varargin{:});
    
    trajectories = self.Trajectories;
    
    colourOrder = distinguishable_colors(size(trajectories,2));
    
    frameRate = 100; % TODO : specify somewhere?
    frameOffset = 11;  % TODO : specify somewhere?
    deltaT = 1/frameRate;
    
    tt = ((1:size(trajectories{l,1},1))-frameOffset)*deltaT;
    
    hs = gobjects(1,size(self.Map,2));
    
    mmppxTracking = 0.067; % TODO : push this into AlignmentInfo
    nSubplots = 1+2*parser.Results.PlotComponentsSeparately;
    axisLabels = {'Horizontal Displacement (mm)' 'Vertical Displacement (mm)' 'Euclidean Distance from Origin (mm)'};
    
    % TODO : more control over saving
    [~,finalFolder] = fileparts(pwd);
    
    if parser.Results.PlotComponentsSeparately
        saveFileInfix = 'trajectory_components';
    else
        saveFileInfix = 'trajectories';
    end
    
    if ~isnan(parser.Results.TrialIndex)
        saveFileSuffix = sprintf('_trial_%d_highlighted',parser.Results.TrialIndex);
    else
        saveFileSuffix = '';
    end
    
    for hh = 1:size(self.Map,2)
        hs(hh) = figure;
        axs = gobjects(1,nSubplots);
        
        for ii = 1:nSubplots
            axs(ii) = subplot(nSubplots,1,ii);
            hold(axs(ii),'on');
        end

        for ii = 1:size(trajectories,2)
            x = (trajectories{l,ii}(:,1,hh)-trajectories{l,ii}(1,1,hh))*mmppxTracking;
            y = (trajectories{l,ii}(:,2,hh)-trajectories{l,ii}(1,2,hh))*mmppxTracking;
            
            if parser.Results.PlotComponentsSeparately
                z = sqrt(x.^2+y.^2);
                data = {x y z};
                
                for jj = 1:nSubplots
                    plot(axs(jj),tt,data{jj},'Color',colourOrder(ii,:),'LineWidth',1+(ii==parser.Results.TrialIndex));
                end
            else
                plot3(tt,x,y,'Color',colourOrder(ii,:),'LineWidth',1+(ii==parser.Results.TrialIndex));
            end
        end
        
        if parser.Results.PlotComponentsSeparately
            for ii = 1:nSubplots
                xlabel(axs(ii),'Time from Stimulus Onset (s)');
                ylabel(axs(ii),axisLabels{ii});
            end
        else
            view(axs(1),3);
            set(axs(1),'YDir','reverse','ZDir','reverse');

            xlabel(axs(1),'Time from Stimulus Onset (s)');
            xlim(axs(1),tt([1 end]));
            ylabel(axs(1),axisLabels{1});
            ylim([-2 2]); % TODO : specify???
            zlabel(axs(1),axisLabels{2});
            zlim([-2 2]); % TODO : specify???

            saveas(gcf,sprintf('%s_%s_all_%s%s',finalFolder,self.BodyParts{hh},saveFileInfix,saveFileSuffix),'fig');
        end
    end
end