function p = parseINIFile(file)
    fin = fopen(file,'r');
    
    p = struct([]);
    
    while ~feof(fin)
        s = fgetl(fin);
        
        tokens = regexp(s,'(^[a-zA-Z][a-zA-Z_]*)=([^#]*)','tokens'); % TODO : unicode?
        
        if isempty(tokens)
            continue
        end
        
        value = tokens{1}{2};
        
        number = str2num(value); %#ok<ST2NM> str2double can't distinguish between literal NaN and a string that can't be parsed as a number
        
        if ~isempty(number)
            value = number;
        end
        
        p(1).(strtrim(tokens{1}{1})) = value;
    end
    
    fclose(fin);
end