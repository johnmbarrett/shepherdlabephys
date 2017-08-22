	
	------------------------------------------------------------------------------------
	Help on LOADING TRACES
    
    Three different TRACE TYPES can be loaded:
    - 'general physiology traces' -- i.e., non-map traces; these are to be analyzed with 
        the 'Generic trace analysis' panel.
    - 'excitation profile' -- for analysis with the 'Excitation profile' panel.
    - 'input map' -- for analysis with the 'Input map' panel.
    
    Different LOAD METHODS are available in for some trace types. Specifically,
    - 'selected traces' -- this is mainly used to load general physiology traces. 
        A gui will appear that allows you to select all traces in directory, or just 
        a subset selected by using the ctrl or shift keys.
    - 'single map' -- standard way to load a set of excitation profile traces.  Can also 
        load a single map from a set of input maps this way. When this is chosen, you 
        select the set of map traces you want by double-clicking on any of the traces 
        when prompted.
    - 'multiple maps, selected manually' -- this loads a set of maps, each selected as 
        above.
    - 'multiple maps, from M-file' -- not yet fully implemented. Same as above, except 
        that the maps to load are obtained from the mapNum field in a data M-file, 
        instead of manually selecting them.
    
    FILTERING is performed by default.
    
    BASELINE SUBTRACTION is performed by default.
    
	Note that the DATA STRUCTURE for analysis of multiple mapsis : 
		handles.data.map
		handles.data.map.mapActive
		handles.data.map.map1
		handles.data.map.map2
		etc
    
    Editing:
    gs july 2005 -- created
    
	------------------------------------------------------------------------------------
	
