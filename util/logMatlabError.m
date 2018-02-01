function logMatlabError(err, message, noStack)
    % for some reason Matlab has started printing stack traces with
    % warnings by default instead of displaying them as single lines, which
    % makes the warnings created by logMatlabError super hard to read.
    % This should fix that.
    % TODO : version dependency?
    backtraceState = warning('query','backtrace');
    verboseState = warning('query','verbose');
    
    warning('off','backtrace');
    warning('off','verbose');
    
    cleanup = onCleanup(@() cleanupWarningState(backtraceState,verboseState));

    if nargin < 2 || ~ischar(message)
        message = 'Encountered the following Matlab error:-';
    end
    
    warning(message);
    warning('%s - %s', err.identifier, err.message);
    
    if nargin > 2 && noStack
        return
    end
    
    for ii = 1:numel(err.stack)
        warning(' on line %d of %s (%s)', err.stack(ii).line, err.stack(ii).name, err.stack(ii).file);
    end
end

function cleanupWarningState(backtraceState,verboseState)
    warning([backtraceState verboseState]);
end