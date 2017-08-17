	
	------------------------------------------------------------------------------------
	OVERVIEW OF MAP ANALYSIS
    
    Please refer to the help files for additional help with specific issues.
    
    This provides a rough STEP-BY-STEP outline for a typical analysis session of a set 
    of synaptic input maps for one cell.
    
    (1) Load the traces: 
        Trace type > input map
        Load method > multiple maps, select manually
        Filtering > on
        Baseline subtraction > on
        > LOAD
        
    (2) Hit 'display' to review the video images. Print hardcopy.
    
    (3) Map and trace display:
        Hit 'Trace maps'. Print hardcopies.
        Hit 'Trace browser'. Review the data by selecting sites of interest on the 
        image.
        
    (4) In the 'Input map' panel:
        Specify the analysis settings appropriate for your application (do not simply 
        accept the defaults!). For example, if you had CPP in the bath, a shorter 
        response interval of ~50 msec might be used. Among the values you might change:
            - direct window duration (typically set to 5-10 ms)
            - synaptic window duration (typically set to 50-100 ms)
            - threshold level (typically set to 2-3)
            
    (5) Hit 'ANALYZE'. 
        Leave 'with Rs, Rm' checked, the others unchecked.
        Print hardcopy.
    
    (6) In the 'Information' panel:
        Modify/add information to the various fields.
        Hit 'Generate data M file' and save to a data M file directory.
        
    (7) At the command line, type: 
        >> clc;  M = dataMfilename; 
        This will allow you to review the data M file, to check that it was correctly 
        generated.  If desired, you can modify/add to the data M file directly. Finally, 
        print a hardcopy of the data M file output to command line, e.g. simply via 
        File > Print in the Matlab window. Change your Matlab Preferences to optimize 
        the hardcopy appearance.
            
    Editing:
    gs july 2005 -- created
	------------------------------------------------------------------------------------
	
