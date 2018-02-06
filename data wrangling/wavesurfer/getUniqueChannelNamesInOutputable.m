function channelNames = getUniqueChannelNamesInOutputable(outputables)
%GETUNIQUECHANNELNAMESINOUTPUTABLE  Get channel names from outputable
%   CHANNELNAMES = GETUNIQUECHANNELNAMESINOUTPUTABLE(OUTPUTABLES) returns a
%   cell array of the unique channel names in the array of WaveSurfer maps
%   or sequences OUTPUTABLES.  OUTPUTABLES may be a cell array or a struct
%   array.

%   Written by John Barrett 2018-02-06 17:11 CDT
%   Last updated John Barrett 2018-02-06 17:11 CDT
    channelNames = {};
    channelFields = {'ChannelName' 'ChannelNames'};
                        
    for ii = 1:numel(outputables)
        isChannelsFound = false;
        
        if iscell(outputables)
            outputable = outputables{ii};
        else
            outputable = outputables(ii);
        end
        
        for jj = 1:numel(channelFields)
            if isfield(outputable,channelFields{jj})
                isChannelsFound = true;
                channelNames = union(channelNames,outputable.(channelFields{jj}));
                break
            end
        end
        
        if ~isChannelsFound
            warnring('ShepherdLabEphys:getUniqueChannelNamesInOutputable:UnknownOutputableFormat','Cannot find channel names in selected outputable.');
        end
    end
end
                
            
                                