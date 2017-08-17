	
	------------------------------------------------------------------------------------
	Help on using the CURRENT-FREQUENCY ANALYSIS panel
    
    This panel enables you to analyze the spikes in a family of step responses, to
    generate frequency-current plots (f-I relationship, input-output functions) for
    neurons.
    
    To use, you must modify the start and duration parameters as necessary, to match
    the stimulus parameters for the current steps you used in the acquisition.  
    
    =====================================================
    CAVEAT EMPTOR: The threshold parameter's default of 5 
    should work well in general, but it is imperative to 
    verify this for your data. 
    =====================================================
    
    Hit 'specify traces' and provide a Matlab-format vector to specify the traces.
    
    Hit 'specify I steps' and provide a Matlab-format vector to specify the amplitudes
    of the family of current steps.
    
    The lengths of these two vectors should of course match.
    
    Hit ANALYZE. Analysis data are both plotted and printed to the command window.
    
    Editing:
    gs july 2005 -- created    
	------------------------------------------------------------------------------------
	