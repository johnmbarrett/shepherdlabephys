	
	------------------------------------------------------------------------------------
	Help on using the INFORMATION panel
    
    Basic information about the acquisition and analysis is shown. Many items are
    extracted from the uncaging and physiology headers. The headers are stored in full 
    in the handles structure; e.g. handles.data.map.map1.uncagingHeader and 
    handles.data.map.map1.physHeader.
    
    The information includes some parameters that are automatically filled during trace 
    loading, and others that are only user-supplied. Some of the auto-loaded parameters 
    can be re-entered manually (e.g. the soma position parameters). Of course, once you 
    have created a data M-file for subsequent analyses, you can over-write any parameter 
    within it.
    
    The top part mainly contains panels that are auto-loaded; some are editable.
    
    The USER INPUT PARAMETERS in the bottom section are reset with each new loading; 
    i.e., they are user-provided for each experiment. 
    
    The three pairs of FIELD - VALUE boxes have a special purpose -- these are user-
    defined field names that will appear in the data M-file. You can either use the 
    default field name (fieldA, etc.) or change the field name to almost any 
    legitimate Matlab string variable; however, avoid underlines and other 
    non-letter strings as this can cause problems in generating the M-file.
    
    All the other boxes in the User Input section accept most standard Matlab string 
    or numeric inputs; again, best to avoid things like:  _  '  \  /  
    
    SEND HANDLES VARIABLE TO WORKSPACE -- this can be used at any time to place the 
    handles variable, containing all the analysis data and settings, to the workspace.
    
    GENERATE DATA M FILE -- this should only be used after analysis of an input map or 
    excitation profile has been performed. It does not work for a set of physiology
    traces. See also the help file on data M files.
	
    See also help on data M files
    
    Editing:
    gs july 2005 -- created
	------------------------------------------------------------------------------------
	
