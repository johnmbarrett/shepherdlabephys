function logMatlabError(err, message, noStack)
    if nargin < 2 || ~ischar(message)
        message = 'Encountered the following Matlab error:-\n';
    end
    
    warning(message);
    warning('%s - $s\n', err.identifier, err.message);
    
    if nargin > 2 && noStack
        return
    end
    
    for ii = 1:numel(err.stack)
        warning(' on line %d of %s (%s)\n', err.stack(ii).line, err.stack(ii).name, err.stack(ii).line);
    end
end