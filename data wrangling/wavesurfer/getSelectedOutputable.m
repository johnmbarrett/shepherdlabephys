function [maps,stimulusLibrary,nMaps] = getSelectedOutputable(dataFile)
%GETSELECTEDOUTPUTABLE  Get current selected WaveSurfer stimulus
%   MAPS = GETSELECTEDOUTPUTABLE(DATAFILE) returns the structure
%   corresponding to the stimulus sequence or map that was selected when
%   the WaveSurfer file DATAFILE was started.  DATAFILE should be a struct
%   of the kind returned by ws.loadDataFile.
%
%   [MAPS,STIMULUSLIBRARY] = GETSELECTEDOUTPUTABLE(DATAFILE) additionally
%   returns the STIMULUSLIBRARY struct from the header of DATAFILE
%
%   [MAPS,STIMULUSLIBRARY,NMAPS] = GETSELECTEDOUTPUTABLE(DATAFILE) also
%   returns the number of maps.  This is mostly for convenience.

%   Written by John Barrett 2018-02-06 16:56 CDT
%   Last updated John Barrett 2018-02-06 17:00 CDT
    stimulusLibrary = dataFile.header.Stimulation.StimulusLibrary;
    
    if isfield(stimulusLibrary,'SelectedOutputable')
        % it's a sequence!  I think
        sequence = stimulusLibrary.SelectedOutputable;
        nMaps = numel(fieldnames(sequence.Maps)); % ._.
        maps = arrayfun(@(ii) sequence.Maps.(sprintf('element%d',ii)),1:nMaps,'UniformOutput',false);
    else
        % it must be a map?
        assert(strcmp(stimulusLibrary.SelectedOutputableClassName,'ws.StimulusMap'),'ShepherdLab:extractWavesurferSquarePulseTrainParameters:UnknownOutputable','Unknown Outputable class: %s\n',stimulusLibrary.SelectedOutputableClassName);
        maps = {stimulusLibrary.Maps.(sprintf('element%d',stimulusLibrary.SelectedOutputableIndex))};
        nMaps = 1;
    end
end