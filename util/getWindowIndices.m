function [startIndex,endIndex] = getWindowIndices(start,length,sampleRate,maxLength)
%GETWINDOWINDICES   Get indices for a specified time window
%   [STARTINDEX,ENDINDEX] = GETWINDOWINDICES(START,LENGTH,SAMPLERATE,...
%   MAXLENGTH) returns the STARTINDEX and ENDINDEX for a time window of
%   length LENGTH seconds starting at time START seconds assuming a sample
%   rate of SAMPLERATE Hz and a trace length of MAXLENGTH.  If STARTINDEX
%   is negative, it is treated as being relative to the end of the trace,
%   otherwise it is relative to the beginning of the trace.  Windows that
%   extend before the beginning or after the end of the trace are silently
%   truncated.

%   Written by John Barrett 2017-08-16 13:36 CDT
%   Last updated John Barrett 2017-08-16 13:39 CDT
    if start < 0
        startIndex = max(1,round(maxLength-start*sampleRate));
    else
        startIndex = max(1,min(maxLength,round(start*sampleRate)));
    end
    
    endIndex = max(1,min(maxLength,round(startIndex+length*sampleRate));
end