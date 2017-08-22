	
	------------------------------------------------------------------------------------
	Help on using the EXCITATION PROFILE panel
    
    This analysis is essentially a simpler version of the synaptic input map analysis.
    
    Settings:
        - Set the end of response interval to be the same as that used for the synaptic 
            input maps.
        - Although theoretically the start of the response interval should also be the 
            same as that used for the synaptic input maps, in practice this is set to 
            the stimulus onset (because of uncertainties in the delays due to spike 
            propagation, etc.).
        - Set the event threshold to a best-guess value to try to capture all the events 
            without also misidentifying noise as events. 
          
    Analysis:
        ==================================================================
        CAVEAT EMPTOR: It is imperative to review the analysis carefully 
        to be sure that the event threshold captured exactly the right 
        number of events; i.e., you need to verify by careful inspection 
        that there are no false positives or negatives. It is very likely 
        that you will need to change the threshold to accomplish this. In
        some cases the correct analysis cannot be accomplished (this can
        occur if a spike rides on a down-going direct response, for 
        instance). In these cases you can manually edit the map array in 
        the data M file. The analysis results for the cell will be off
        in the data M file, but these can be correctly obtained when
        the cell is re-analyzed as part of a group of excitation profiles, 
        using mapAverager.
        ==================================================================

    Editing:
    gs july 2005 -- created
	------------------------------------------------------------------------------------
	
