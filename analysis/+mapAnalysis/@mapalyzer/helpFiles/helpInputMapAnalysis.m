	
	------------------------------------------------------------------------------------
	Help on using the INPUT MAP analysis panel
    
        ======================================================
        CAVEAT EMPTOR: although the default values that appear
        will be appropriate for many applications, you need to
        select map analysis parameters that are optimal for
        your application.
        ======================================================
    
    *** WINDOWS section ***
    
    The basic analysis windows are:
    
    |<-baseline->|<-dir->|<-synaptic->|
    ~~~~~~~~~~~~~~.    ____~~~~~~~~~~~~~~~~ direct response
                  | __/
                  |/
    ~~~~~~~~~~~~~~~~~~~~~~~.    ____~~~~~~~ synaptic response
                           | __/
                           |/
    
    BASELINE -- usually set to include most of the pre-stimulus region of the trace.
    
    DIRECT -- usually set to start at the stimulus, end at about 5-10 msec later, 
        depending on the cell type and other mapping conditions. A value of 7.5 msec 
        is used as default. The latency histogram of events provided in the analysis 
        figures will give a pretty good indication of whether the direct window 
        duration is appropriate -- ideally there will be a 'notch' between the direct 
        response latencies and the synaptic response latencies.
    
    SYNAPTIC -- at this point this is still forced to start at the end of the direct 
        window. NB: The duration is measured from the start of the direct window, not 
        the synaptic window.
    
    4TH WINDOW -- not yet implemented. This will allow the responses in an additional 
        window to be calculated. For example, it can be set to 0-4 msec post-stimulus, 
        to obtain maps of the direct responses in the temporal window prior to their 
        contamination by synaptic events.
    
    
    *** THRESHOLDS section ***
    
    METHOD -- selects between different algorithms. New users should use Method 2; 
        Method 1 is mainly for back-compatibility. In brief, 
        method 1 -- 'old' way; baseline is divided into 2 intervals which are 
            compared using min to find baseline distribution. Baseline-subtraction 
            relies on mean values.
        method 2 -- 'new' way (recommended); baseline noise level is determined based 
            on the mean standard deviation of the baseline traces. Baseline-
            subtraction relies on median values.
       
    POLARITY -- specify whether events are up- or down-going. For typical voltage-
        clamp recordings at hyperpolarized potentials (e.g. -70 mV) use the default 
        setting ('down').
    
    THRESHOLD LEVEL -- set the level (units of standard deviations). After running the 
        analysis, the 'Baseline noise' and 'pA or mV' windows will update.
    
    
    ANALYZE -- runs the analysis. Keep the checkbox 'with Rs, Rm' checked to include 
        the cell parameters calculations with the analysis. The 'show all histos' 
        option is mainly historical.  The 'trace averaging' option is under development.
        
    
    *** ANALYSIS PLOTS AND RESULTS ***
    
    Figure ARRAY2DPLOT -- plots of the results of the analysis of an individual map.
    
    Figure ARRAYAVGPLOTS -- plots of the average results for a set of multiple maps.
        Can still be run with only one map.
        
    Some data are also printed to the command line, but this is mainly historical.
    
    
    See also:
    Overview of analysis
    (Selecting map analysis parameters)
    (Analysis algorithm)
    
    Editing:
    gs july 2005 -- created
    
	------------------------------------------------------------------------------------
	