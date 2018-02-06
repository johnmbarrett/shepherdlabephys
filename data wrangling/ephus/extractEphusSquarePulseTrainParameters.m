function [amplitude,width,start,number,interval] = extractEphusSquarePulseTrainParameters(dataFiles,stimIndex,varargin)
%EXTRACTEPHUSSQUAREPULSETRAINPARAMETERS  Extract square pulse train
%parameters.
%   AMPLITUDE = EXTRACTEPHUSSQUAREPULSETRAINPARAMETERS(DATAFILE,STIMINDEX)
%   returns the AMPLITUDE of the STIMINDEXth stimulator stimulus in the xsg
%   file DATAFILE.  The stimulus is assumed to be a square pulse train.
%   DATAFILE maybe specified as a filename string or as a struct containing
%   the header from a previously loaded xsg file.  AMPLITUDE is a scalar
%   with arbitrary dimensionality.
%   
%   [AMPLITUDE,WIDTH,START,NUMBER,INTERVAL] =
%   EXTRACTEPHUSSQUAREPULSETRAINPARAMETERS(...) additionally returns the
%   WIDTH, START, NUMBER and inter-stimulus INTERVAL of the square pulse
%   train (all scalar, all in seconds apart from NUMBER, which is
%   dimensionless).
%
%   [...] = EXTRACTEPHUSSQUAREPULSETRAINPARAMETERS(...,PARAM,VAL,...) 
%   specifies one or more of the following name/value pairs:
%
%       'Program'   Specifies which Ephus program to extract the stimulus
%                   parameters from.  Must be one of 'ephys', 'pulseJacker'
%                   or giot'stimulator'.  Default is 'stimulator'.

%   Written by John Barrett 2017-07-28 11:42 CDT
%   Last updated John Barrett 2017-08-15 17:16 CDT
    if nargin < 2
        stimIndex = 1;
    end
    
    if ~iscell(dataFiles)
        dataFiles = {dataFiles};
    end
    
    nFiles = numel(dataFiles);
    
    start = nan(nFiles,1);
    width = nan(nFiles,1);
    interval = nan(nFiles,1);
    number = nan(nFiles,1);
    amplitude = nan(nFiles,1);
    
    for ii = 1:nFiles
        dataFile = dataFiles{ii};
        
        if ischar(dataFile)
            dataFile = load(dataFile,'-mat');
        end

        parser = inputParser;
        addParameter(parser,'Program','stimulator',@(x) any(strcmpi(x,{'ephys' 'pulseJacker' 'stimulator'})));
        parser.parse(varargin{:});

        program = lower(parser.Results.Program);

        switch program
            case {'ephys' 'stimulator'}
                stimData = dataFile.header.(program).(program).pulseParameters{1,stimIndex};
            case 'pulsejacker'
                pulseJacker = dataFile.header.pulseJacker.pulseJacker;

                if isempty(pulseJacker.pulseDataMap)
                    stimData = [];
                else
                    stimData = pulseJacker.pulseDataMap{stimIndex,pulseJacker.currentPosition+1};
                end
        end

        if isempty(stimData)
            continue
        end
        
        start(ii) = stimData.squarePulseTrainDelay;
        width(ii) = stimData.squarePulseTrainWidth;
        interval(ii) = stimData.squarePulseTrainISI;
        number(ii) = stimData.squarePulseTrainNumber;
        amplitude(ii) = stimData.amplitude;
    end

    if nargout <= 1 
        amplitude = struct('start',num2cell(start),'width',num2cell(width),'interval',num2cell(interval),'number',num2cell(number),'amplitude',num2cell(amplitude));
    end
end 