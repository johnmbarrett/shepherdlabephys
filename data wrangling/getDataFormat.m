function format = getDataFormat(file)
    if ischar(file)
        [~,~,extension] = fileparts(file);
        
        switch extension
            case '.xsg'
                format = 'xsg';
            case '.h5';
                format = 'wavesurfer';
            otherwise
                format = 'unknown';
        end
        
        return
    end
    
    if isstruct(file)
        if isfield(file,'header')
            header = file.header;
            
            if isfield(header,'xsg')
                format = 'xsg';
                return
            end
            
            if isfield(header,'Acquisition')
                format = 'wavesurfer';
                return
            end
            
            format = 'unknown';
            
            return
        end
        
        format = 'unknown';
        
        return
    end
    
    format = 'unknown';
end